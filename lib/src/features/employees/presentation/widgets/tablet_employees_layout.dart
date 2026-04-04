import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/employees_controller.dart';
import 'employee_list_panel.dart';

/// Two-pane tablet layout for employees.
///
/// Left pane: Employee list with search
/// Right pane: Employee detail from router or empty state
class TabletEmployeesLayout extends ConsumerWidget {
  const TabletEmployeesLayout({
    super.key,
    required this.detailContent,
  });

  final Widget detailContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesControllerProvider);

    final routerState = GoRouterState.of(context);
    final selectedEmployeeId = routerState.pathParameters['id'];

    return employeesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error: ${error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(employeesControllerProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (employees) => Row(
        children: [
          SizedBox(
            width: 320,
            child: EmployeeListPanel(employees: employees),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selectedEmployeeId != null
                ? detailContent
                : const _EmptyEmployeeState(),
          ),
        ],
      ),
    );
  }
}

class _EmptyEmployeeState extends StatelessWidget {
  const _EmptyEmployeeState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.badge_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select an employee to view details',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
