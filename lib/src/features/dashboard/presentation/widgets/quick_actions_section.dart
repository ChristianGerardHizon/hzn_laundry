import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../customers/presentation/widgets/customer_form_sheet.dart';
import '../../../employees/presentation/widgets/attendance_dialog.dart';
import '../../../sales/presentation/widgets/create_order_dialog.dart';
import 'orders_by_resource_dialog.dart';

/// Section displaying quick action buttons on the dashboard.
///
/// Provides fast access to common tasks:
/// - Open POS/Cashier
/// - Show dashboard overview (tablet only)
class QuickActionsSection extends ConsumerWidget {
  const QuickActionsSection({
    super.key,
    this.onShowOverview,
  });

  /// Optional callback to show the dashboard overview (clears selection).
  /// Only shown when this callback is provided (tablet layout).
  final VoidCallback? onShowOverview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Show Dashboard Overview button only on tablet
                if (onShowOverview != null) ...[
                  _QuickActionButton(
                    icon: Icons.dashboard,
                    label: 'Overview',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: onShowOverview!,
                  ),
                  const SizedBox(width: 12),
                ],
                _QuickActionButton(
                  icon: Icons.add_shopping_cart,
                  label: 'New Sale',
                  color: Colors.green,
                  filled: true,
                  onTap: () => showCreateOrderDialog(context),
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'New Customer',
                  color: Colors.blue,
                  onTap: () => showCustomerFormDialog(context),
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.how_to_reg,
                  label: 'Attendance',
                  color: Colors.orange,
                  onTap: () => showAttendanceDialog(context),
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.local_laundry_service,
                  label: 'Machine & Storage',
                  color: Colors.purple,
                  onTap: () => showOrdersByResourceDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = filled ? color : color.withValues(alpha: 0.1);
    final fgColor = filled ? Colors.white : color;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      elevation: filled ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: fgColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
