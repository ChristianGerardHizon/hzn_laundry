// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Platform-wide billing settings (QRPH, grace days, reminders).

@ProviderFor(BillingSettingsController)
final billingSettingsControllerProvider = BillingSettingsControllerProvider._();

/// Platform-wide billing settings (QRPH, grace days, reminders).
final class BillingSettingsControllerProvider extends $AsyncNotifierProvider<
    BillingSettingsController, PlatformBillingSettings> {
  /// Platform-wide billing settings (QRPH, grace days, reminders).
  BillingSettingsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'billingSettingsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$billingSettingsControllerHash();

  @$internal
  @override
  BillingSettingsController create() => BillingSettingsController();
}

String _$billingSettingsControllerHash() =>
    r'98c9c1a1f2c39bd07d8b6c9098a78fdba279d3c0';

/// Platform-wide billing settings (QRPH, grace days, reminders).

abstract class _$BillingSettingsController
    extends $AsyncNotifier<PlatformBillingSettings> {
  FutureOr<PlatformBillingSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<PlatformBillingSettings>, PlatformBillingSettings>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<PlatformBillingSettings>,
            PlatformBillingSettings>,
        AsyncValue<PlatformBillingSettings>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
