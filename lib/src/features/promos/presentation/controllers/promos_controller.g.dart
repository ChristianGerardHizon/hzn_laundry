// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promos_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the list of promos.

@ProviderFor(PromosController)
final promosControllerProvider = PromosControllerProvider._();

/// Controller for managing the list of promos.
final class PromosControllerProvider
    extends $AsyncNotifierProvider<PromosController, List<Promo>> {
  /// Controller for managing the list of promos.
  PromosControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'promosControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$promosControllerHash();

  @$internal
  @override
  PromosController create() => PromosController();
}

String _$promosControllerHash() => r'3f484c23142bfe60840490e74816be68b89a5429';

/// Controller for managing the list of promos.

abstract class _$PromosController extends $AsyncNotifier<List<Promo>> {
  FutureOr<List<Promo>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Promo>>, List<Promo>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Promo>>, List<Promo>>,
        AsyncValue<List<Promo>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
