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

/// The printer selected on this device, if it exists and is enabled.

@ProviderFor(selectedPrinter)
final selectedPrinterProvider = SelectedPrinterProvider._();

/// The printer selected on this device, if it exists and is enabled.

final class SelectedPrinterProvider extends $FunctionalProvider<
        AsyncValue<PrinterConfig?>, PrinterConfig?, FutureOr<PrinterConfig?>>
    with $FutureModifier<PrinterConfig?>, $FutureProvider<PrinterConfig?> {
  /// The printer selected on this device, if it exists and is enabled.
  SelectedPrinterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedPrinterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedPrinterHash();

  @$internal
  @override
  $FutureProviderElement<PrinterConfig?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PrinterConfig?> create(Ref ref) {
    return selectedPrinter(ref);
  }
}

String _$selectedPrinterHash() => r'0f2361cae31961b30b9e1d827e6a6fa9cb2c2cce';
