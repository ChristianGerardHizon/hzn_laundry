import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/domain/product.dart';
import '../../../services/data/repositories/service_repository.dart';
import '../../../services/domain/service.dart';
import '../cart_controller.dart';
import 'lot_selection_dialog.dart';
import 'quantity_prompt_dialog.dart';
import 'variable_price_dialog.dart';

/// A search field with a dropdown overlay that shows matching products/services.
///
/// Used in the grouped cashier view to search across all items.
/// Tapping a result adds it to the cart directly.
class CashierSearchDropdown extends HookConsumerWidget {
  const CashierSearchDropdown({
    super.key,
    this.isDense = false,
  });

  final bool isDense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final layerLink = useMemoized(() => LayerLink());
    final overlayEntry = useState<OverlayEntry?>(null);
    final focusNode = useFocusNode();

    // Debounce search
    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    // Show/hide overlay based on search query and focus
    // Use addPostFrameCallback to avoid calling during build
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (searchQuery.value.trim().isNotEmpty && focusNode.hasFocus) {
          _showOverlay(
            context,
            ref,
            layerLink,
            overlayEntry,
            searchQuery.value,
            searchController,
          );
        } else {
          _removeOverlay(overlayEntry);
        }
      });
      return null;
    }, [searchQuery.value]);

    // Clean up overlay on dispose
    useEffect(() {
      return () => _removeOverlay(overlayEntry);
    }, []);

    return CompositedTransformTarget(
      link: layerLink,
      child: TextField(
        controller: searchController,
        focusNode: focusNode,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search products & services...',
          border: const OutlineInputBorder(),
          isDense: isDense,
          suffixIcon: searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _removeOverlay(overlayEntry);
                  },
                )
              : null,
        ),
        onTap: () {
          if (searchQuery.value.trim().isNotEmpty) {
            _showOverlay(
              context,
              ref,
              layerLink,
              overlayEntry,
              searchQuery.value,
              searchController,
            );
          }
        },
      ),
    );
  }

  void _showOverlay(
    BuildContext context,
    WidgetRef ref,
    LayerLink layerLink,
    ValueNotifier<OverlayEntry?> overlayEntry,
    String query,
    TextEditingController searchController,
  ) {
    _removeOverlay(overlayEntry);

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _SearchDropdownOverlay(
        link: layerLink,
        query: query,
        ref: ref,
        onItemSelected: () {
          searchController.clear();
          _removeOverlay(overlayEntry);
        },
        onDismiss: () {
          _removeOverlay(overlayEntry);
        },
      ),
    );

    overlayEntry.value = entry;
    overlay.insert(entry);
  }

  void _removeOverlay(ValueNotifier<OverlayEntry?> overlayEntry) {
    overlayEntry.value?.remove();
    overlayEntry.value = null;
  }
}

class _SearchDropdownOverlay extends StatelessWidget {
  const _SearchDropdownOverlay({
    required this.link,
    required this.query,
    required this.ref,
    required this.onItemSelected,
    required this.onDismiss,
  });

