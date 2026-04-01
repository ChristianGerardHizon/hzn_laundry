import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../data/dto/customer_promo_dto.dart';
import '../../domain/customer_promo.dart';

/// Shows the list of customers enrolled in a specific promo with their progress.
class CustomerPromoList extends ConsumerWidget {
  const CustomerPromoList({
    super.key,
    required this.promoId,
  });

  final String promoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inline fetch — this is a detail-view widget, not a reusable provider
    return FutureBuilder<List<_CustomerPromoEntry>>(
      future: _fetchEntries(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final entries = snapshot.data ?? [];

        if (entries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No customers enrolled yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }

        return Column(
          children: entries.map((e) => _EntryTile(entry: e)).toList(),
        );
      },
    );
  }

  Future<List<_CustomerPromoEntry>> _fetchEntries(WidgetRef ref) async {
    final pb = ref.read(pocketbaseProvider);
    final filter = PBFilter()
        .notDeleted()
        .relation('promo', promoId)
        .build();

    final records = await pb
        .collection(PocketBaseCollections.customerPromos)
        .getFullList(
          filter: filter,
          expand: 'customer,promo',
          sort: 'customer',
        );

    return records.map((record) {
      final json = record.toJson();
      final cp = CustomerPromoDto.fromRecord(record).toEntity();

      // Extract customer name from expand
      String customerName = 'Unknown';
      final expand = json['expand'] as Map<String, dynamic>?;
      if (expand != null && expand['customer'] != null) {
        final custData = expand['customer'] as Map<String, dynamic>;
        customerName = custData['name'] as String? ?? 'Unknown';
      }

      return _CustomerPromoEntry(
        customerPromo: cp,
        customerName: customerName,
      );
    }).toList();
  }
}

class _CustomerPromoEntry {
  final CustomerPromo customerPromo;
  final String customerName;

  _CustomerPromoEntry({
    required this.customerPromo,
    required this.customerName,
  });
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final _CustomerPromoEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cp = entry.customerPromo;
    final requiredOrders = cp.promo?.requiredOrders ?? 0;

    String statusText;
    Color statusColor;
    if (cp.isRewardRedeemed) {
      statusText = 'Redeemed';
      statusColor = theme.colorScheme.tertiary;
    } else if (cp.isRewardEarned) {
      statusText = 'Reward Earned';
      statusColor = theme.colorScheme.primary;
    } else {
      statusText = '${cp.completedOrders}/$requiredOrders orders';
      statusColor = theme.colorScheme.onSurfaceVariant;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Text(
          entry.customerName.isNotEmpty
              ? entry.customerName[0].toUpperCase()
              : '?',
          style: theme.textTheme.bodySmall,
        ),
      ),
      title: Text(entry.customerName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: cp.progressPercent,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 2),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }
}
