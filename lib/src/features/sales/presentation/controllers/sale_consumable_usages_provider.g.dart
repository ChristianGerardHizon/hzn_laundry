// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_consumable_usages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(saleConsumableUsages)
final saleConsumableUsagesProvider = SaleConsumableUsagesFamily._();

final class SaleConsumableUsagesProvider extends $FunctionalProvider<
        AsyncValue<List<SaleConsumableUsage>>,
        List<SaleConsumableUsage>,
        FutureOr<List<SaleConsumableUsage>>>
    with
        $FutureModifier<List<SaleConsumableUsage>>,
        $FutureProvider<List<SaleConsumableUsage>> {
  SaleConsumableUsagesProvider._(
      {required SaleConsumableUsagesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'saleConsumableUsagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$saleConsumableUsagesHash();

  @override
  String toString() {
    return r'saleConsumableUsagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SaleConsumableUsage>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<SaleConsumableUsage>> create(Ref ref) {
    final argument = this.argument as String;
    return saleConsumableUsages(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleConsumableUsagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleConsumableUsagesHash() =>
    r'61808cd020955cf8a09e2863b7e5fe9b4aa6156a';

final class SaleConsumableUsagesFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<SaleConsumableUsage>>, String> {
  SaleConsumableUsagesFamily._()
      : super(
          retry: null,
          name: r'saleConsumableUsagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  SaleConsumableUsagesProvider call(
    String saleId,
  ) =>
      SaleConsumableUsagesProvider._(argument: saleId, from: this);

  @override
  String toString() => r'saleConsumableUsagesProvider';
}
