// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to fetch a single printer config by ID.

@ProviderFor(printerConfig)
final printerConfigProvider = PrinterConfigFamily._();

/// Provider to fetch a single printer config by ID.

final class PrinterConfigProvider extends $FunctionalProvider<
        AsyncValue<PrinterConfig?>, PrinterConfig?, FutureOr<PrinterConfig?>>
    with $FutureModifier<PrinterConfig?>, $FutureProvider<PrinterConfig?> {
  /// Provider to fetch a single printer config by ID.
  PrinterConfigProvider._(
      {required PrinterConfigFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'printerConfigProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$printerConfigHash();

  @override
  String toString() {
    return r'printerConfigProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PrinterConfig?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PrinterConfig?> create(Ref ref) {
    final argument = this.argument as String;
    return printerConfig(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PrinterConfigProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$printerConfigHash() => r'97e8ed3d7b784d4f8b9678eaf68a75d1ec3f674c';

/// Provider to fetch a single printer config by ID.

final class PrinterConfigFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PrinterConfig?>, String> {
  PrinterConfigFamily._()
      : super(
          retry: null,
          name: r'printerConfigProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to fetch a single printer config by ID.

  PrinterConfigProvider call(
    String id,
  ) =>
      PrinterConfigProvider._(argument: id, from: this);

  @override
  String toString() => r'printerConfigProvider';
}

/// Provider to fetch the effective default printer configuration.
///
/// Priority: local default (device-specific) > server default.
/// If no local default is set, falls back to the server-configured default.

@ProviderFor(defaultPrinter)
final defaultPrinterProvider = DefaultPrinterProvider._();

/// Provider to fetch the effective default printer configuration.
///
/// Priority: local default (device-specific) > server default.
/// If no local default is set, falls back to the server-configured default.

final class DefaultPrinterProvider extends $FunctionalProvider<
        AsyncValue<PrinterConfig?>, PrinterConfig?, FutureOr<PrinterConfig?>>
    with $FutureModifier<PrinterConfig?>, $FutureProvider<PrinterConfig?> {
  /// Provider to fetch the effective default printer configuration.
  ///
  /// Priority: local default (device-specific) > server default.
  /// If no local default is set, falls back to the server-configured default.
  DefaultPrinterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'defaultPrinterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$defaultPrinterHash();

  @$internal
  @override
  $FutureProviderElement<PrinterConfig?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PrinterConfig?> create(Ref ref) {
    return defaultPrinter(ref);
  }
}

String _$defaultPrinterHash() => r'93d4db920e52d04aa094d434cc0b9d147f36922e';
