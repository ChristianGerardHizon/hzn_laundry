import 'package:dart_mappable/dart_mappable.dart';

part 'platform_billing_settings.mapper.dart';

/// Singleton platform-wide billing settings (QRPH, grace, warnings, lockout).
@MappableClass()
class PlatformBillingSettings with PlatformBillingSettingsMappable {
  const PlatformBillingSettings({
    required this.id,
    this.qrphImageUrl,
    this.payeeName = '',
    this.instructions = '',
    this.defaultGraceDays = 7,
    this.warningDaysBeforeDue = 7,
    this.enforceWarnings = true,
    this.enforceLockout = true,
    this.reminderDaysBeforeDue = const [3, 0],
  });

  final String id;
  final String? qrphImageUrl;
  final String payeeName;
  final String instructions;

  /// Grace length in days **after** the due date (`periodEnd`).
  final int defaultGraceDays;

  /// Days **before** `periodEnd` to show in-app due-soon warnings.
  final int warningDaysBeforeDue;

  /// When false, skip banners / dialogs / org-picker warning chips.
  final bool enforceWarnings;

  /// When false, skip grace→lock transitions and client lock UI.
  final bool enforceLockout;

  /// Email reminder schedule (days before due); independent of in-app warnings.
  final List<int> reminderDaysBeforeDue;
}
