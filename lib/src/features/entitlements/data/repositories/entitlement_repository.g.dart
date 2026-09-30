// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(entitlementRepository)
final entitlementRepositoryProvider = EntitlementRepositoryProvider._();

final class EntitlementRepositoryProvider extends $FunctionalProvider<
    EntitlementRepository,
    EntitlementRepository,
    EntitlementRepository> with $Provider<EntitlementRepository> {
  EntitlementRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'entitlementRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entitlementRepositoryHash();

  @$internal
  @override
  $ProviderElement<EntitlementRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EntitlementRepository create(Ref ref) {
    return entitlementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntitlementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntitlementRepository>(value),
    );
  }
}

String _$entitlementRepositoryHash() =>
    r'287577387ff0bdea28b6e144e26e248a03c8fb23';
