// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine_usage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that checks if a machine is currently in use.
///
/// A machine is considered "in use" if it's assigned to any saleServiceItem
/// whose parent sale has orderStatus == "processing".

@ProviderFor(machineUsage)
final machineUsageProvider = MachineUsageFamily._();

/// Provider that checks if a machine is currently in use.
///
/// A machine is considered "in use" if it's assigned to any saleServiceItem
/// whose parent sale has orderStatus == "processing".

final class MachineUsageProvider extends $FunctionalProvider<
        AsyncValue<MachineUsageInfo>,
        MachineUsageInfo,
        FutureOr<MachineUsageInfo>>
    with $FutureModifier<MachineUsageInfo>, $FutureProvider<MachineUsageInfo> {
  /// Provider that checks if a machine is currently in use.
  ///
  /// A machine is considered "in use" if it's assigned to any saleServiceItem
  /// whose parent sale has orderStatus == "processing".
  MachineUsageProvider._(
      {required MachineUsageFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'machineUsageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$machineUsageHash();

  @override
  String toString() {
    return r'machineUsageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MachineUsageInfo> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MachineUsageInfo> create(Ref ref) {
    final argument = this.argument as String;
    return machineUsage(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MachineUsageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$machineUsageHash() => r'9759bee312335077a575bfd0eee9109f0a10ce25';

/// Provider that checks if a machine is currently in use.
///
/// A machine is considered "in use" if it's assigned to any saleServiceItem
/// whose parent sale has orderStatus == "processing".

final class MachineUsageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MachineUsageInfo>, String> {
  MachineUsageFamily._()
      : super(
          retry: null,
          name: r'machineUsageProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider that checks if a machine is currently in use.
  ///
  /// A machine is considered "in use" if it's assigned to any saleServiceItem
  /// whose parent sale has orderStatus == "processing".

  MachineUsageProvider call(
    String machineId,
  ) =>
      MachineUsageProvider._(argument: machineId, from: this);

  @override
  String toString() => r'machineUsageProvider';
}
