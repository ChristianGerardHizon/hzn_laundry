import 'package:dart_mappable/dart_mappable.dart';

part 'platform_billing_settings.mapper.dart';

/// Singleton platform-wide billing settings (QRPH, grace, reminders).
@MappableClass()
class PlatformBillingSettings with PlatformBillingSettingsMappable {
  const PlatformBillingSettings({
    required this.id,
    this.qrphImageUrl,
    this.payeeName = '',
    this.instructions = '',
    this.defaultGraceDays = 7,
    this.reminderDaysBeforeDue = const [3, 0],
  });

  final String id;
  final String? qrphImageUrl;
  final String payeeName;
  final String instructions;
  final int defaultGraceDays;
  final List<int> reminderDaysBeforeDue;
}
