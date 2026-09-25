import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../users/data/repositories/user_repository.dart';
import '../../data/repositories/activity_log_repository.dart';
import '../../domain/activity_log.dart';
import '../utils/activity_log_actor_resolver.dart';

part 'activity_log_provider.g.dart';

/// Provider for a single activity log by ID.
@riverpod
Future<ActivityLog?> activityLog(Ref ref, String id) async {
  final repository = ref.watch(activityLogRepositoryProvider);
  final result = await repository.fetchById(id);

  return await result.fold(
    (failure) async => null,
    (log) => resolveActivityActorName(
      log: log,
      userRepository: ref.read(userRepositoryProvider),
    ),
  );
}
