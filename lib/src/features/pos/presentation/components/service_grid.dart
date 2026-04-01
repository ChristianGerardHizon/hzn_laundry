import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../services/data/repositories/service_repository.dart';
import '../../../services/domain/service.dart';
import '../cart_controller.dart';
import 'quantity_prompt_dialog.dart';
import 'variable_price_dialog.dart';

class ServiceGrid extends ConsumerWidget {
  const ServiceGrid({
    super.key,
    this.searchQuery = '',
  });

  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: _fetchServices(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final result = snapshot.data;
        if (result == null) {
          return const Center(child: Text('No services loaded'));
        }

        return result.fold(
          (failure) => Center(child: Text('Error: ${failure.message}')),
          (services) {
            if (services.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      searchQuery.isEmpty
                          ? 'No services found'
                          : 'No services match "$searchQuery"',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width < 400
                    ? 3
                    : width < 600
                        ? 4
                        : width < 900
                            ? 5
                            : 6;

                // Adjust aspect ratio based on column count
                // More columns = wider cards, fewer columns = taller cards
                final childAspectRatio = crossAxisCount <= 3 ? 0.9 : 1.3;

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return _ServiceCard(service: service);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Either<Failure, List<Service>>> _fetchServices(WidgetRef ref) async {
    final repository = ref.read(serviceRepositoryProvider);

    if (searchQuery.trim().isEmpty) {
      return repository.fetchAll();
    } else {
      return repository.search(
        searchQuery.trim(),
        fields: ['name', 'description'],
      );
    }
  }
}

class _ServiceCard extends ConsumerWidget {
  const _ServiceCard({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleServiceTap(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service name
              Expanded(
                child: Text(
                  service.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Price
              Text(
                service.isVariablePrice
                    ? 'Variable'
                    : service.price.toCurrency(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: service.isVariablePrice
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleServiceTap(BuildContext context, WidgetRef ref) async {
    final cartNotifier = ref.read(cartControllerProvider.notifier);

    if (service.isVariablePrice) {
      // Variable price services always show price dialog
      showVariablePriceDialog(
        context,
        productName: service.name,
      ).then((price) {
        if (price != null) {
          if (service.showPrompt) {
            // Also prompt for quantity after price
            showQuantityPromptDialog(
              context,
              serviceName: service.name,
              maxQuantity: service.maxQuantity,
              allowExcess: service.allowExcess,
              unitLabel: service.quantityUnit?.shortPlural,
            ).then((quantity) {
              if (quantity != null) {
                _addServiceWithPossibleSplit(
                  cartNotifier,
                  quantity,
                  customPrice: price,
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
        allowExcess: service.allowExcess,
        unitLabel: service.quantityUnit?.shortPlural,
      ).then((quantity) {
        if (quantity != null) {
          _addServiceWithPossibleSplit(cartNotifier, quantity);
        }
      });
    } else {
      final result = await cartNotifier.addServiceToCart(service);
      if (result == AddServiceResult.maxReached && context.mounted) {
        showErrorSnackBar(
          context,
          message:
              '${service.name} has reached the maximum quantity of ${service.maxQuantity} per order',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  /// Adds a service to the cart, splitting into multiple items if necessary.
  ///
  /// When [service.allowExcess] is true and [quantity] exceeds [service.maxQuantity],
  /// creates multiple cart items (e.g., quantity=12 with max=5 creates items of 5, 5, 2).
  /// Each call is awaited sequentially to avoid state race conditions.
  Future<void> _addServiceWithPossibleSplit(
    CartController cartNotifier,
    int quantity, {
    num? customPrice,
  }) async {
    final max = service.maxQuantity;

    // If no max, allowExcess is false, or quantity is within max, add normally
    if (max == null || max <= 0 || !service.allowExcess || quantity <= max) {
      await cartNotifier.addServiceToCart(
        service,
        customPrice: customPrice,
        quantity: quantity,
      );
      return;
    }

    // Split into multiple cart items, each as a separate line
    final fullItems = quantity ~/ max;
    final remainder = quantity % max;

    // Add full items — must be sequential so each sees the updated state
    for (var i = 0; i < fullItems; i++) {
      await cartNotifier.addServiceToCart(
        service,
        customPrice: customPrice,
        quantity: max,
        forceNewLine: true,
      );
    }

    // Add remainder if any
    if (remainder > 0) {
      await cartNotifier.addServiceToCart(
        service,
        customPrice: customPrice,
        quantity: remainder,
        forceNewLine: true,
      );
    }
  }
}
