// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_rule_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the LoadRuleRepository instance.

@ProviderFor(loadRuleRepository)
final loadRuleRepositoryProvider = LoadRuleRepositoryProvider._();

/// Provides the LoadRuleRepository instance.

final class LoadRuleRepositoryProvider extends $FunctionalProvider<
    LoadRuleRepository,
    LoadRuleRepository,
    LoadRuleRepository> with $Provider<LoadRuleRepository> {
  /// Provides the LoadRuleRepository instance.
  LoadRuleRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loadRuleRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loadRuleRepositoryHash();

  @$internal
  @override
  $ProviderElement<LoadRuleRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadRuleRepository create(Ref ref) {
    return loadRuleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadRuleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadRuleRepository>(value),
    );
  }
}

String _$loadRuleRepositoryHash() =>
    r'a28b968098ccc53dcdd378fc41e1ff4c84d6608c';
