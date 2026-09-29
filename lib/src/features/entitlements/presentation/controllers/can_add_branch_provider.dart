import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../domain/entitlement_limit.dart';
import '../../domain/feature_key.dart';
import 'entitlement_limit_provider.dart';
import 'feature_enabled_provider.dart';

part 'can_add_branch_provider.g.dart';

/// Whether the UI may offer "Add Branch".
///
/// Without [FeatureKey.multiBranch] an organization is limited to the branch
/// it already has (the first branch is always allowed). Existing branches are
/// never removed. The package / Super Admin branch limit also applies. The
/// server enforces the same rules.
@riverpod
bool canAddBranch(Ref ref) {
  if (ref.watch(entitlementLimitProvider(LimitKey.branches)).isReached) {
    return false;
  }
  if (ref.watch(featureEnabledProvider(FeatureKey.multiBranch))) return true;
  final branches = ref.watch(branchesControllerProvider).value;
  return branches == null || branches.isEmpty;
}
