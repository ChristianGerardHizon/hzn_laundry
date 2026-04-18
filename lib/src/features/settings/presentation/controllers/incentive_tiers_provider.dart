import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/incentive_tier_repository.dart';
import '../../domain/incentive_tier.dart';

part 'incentive_tiers_provider.g.dart';

/// Cached list of incentive tiers for a branch. Tiers change rarely, so
/// keep them alive across screen rebuilds to avoid refetching.
@Riverpod(keepAlive: true)
Future<List<IncentiveTier>> incentiveTiersForBranch(
  Ref ref,
  String branchId,
) async {
  if (branchId.isEmpty) return const [];
  final repository = ref.watch(incentiveTierRepositoryProvider);
  final result = await repository.fetchForBranch(branchId);
  return result.fold((_) => const <IncentiveTier>[], (list) => list);
}
