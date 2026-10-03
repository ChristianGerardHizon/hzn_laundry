// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_rates_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Delivery rates of one branch (default first).

@ProviderFor(DeliveryRatesController)
final deliveryRatesControllerProvider = DeliveryRatesControllerFamily._();

/// Delivery rates of one branch (default first).
final class DeliveryRatesControllerProvider extends $AsyncNotifierProvider<
    DeliveryRatesController, List<DeliveryRate>> {
  /// Delivery rates of one branch (default first).
  DeliveryRatesControllerProvider._(
      {required DeliveryRatesControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'deliveryRatesControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deliveryRatesControllerHash();

  @override
  String toString() {
    return r'deliveryRatesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeliveryRatesController create() => DeliveryRatesController();

  @override
  bool operator ==(Object other) {
    return other is DeliveryRatesControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deliveryRatesControllerHash() =>
    r'94f2c64516144f6dd3de590a60b6dcfc2800e77e';

/// Delivery rates of one branch (default first).

final class DeliveryRatesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            DeliveryRatesController,
            AsyncValue<List<DeliveryRate>>,
            List<DeliveryRate>,
            FutureOr<List<DeliveryRate>>,
            String> {
  DeliveryRatesControllerFamily._()
      : super(
          retry: null,
          name: r'deliveryRatesControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Delivery rates of one branch (default first).

  DeliveryRatesControllerProvider call(
    String branchId,
  ) =>
      DeliveryRatesControllerProvider._(argument: branchId, from: this);

  @override
  String toString() => r'deliveryRatesControllerProvider';
}

/// Delivery rates of one branch (default first).

abstract class _$DeliveryRatesController
    extends $AsyncNotifier<List<DeliveryRate>> {
  late final _$args = ref.$arg as String;
  String get branchId => _$args;

  FutureOr<List<DeliveryRate>> build(
    String branchId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<DeliveryRate>>, List<DeliveryRate>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<DeliveryRate>>, List<DeliveryRate>>,
        AsyncValue<List<DeliveryRate>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
