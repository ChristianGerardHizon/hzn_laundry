import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/branch_repository.dart';
import '../../domain/branch.dart';

part 'branch_provider.g.dart';

/// Provider to fetch a single branch by ID.
@Riverpod(keepAlive: true)
Future<Branch?> branch(Ref ref, String id) async {
  if (id.isEmpty) return null;

  final repository = ref.watch(branchRepositoryProvider);
  final result = await repository.fetchOne(id);

  return result.fold(
    (failure) => null,
    (branch) => branch,
  );
}
