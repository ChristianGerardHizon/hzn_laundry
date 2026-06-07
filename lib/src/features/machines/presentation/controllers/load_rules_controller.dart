import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/load_rule_repository.dart';
import '../../domain/load_rule.dart';

part 'load_rules_controller.g.dart';

/// Controller for managing the load rules of a single machine.
///
/// Keyed by [machineId] so each machine's rules are tracked independently.
@riverpod
class LoadRulesController extends _$LoadRulesController {
  LoadRuleRepository get _repository => ref.read(loadRuleRepositoryProvider);

  @override
  Future<List<LoadRule>> build(String machineId) async {
    final result = await _repository.fetchForMachine(machineId);
    return result.fold(
      (failure) => throw failure,
      (rules) => rules,
    );
  }

  /// Refreshes the load rule list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    final result = await _repository.fetchForMachine(machineId);
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (rules) => AsyncData(rules),
    );
  }

  /// Creates a new load rule, then refreshes to keep tiers sorted by weight.
  Future<bool> createRule(LoadRule rule) async {
    final result = await _repository.create(rule);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }

  /// Updates an existing load rule, then refreshes to keep tiers sorted.
  Future<bool> updateRule(LoadRule rule) async {
    final result = await _repository.update(rule);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }

  /// Soft deletes a load rule.
  Future<bool> deleteRule(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        final current = state.value ?? [];
        state = AsyncData(current.where((r) => r.id != id).toList());
        return true;
      },
    );
  }
}
