// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_consumable_recipes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serviceConsumableRecipes)
final serviceConsumableRecipesProvider = ServiceConsumableRecipesFamily._();

final class ServiceConsumableRecipesProvider extends $FunctionalProvider<
        AsyncValue<List<ServiceConsumableRecipe>>,
        List<ServiceConsumableRecipe>,
        FutureOr<List<ServiceConsumableRecipe>>>
    with
        $FutureModifier<List<ServiceConsumableRecipe>>,
        $FutureProvider<List<ServiceConsumableRecipe>> {
  ServiceConsumableRecipesProvider._(
      {required ServiceConsumableRecipesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'serviceConsumableRecipesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serviceConsumableRecipesHash();

  @override
  String toString() {
    return r'serviceConsumableRecipesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ServiceConsumableRecipe>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceConsumableRecipe>> create(Ref ref) {
    final argument = this.argument as String;
    return serviceConsumableRecipes(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceConsumableRecipesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serviceConsumableRecipesHash() =>
    r'1c8f578e229b923c637d4fc3cf638ab9f17b23c3';

final class ServiceConsumableRecipesFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<ServiceConsumableRecipe>>,
            String> {
  ServiceConsumableRecipesFamily._()
      : super(
          retry: null,
          name: r'serviceConsumableRecipesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ServiceConsumableRecipesProvider call(
    String serviceId,
  ) =>
      ServiceConsumableRecipesProvider._(argument: serviceId, from: this);

  @override
  String toString() => r'serviceConsumableRecipesProvider';
}
