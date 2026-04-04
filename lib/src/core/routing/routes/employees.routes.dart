import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/employees/presentation/pages/employee_detail_page.dart';
import '../../../features/employees/presentation/pages/employees_list_page.dart';
import '../../../features/employees/presentation/pages/employees_shell.dart';
import '../../utils/breakpoints.dart';

part 'employees.routes.g.dart';

/// Employees shell route for master-detail layout.
///
/// On tablet: Shows list and detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<EmployeesShellRoute>(
  routes: [
    TypedGoRoute<EmployeesRoute>(
      path: EmployeesRoute.path,
      routes: [
        TypedGoRoute<EmployeeDetailRoute>(path: ':id'),
      ],
    ),
  ],
)
class EmployeesShellRoute extends ShellRouteData {
  const EmployeesShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return EmployeesShell(child: navigator);
  }
}

/// Employees list page route.
class EmployeesRoute extends GoRouteData with $EmployeesRoute {
  const EmployeesRoute();

  static const path = '/employees';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const EmployeesListPage();
  }
}

/// Employee detail page route.
class EmployeeDetailRoute extends GoRouteData with $EmployeeDetailRoute {
  const EmployeeDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EmployeeDetailPage(employeeId: id);
  }
}
