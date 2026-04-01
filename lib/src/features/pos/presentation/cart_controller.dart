import 'package:dart_mappable/dart_mappable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../settings/presentation/controllers/current_branch_controller.dart';
import '../../products/domain/product.dart';
import '../../products/domain/product_lot.dart';
import '../../services/domain/cart_service_item.dart';
import '../../services/domain/service.dart';
import '../data/repositories/cart_repository.dart';
import '../domain/cart.dart';
import '../domain/cart_item.dart';

part 'cart_controller.g.dart';
part 'cart_controller.mapper.dart';

/// Result of attempting to add a service to the cart.
enum AddServiceResult { success, maxReached }

/// State for the shopping cart.
@MappableClass()
class CartState with CartStateMappable {
  const CartState({
    this.cartId,
    this.items = const [],
    this.serviceItems = const [],
    this.isSyncing = false,
  });

  /// PocketBase cart record ID (null if not yet persisted).
  final String? cartId;

  /// Product items in the cart.
  final List<CartItem> items;

  /// Service items in the cart.
  final List<CartServiceItem> serviceItems;

  /// Whether a sync operation is in progress.
  final bool isSyncing;

  /// Total price of all items (products + services).
  double get total =>
      items.fold(0.0, (sum, item) => sum + item.total) +
      serviceItems.fold(0.0, (sum, item) => sum + item.total);

  /// Whether the cart is empty (no products and no services).
  bool get isEmpty => items.isEmpty && serviceItems.isEmpty;

  /// Whether the cart is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Total number of line items (products + services).
  int get totalItemCount => items.length + serviceItems.length;
}

@Riverpod(keepAlive: true)
class CartController extends _$CartController {
  CartRepository get _cartRepo => ref.read(cartRepositoryProvider);

  @override
  Future<CartState> build() async {
    // Try to load existing active cart for current working branch
    final branchId = ref.read(currentBranchIdProvider);

    if (branchId == null) {
      return const CartState();
    }

    // Check for existing active cart
    final result = await _cartRepo.getActiveCarts(branchId);
    return result.fold(
      (failure) => const CartState(),
      (carts) async {
        if (carts.isEmpty) {
          return const CartState();
        }

        // Load items from the most recent active cart
        final cart = carts.first;
        final itemsResult = await _cartRepo.getCartItems(cart.id);
        final serviceItemsResult =
            await _cartRepo.getCartServiceItems(cart.id);
        return itemsResult.fold(
          (failure) => CartState(cartId: cart.id),
          (items) => CartState(
            cartId: cart.id,
            items: items,
            serviceItems: serviceItemsResult.fold(
              (failure) => [],
              (serviceItems) => serviceItems,
            ),
          ),
        );
      },
    );
  }

  /// Creates a new cart in the backend if one doesn't exist.
  Future<String?> _ensureCart() async {
    final currentState = state.value;
    if (currentState?.cartId != null) {
      return currentState!.cartId;
    }

    final branchId = ref.read(currentBranchIdProvider);
    final userId = ref.read(currentAuthProvider)?.user.id;

    if (branchId == null) return null;

    final cart = Cart(
      id: '',
      branchId: branchId,
      status: 'active',
      userId: userId,
    );

    final result = await _cartRepo.createCart(cart);
    return result.fold(
      (failure) => null,
      (createdCart) {
        state = AsyncData(CartState(
          cartId: createdCart.id,
          items: currentState?.items ?? [],
          serviceItems: currentState?.serviceItems ?? [],
        ));
        return createdCart.id;
      },
    );
  }

