// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_printer_id_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to get/set the printer selected on this device.

@ProviderFor(SelectedPrinterId)
final selectedPrinterIdProvider = SelectedPrinterIdProvider._();

/// Provider to get/set the printer selected on this device.
final class SelectedPrinterIdProvider
    extends $AsyncNotifierProvider<SelectedPrinterId, String?> {
  /// Provider to get/set the printer selected on this device.
  SelectedPrinterIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedPrinterIdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedPrinterIdHash();

  @$internal
  @override
  SelectedPrinterId create() => SelectedPrinterId();
}

String _$selectedPrinterIdHash() => r'cd16e1927a2c77df19959b6052c110e24e547b46';

/// Provider to get/set the printer selected on this device.

abstract class _$SelectedPrinterId extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<String?>, String?>,
        AsyncValue<String?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
