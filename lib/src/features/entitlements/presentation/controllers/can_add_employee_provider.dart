import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entitlement_limit.dart';
import 'entitlement_limit_provider.dart';

part 'can_add_employee_provider.g.dart';

/// Whether the UI may offer "Add Employee" (employee limit not reached).
/// The server enforces the same rule.
@riverpod
bool canAddEmployee(Ref ref) {
  return !ref.watch(entitlementLimitProvider(LimitKey.employees)).isReached;
}