  final LayerLink link;
  final String query;
  final WidgetRef ref;
  final VoidCallback onItemSelected;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dismiss barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
        // Dropdown
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300,
                maxWidth: 500,
              ),
              child: _SearchResultsList(
                query: query,
                ref: ref,
                onItemSelected: onItemSelected,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.query,
    required this.ref,
    required this.onItemSelected,
  });

  final String query;
  final WidgetRef ref;
  final VoidCallback onItemSelected;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _searchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No results for "$query"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return _SearchResultTile(
              item: item,
              ref: ref,
              onSelected: onItemSelected,
            );
          },
        );
      },
    );
  }

  Future<List<_SearchResult>> _searchAll() async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final pb = ref.read(pocketbaseProvider);
      final filter = PBFilter()
          .searchFields(trimmed, ['name', 'description'])
          .build();

      final records = await pb
          .collection(PocketBaseCollections.vwPosSearchItems)
          .getFullList(
            filter: filter,
            sort: 'name',
          );

      return records
          .map((r) => _SearchResult(
                id: r.id,
                type: r.getStringValue('type'),
                name: r.getStringValue('name'),
                description: r.getStringValue('description'),
                price: (r.data['price'] as num?)?.toDouble() ?? 0,
                branch: r.getStringValue('branch'),
              ))
          .toList();
    } catch (_) {
      // Fallback to dual-query if view is unavailable
      return _searchAllFallback();
    }
  }

  /// Fallback search using separate product/service repositories.
  Future<List<_SearchResult>> _searchAllFallback() async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final productRepo = ref.read(productRepositoryProvider);
    final serviceRepo = ref.read(serviceRepositoryProvider);

    final results = await Future.wait([
      productRepo.search(trimmed, fields: ['name', 'description']),
      serviceRepo.search(trimmed, fields: ['name', 'description']),
    ]);

    final items = <_SearchResult>[];

    results[0].fold(
      (_) {},
      (products) {
        for (final product in (products as List<Product>)) {
          if (product.forSale && !product.isDeleted) {
            items.add(_SearchResult(
              id: product.id,
              type: 'product',
              name: product.name,
              description: product.description,
              price: product.price.toDouble(),
              branch: product.branch,
            ));
          }
        }
      },
    );

    results[1].fold(
      (_) {},
      (services) {
        for (final service in (services as List<Service>)) {
          if (!service.isDeleted) {
            items.add(_SearchResult(
              id: service.id,
              type: 'service',
              name: service.name,
              description: service.description,
              price: service.price.toDouble(),
              branch: service.branch,
            ));
          }
        }
      },
    );

    return items;
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.item,
    required this.ref,
    required this.onSelected,
  });

  final _SearchResult item;
  final WidgetRef ref;
  final VoidCallback onSelected;

  bool get isProduct => item.type == 'product';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVariablePrice = item.price <= 0;

    return ListTile(
      dense: true,
      leading: Icon(
        isProduct ? Icons.inventory_2 : Icons.miscellaneous_services,
        color: isProduct ? theme.colorScheme.primary : theme.colorScheme.tertiary,
      ),
      title: Text(item.name),
      subtitle: Text(
        isVariablePrice ? 'Variable price' : item.price.toCurrency(),
      ),
      trailing: Text(
        isProduct ? 'Product' : 'Service',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      onTap: () => _handleTap(context),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    if (isProduct) {
      await _handleProductTap(context);
    } else {
      await _handleServiceTap(context);
    }
    onSelected();
  }

  Future<void> _handleProductTap(BuildContext context) async {
    // Fetch the full product object for cart logic (lot tracking, etc.)
    final productRepo = ref.read(productRepositoryProvider);
    final result = await productRepo.fetchOne(item.id);

    result.fold((_) {}, (product) {
      if (!context.mounted) return;
      final cartNotifier = ref.read(cartControllerProvider.notifier);

      if (product.trackByLot) {
        showLotSelectionDialog(
          context,
          product: product,
          onLotSelected: (lot, quantity) {
            if (product.isVariablePrice) {
              showVariablePriceDialog(context, productName: product.name)
                  .then((price) {
                if (price != null) {
                  cartNotifier.addToCartWithLot(product, lot, quantity,
                      customPrice: price);
                }
              });
            } else {
              cartNotifier.addToCartWithLot(product, lot, quantity);
            }
          },
        );
      } else if (product.isVariablePrice) {
        showVariablePriceDialog(context, productName: product.name)
            .then((price) {
          if (price != null) {
            cartNotifier.addToCart(product, customPrice: price);
          }
        });
      } else {
        cartNotifier.addToCart(product);
      }
    });
  }

  Future<void> _handleServiceTap(BuildContext context) async {
    // Fetch the full service object for cart logic
    final serviceRepo = ref.read(serviceRepositoryProvider);
    final result = await serviceRepo.fetchOne(item.id);

    result.fold((_) {}, (service) {
      if (!context.mounted) return;
      final cartNotifier = ref.read(cartControllerProvider.notifier);

      if (service.hasVariablePrice) {
        // Variable price services always show price dialog
        showVariablePriceDialog(context, productName: service.name)
            .then((price) {
          if (price != null) {
            if (service.showPrompt) {
              // Also prompt for quantity after price
              showQuantityPromptDialog(
                context,
                serviceName: service.name,
                maxQuantity: service.maxQuantity,
                unitLabel: service.quantityUnit?.shortPlural,
              ).then((quantity) {
                if (quantity != null) {
                  cartNotifier.addServiceToCart(
                    service,
                    customPrice: price,
                    quantity: quantity,
                  );
                }
              });
            } else {
              cartNotifier.addServiceToCart(service, customPrice: price);
            }
          }
        });
      } else if (service.showPrompt) {
        // Show quantity prompt for non-variable price services
        showQuantityPromptDialog(
          context,
          serviceName: service.name,
          maxQuantity: service.maxQuantity,
          unitLabel: service.quantityUnit?.shortPlural,
        ).then((quantity) {
          if (quantity != null) {
            cartNotifier.addServiceToCart(service, quantity: quantity);
          }
        });
      } else {
        cartNotifier.addServiceToCart(service);
      }
    });
  }
}

/// Lightweight search result from the combined view.
class _SearchResult {
  final String id;
  final String type;
  final String name;
  final String? description;
  final double price;
  final String? branch;

  const _SearchResult({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.price,
    this.branch,
  });
}
