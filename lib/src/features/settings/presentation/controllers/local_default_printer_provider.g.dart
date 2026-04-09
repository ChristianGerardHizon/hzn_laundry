// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_default_printer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to get/set the locally-configured default printer ID.
///
/// This allows each device to override the server-set default printer
/// with a local preference. If no local default is set, the server
/// default is used as fallback.

@ProviderFor(LocalDefaultPrinterId)
final localDefaultPrinterIdProvider = LocalDefaultPrinterIdProvider._();

/// Provider to get/set the locally-configured default printer ID.
///
/// This allows each device to override the server-set default printer
/// with a local preference. If no local default is set, the server
/// default is used as fallback.
final class LocalDefaultPrinterIdProvider
    extends $AsyncNotifierProvider<LocalDefaultPrinterId, String?> {
  /// Provider to get/set the locally-configured default printer ID.
  ///
  /// This allows each device to override the server-set default printer
  /// with a local preference. If no local default is set, the server
  /// default is used as fallback.
  LocalDefaultPrinterIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localDefaultPrinterIdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localDefaultPrinterIdHash();

  @$internal
  @override
  LocalDefaultPrinterId create() => LocalDefaultPrinterId();
}

String _$localDefaultPrinterIdHash() =>
    r'7c62640c4aead9fc4bbf5a75d738d37749935032';

/// Provider to get/set the locally-configured default printer ID.
///
/// This allows each device to override the server-set default printer
/// with a local preference. If no local default is set, the server
/// default is used as fallback.

abstract class _$LocalDefaultPrinterId extends $AsyncNotifier<String?> {
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
