import 'package:dart_mappable/dart_mappable.dart';

part 'service_item_status.mapper.dart';

/// Status of a service item within an order.
///
/// Tracks the completion status of individual service items independently
/// from the overall order status. This enables machine reuse when a service
/// completes while other services in the same order are still running.
@MappableEnum()
enum ServiceItemStatus {
  /// Service has not yet started (default when created).
  pending,

  /// Machine assigned, service is running.
  inProgress,

  /// Service finished, machine released.
  completed;

  /// Database value for this status (uses snake_case).
  String get dbValue => switch (this) {
        ServiceItemStatus.pending => 'pending',
        ServiceItemStatus.inProgress => 'in_progress',
        ServiceItemStatus.completed => 'completed',
      };

  /// User-friendly display name.
  String get displayName => switch (this) {
        ServiceItemStatus.pending => 'Pending',
        ServiceItemStatus.inProgress => 'In Progress',
        ServiceItemStatus.completed => 'Completed',
      };

  /// Parses a database value to a ServiceItemStatus.
  static ServiceItemStatus? fromDbValue(String? value) {
    if (value == null || value.isEmpty) return null;
    return switch (value) {
      'pending' => ServiceItemStatus.pending,
      'in_progress' => ServiceItemStatus.inProgress,
      'completed' => ServiceItemStatus.completed,
      _ => null,
    };
  }
}