  /// Adds a product to the cart (for non-lot-tracked products).
  /// For variable-price products, [customPrice] must be provided.
  Future<void> addToCart(Product product, {num? customPrice}) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Check if a matching item already exists:
    // - For variable-price products, match on productId + customPrice
    // - For regular products, match on productId (non-lot)
    final existingIndex = currentState.items.indexWhere((item) {
      if (item.productId != product.id || item.hasLot) return false;
      if (customPrice != null) return item.customPrice == customPrice;
      return !item.hasCustomPrice;
    });

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final existingItem = currentState.items[existingIndex];
      final newQuantity = existingItem.quantity + 1;
      await updateQuantityById(existingItem.id, newQuantity.toInt());
    } else {
      // Add new item
      state = AsyncData(currentState.copyWith(isSyncing: true));

      // Ensure cart exists in backend
      final cartId = await _ensureCart();
      if (cartId == null) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
        return;
      }

      // Create cart item in backend
      final cartItem = CartItem(
        cartId: cartId,
        productId: product.id,
        product: product,
        quantity: 1,
        customPrice: customPrice,
      );

      final result = await _cartRepo.addCartItem(cartItem);
      result.fold(
        (failure) {
          // Rollback on failure - keep local state but mark sync failed
          state = AsyncData(currentState.copyWith(isSyncing: false));
        },
        (createdItem) {
          // Preserve customPrice if the server didn't return it
          // (PocketBase may default to 0 which the DTO strips)
          final item = createdItem.customPrice == null && customPrice != null
              ? createdItem.copyWith(customPrice: customPrice)
              : createdItem;
          final newItems = <CartItem>[...currentState.items, item];
          state = AsyncData(currentState.copyWith(
            cartId: cartId,
            items: newItems,
            isSyncing: false,
          ));
        },
      );
    }
  }

  /// Adds a product with a specific lot to the cart.
  ///
  /// For lot-tracked products, items are identified by both productId AND lotId.
  /// This means the same product from different lots creates separate cart items.
  /// For variable-price products, [customPrice] must be provided.
  Future<void> addToCartWithLot(
    Product product,
    ProductLot lot,
    int quantity, {
    num? customPrice,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Check if same product+lot combination exists in cart
    final existingIndex = currentState.items.indexWhere(
      (item) => item.productId == product.id && item.productLotId == lot.id,
    );

    if (existingIndex >= 0) {
      // Update quantity of existing item (respecting lot stock limits)
      final existingItem = currentState.items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      // Validate against lot stock
      if (newQuantity > lot.quantity) {
        // Can't add more than available in lot
        return;
      }

      await updateQuantityWithLot(
        product,
        lot,
        newQuantity.toInt(),
      );
    } else {
      // Add new item with lot info
      state = AsyncData(currentState.copyWith(isSyncing: true));

      // Ensure cart exists in backend
      final cartId = await _ensureCart();
      if (cartId == null) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
        return;
      }

      // Create cart item with lot info
      final cartItem = CartItem(
        cartId: cartId,
        productId: product.id,
        product: product,
        quantity: quantity,
        customPrice: customPrice,
        productLotId: lot.id,
        lotNumber: lot.lotNumber,
      );

      final result = await _cartRepo.addCartItem(cartItem);
      result.fold(
        (failure) {
          state = AsyncData(currentState.copyWith(isSyncing: false));
        },
        (createdItem) {
          // Preserve customPrice if the server didn't return it
          final item = createdItem.customPrice == null && customPrice != null
              ? createdItem.copyWith(customPrice: customPrice)
              : createdItem;
          final newItems = <CartItem>[...currentState.items, item];
          state = AsyncData(currentState.copyWith(
            cartId: cartId,
            items: newItems,
            isSyncing: false,
          ));
        },
      );
    }
  }

  /// Updates the quantity of a lot-tracked item in the cart.
  Future<void> updateQuantityWithLot(
    Product product,
    ProductLot lot,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeFromCartWithLot(product, lot);
      return;
    }

    final currentState = state.value;
    if (currentState == null) return;

    final index = currentState.items.indexWhere(
      (item) => item.productId == product.id && item.productLotId == lot.id,
    );
    if (index < 0) return;

    final item = currentState.items[index];
    state = AsyncData(currentState.copyWith(isSyncing: true));

    // Update in backend
    final updatedItem = item.copyWith(quantity: quantity);
    final result = await _cartRepo.updateCartItem(updatedItem);

    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
      },
      (syncedItem) {
        final newItems = [...currentState.items];
        newItems[index] = syncedItem;
        state = AsyncData(currentState.copyWith(
          items: newItems,
          isSyncing: false,
        ));
      },
    );
  }

  /// Removes a lot-tracked product from the cart.
  Future<void> removeFromCartWithLot(Product product, ProductLot lot) async {
    final currentState = state.value;
    if (currentState == null) return;

    final item = currentState.items.firstWhere(
      (item) => item.productId == product.id && item.productLotId == lot.id,
      orElse: () => const CartItem(),
    );

    if (item.id.isEmpty) return;

    state = AsyncData(currentState.copyWith(isSyncing: true));

    // Delete from backend
    final result = await _cartRepo.deleteCartItem(item.id);
    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
      },
      (_) {
        final newItems = currentState.items
            .where((i) => !(i.productId == product.id && i.productLotId == lot.id))
            .toList();
        state = AsyncData(currentState.copyWith(
          items: newItems,
          isSyncing: false,
        ));
      },
    );
  }

  /// Removes a product from the cart.
  Future<void> removeFromCart(Product product) async {
    final currentState = state.value;
    if (currentState == null) return;

    final item = currentState.items.firstWhere(
      (item) => item.productId == product.id,
      orElse: () => const CartItem(),
    );

    if (item.id.isEmpty) return;

    state = AsyncData(currentState.copyWith(isSyncing: true));

    // Delete from backend
    final result = await _cartRepo.deleteCartItem(item.id);
    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
      },
      (_) {
        final newItems = currentState.items
            .where((i) => i.productId != product.id)
            .toList();
        state = AsyncData(currentState.copyWith(
          items: newItems,
          isSyncing: false,
        ));
      },
    );
  }

  /// Updates the quantity of a product in the cart (by product ID).
  ///
  /// For products that may have multiple line items (e.g. variable-price),
  /// prefer [updateQuantityById] instead.
  Future<void> updateQuantity(Product product, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(product);
      return;
    }

    final currentState = state.value;
    if (currentState == null) return;

    final index =
        currentState.items.indexWhere((item) => item.productId == product.id);
    if (index < 0) return;

    await _updateQuantityAtIndex(index, quantity);
  }

  /// Updates the quantity of a specific cart item by its ID.
  ///
  /// Use this for items that share a product ID (e.g. variable-price items
  /// with different custom prices).
  Future<void> updateQuantityById(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeItemById(cartItemId);
      return;
    }

    final currentState = state.value;
    if (currentState == null) return;

    final index =
        currentState.items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;

    await _updateQuantityAtIndex(index, quantity);
  }

  Future<void> _updateQuantityAtIndex(int index, int quantity) async {
    final currentState = state.value;
    if (currentState == null) return;

    final item = currentState.items[index];
    state = AsyncData(currentState.copyWith(isSyncing: true));

    // Update in backend
    final updatedItem = item.copyWith(quantity: quantity);
    final result = await _cartRepo.updateCartItem(updatedItem);

    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
      },
      (syncedItem) {
        // Preserve customPrice if the server didn't return it
        final finalItem = syncedItem.customPrice == null &&
                item.customPrice != null
            ? syncedItem.copyWith(customPrice: item.customPrice)
            : syncedItem;
        final newItems = [...currentState.items];
        newItems[index] = finalItem;
        state = AsyncData(currentState.copyWith(
          items: newItems,
          isSyncing: false,
        ));
      },
    );
  }

  /// Removes a specific cart item by its ID.
  Future<void> removeItemById(String cartItemId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final item = currentState.items.firstWhere(
      (item) => item.id == cartItemId,
      orElse: () => const CartItem(),
    );
    if (item.id.isEmpty) return;

    state = AsyncData(currentState.copyWith(isSyncing: true));

    final result = await _cartRepo.deleteCartItem(cartItemId);
    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
      },
      (_) {
        final newItems = currentState.items
            .where((i) => i.id != cartItemId)
            .toList();
        state = AsyncData(currentState.copyWith(
          items: newItems,
          isSyncing: false,
        ));
      },
    );
  }

  /// Updates the custom price of a cart item.
  Future<void> updateCustomPrice(String cartItemId, num newPrice) async {
    final currentState = state.value;
    if (currentState == null) return;

    final index =
        currentState.items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;

    final item = currentState.items[index];
    state = AsyncData(currentState.copyWith(isSyncing: true));

    final updatedItem = item.copyWith(customPrice: newPrice);
    final result = await _cartRepo.updateCartItem(updatedItem);

    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
      },
      (syncedItem) {
        // Preserve customPrice if the server didn't return it
        final finalItem = syncedItem.customPrice == null
            ? syncedItem.copyWith(customPrice: newPrice)
            : syncedItem;
        final newItems = [...currentState.items];
        newItems[index] = finalItem;
        state = AsyncData(currentState.copyWith(
          items: newItems,
          isSyncing: false,
        ));
      },
    );
  }

  // ── Service Item Methods ──────────────────────────────────────────────

  /// Adds a service to the cart.
  /// For variable-price services, [customPrice] must be provided.
  /// [quantity] defaults to 1 if not specified.
  /// When [forceNewLine] is true, always creates a new cart line instead of
  /// merging into an existing one (used for excess quantity splitting).
  ///
  /// Returns [AddServiceResult.maxReached] when the service has a
  /// `maxQuantity` limit, `allowExcess` is false, and the existing cart
  /// line is already at or above that limit.
  Future<AddServiceResult> addServiceToCart(
    Service service, {
    num? customPrice,
    int quantity = 1,
    bool forceNewLine = false,
  }) async {
    final currentState = state.value;
    if (currentState == null) return AddServiceResult.success;

    // Check if a matching service item already exists
    final existingIndex = forceNewLine
        ? -1
        : currentState.serviceItems.indexWhere((item) {
            if (item.serviceId != service.id) return false;
            if (customPrice != null) return item.customPrice == customPrice;
            return !item.hasCustomPrice;
          });

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final existingItem = currentState.serviceItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      final maxQty = service.maxQuantity;

      // Check if the new quantity would exceed the max
      if (maxQty != null && newQuantity > maxQty) {
        if (service.allowExcess) {
          // Create a new cart line with the requested quantity
          return addServiceToCart(
            service,
            customPrice: customPrice,
            quantity: quantity,
            forceNewLine: true,
          );
        } else {
          // Max reached and excess not allowed
          return AddServiceResult.maxReached;
        }
      }

      await updateServiceQuantityById(existingItem.id, newQuantity.toInt());
      return AddServiceResult.success;
    } else {
      // Add new item
      state = AsyncData(currentState.copyWith(isSyncing: true));

      final cartId = await _ensureCart();
      if (cartId == null) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
        return AddServiceResult.success;
      }

      final cartServiceItem = CartServiceItem(
        cartId: cartId,
        serviceId: service.id,
        service: service,
        quantity: quantity,
        customPrice: customPrice,
      );

      final result = await _cartRepo.addCartServiceItem(cartServiceItem);
      result.fold(
        (failure) {
          state = AsyncData(currentState.copyWith(isSyncing: false));
        },
        (createdItem) {
          final item = createdItem.customPrice == null && customPrice != null
              ? createdItem.copyWith(customPrice: customPrice)
              : createdItem;
          final newServiceItems = [
            ...currentState.serviceItems,
            item,
          ];
          state = AsyncData(currentState.copyWith(
            cartId: cartId,
            serviceItems: newServiceItems,
            isSyncing: false,
          ));
        },
      );
      return AddServiceResult.success;
    }
  }

  /// Updates the quantity of a specific cart service item by its ID.
  Future<void> updateServiceQuantityById(
      String cartServiceItemId, int quantity) async {
    if (quantity <= 0) {
      await removeServiceItemById(cartServiceItemId);
      return;
    }

    final currentState = state.value;
    if (currentState == null) return;

    final index = currentState.serviceItems
        .indexWhere((item) => item.id == cartServiceItemId);
    if (index < 0) return;

    final item = currentState.serviceItems[index];

    // Cap quantity at maxQuantity if the service doesn't allow excess.
    // Overflow / splitting is handled upstream by addServiceToCart.
    final maxQty = item.service?.maxQuantity;
    if (maxQty != null && quantity > maxQty) {
      quantity = maxQty;
    }
    state = AsyncData(currentState.copyWith(isSyncing: true));

    final updatedItem = item.copyWith(quantity: quantity);
    final result = await _cartRepo.updateCartServiceItem(updatedItem);

    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
      },
      (syncedItem) {
        final finalItem =
            syncedItem.customPrice == null && item.customPrice != null
                ? syncedItem.copyWith(customPrice: item.customPrice)
                : syncedItem;
        final newServiceItems = [...currentState.serviceItems];
        newServiceItems[index] = finalItem;
        state = AsyncData(currentState.copyWith(
          serviceItems: newServiceItems,
          isSyncing: false,
        ));
      },
    );
  }

  /// Removes a specific cart service item by its ID.
  Future<void> removeServiceItemById(String cartServiceItemId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final item = currentState.serviceItems.firstWhere(
      (item) => item.id == cartServiceItemId,
      orElse: () => const CartServiceItem(),
    );
    if (item.id.isEmpty) return;

    state = AsyncData(currentState.copyWith(isSyncing: true));

    final result = await _cartRepo.deleteCartServiceItem(cartServiceItemId);
    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
      },
      (_) {
        final newServiceItems = currentState.serviceItems
            .where((i) => i.id != cartServiceItemId)
            .toList();
        state = AsyncData(currentState.copyWith(
          serviceItems: newServiceItems,
          isSyncing: false,
        ));
      },
    );
  }

  /// Updates the custom price of a cart service item.
  Future<void> updateServiceCustomPrice(
      String cartServiceItemId, num newPrice) async {
    final currentState = state.value;
    if (currentState == null) return;

    final index = currentState.serviceItems
        .indexWhere((item) => item.id == cartServiceItemId);
    if (index < 0) return;

    final item = currentState.serviceItems[index];
    state = AsyncData(currentState.copyWith(isSyncing: true));

    final updatedItem = item.copyWith(customPrice: newPrice);
    final result = await _cartRepo.updateCartServiceItem(updatedItem);

    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(isSyncing: false));
      },
      (syncedItem) {
        final finalItem = syncedItem.customPrice == null
            ? syncedItem.copyWith(customPrice: newPrice)
            : syncedItem;
        final newServiceItems = [...currentState.serviceItems];
        newServiceItems[index] = finalItem;
        state = AsyncData(currentState.copyWith(
          serviceItems: newServiceItems,
          isSyncing: false,
        ));
      },
    );
  }

  /// Clears all items from the cart.
  Future<void> clearCart() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(isSyncing: true));

    // Delete all product items from backend
    for (final item in currentState.items) {
      if (item.id.isNotEmpty) {
        await _cartRepo.deleteCartItem(item.id);
      }
    }

    // Delete all service items from backend
    for (final item in currentState.serviceItems) {
      if (item.id.isNotEmpty) {
        await _cartRepo.deleteCartServiceItem(item.id);
      }
    }

    // Update cart status to abandoned if it exists
    if (currentState.cartId != null) {
      final cart = Cart(
        id: currentState.cartId!,
        branchId: '',
        status: 'abandoned',
      );
      await _cartRepo.updateCart(cart);
    }

    state = const AsyncData(CartState());
  }

  /// Marks the cart as converted after successful checkout.
  Future<void> markAsConverted() async {
    final currentState = state.value;
    if (currentState?.cartId == null) return;

    final cart = Cart(
      id: currentState!.cartId!,
      branchId: '',
      status: 'converted',
    );
    await _cartRepo.updateCart(cart);

    state = const AsyncData(CartState());
  }
}

/// Provider for cart total.
@Riverpod(keepAlive: true)
double cartTotal(Ref ref) {
  final cartState = ref.watch(cartControllerProvider);
  return cartState.value?.total ?? 0;
}

/// Provider for cart product items.
@Riverpod(keepAlive: true)
List<CartItem> cartItems(Ref ref) {
  final cartState = ref.watch(cartControllerProvider);
  return cartState.value?.items ?? [];
}

/// Provider for cart service items.
@Riverpod(keepAlive: true)
List<CartServiceItem> cartServiceItems(Ref ref) {
  final cartState = ref.watch(cartControllerProvider);
  return cartState.value?.serviceItems ?? [];
}
