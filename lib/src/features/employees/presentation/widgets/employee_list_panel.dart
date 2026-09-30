import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/widgets/list/list.dart';
import 'package:intl/intl.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';

import '../../../../core/routing/routes/employees.routes.dart';
import '../../../entitlements/domain/entitlement_limit.dart';
import '../../../entitlements/presentation/controllers/can_add_employee_provider.dart';
import '../../../entitlements/presentation/controllers/entitlement_limit_provider.dart';
import '../../domain/employee.dart';
import '../controllers/employees_controller.dart';
import 'employee_form_dialog.dart';

/// List panel for displaying employees with search and create.
class EmployeeListPanel extends HookConsumerWidget {
  const EmployeeListPanel({
    super.key,
    required this.employees,
  });

  final List<Employee> employees;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final canAdd = ref.watch(canAddEmployeeProvider);
    final employeeLimit = ref.watch(entitlementLimitProvider(LimitKey.employees));

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final filteredEmployees = searchQuery.value.isEmpty
        ? employees
        : employees.where((e) {
            final query = searchQuery.value.toLowerCase();
            return e.name.toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(employeesControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          ListToolbar(
            controller: searchController,
            hintText: 'Search employees...',
            // Filtering is live via the controller listener; nothing to submit.
            onSearch: () {},
            onTextChanged: (_) {},
          ),
          Expanded(
            child: filteredEmployees.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.value.isEmpty
                              ? 'No employees yet'
                              : 'No employees match "${searchQuery.value}"',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(employeesControllerProvider.notifier)
                        .refresh(),
                    child: ListView.builder(
                      itemCount: filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = filteredEmployees[index];
                        return _EmployeeListTile(employee: employee);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: canAdd ? () => showEmployeeFormDialog(context) : null,
        tooltip: canAdd
            ? 'Add Employee'
            : 'Employee limit reached (${employeeLimit.limit})',
        backgroundColor: canAdd ? null : theme.disabledColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmployeeListTile extends StatelessWidget {
  const _EmployeeListTile({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    return AppListRow(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: scheme.primaryContainer,
        child: Icon(Icons.badge, color: scheme.onPrimaryContainer),
      ),
      title: Text(employee.name),
      subtitle: Text(currencyFormat.format(employee.baseSalary)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => EmployeeDetailRoute(id: employee.id).goScoped(context),
    );
  }
}