import '../../../users/data/repositories/user_repository.dart';
import '../../domain/activity_log.dart';

/// Fills [ActivityLog.userName] for logs that have a [userId] but no name
/// (e.g. expand missed). Never puts raw IDs into [userName].
Future<List<ActivityLog>> resolveActivityActorNames({
  required List<ActivityLog> logs,
  required UserRepository userRepository,
}) async {
  final missingIds = logs
      .where(
        (log) =>
            (log.userName == null || log.userName!.trim().isEmpty) &&
            log.userId != null &&
            log.userId!.isNotEmpty,
      )
      .map((log) => log.userId!)
      .toSet()
      .toList();

  if (missingIds.isEmpty) return logs;

  final result = await userRepository.fetchNamesByIds(missingIds);
  return result.fold(
    (_) => logs,
    (names) {
      if (names.isEmpty) return logs;
      return [
        for (final log in logs)
          if ((log.userName == null || log.userName!.trim().isEmpty) &&
              log.userId != null &&
              names[log.userId!] != null &&
              names[log.userId!]!.isNotEmpty)
            log.copyWith(userName: names[log.userId!])
          else
            log,
      ];
    },
  );
}

/// Same as [resolveActivityActorNames] for a single log.
Future<ActivityLog> resolveActivityActorName({
  required ActivityLog log,
  required UserRepository userRepository,
}) async {
  final resolved = await resolveActivityActorNames(
    logs: [log],
    userRepository: userRepository,
  );
  return resolved.first;
}
