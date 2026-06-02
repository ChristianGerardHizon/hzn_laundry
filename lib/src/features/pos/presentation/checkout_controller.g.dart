// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CheckoutController)
final checkoutControllerProvider = CheckoutControllerProvider._();

final class CheckoutControllerProvider
    extends $AsyncNotifierProvider<CheckoutController, void> {
  CheckoutControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'checkoutControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$checkoutControllerHash();

  @$internal
  @override
  CheckoutController create() => CheckoutController();
}

String _$checkoutControllerHash() =>
    r'f5dbc62c873bd4d4e3d3f7acc4ed144f76f1058c';

abstract class _$CheckoutController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
