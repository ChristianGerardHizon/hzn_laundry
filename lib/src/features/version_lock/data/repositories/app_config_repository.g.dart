// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [AppConfigRepository] instance.

@ProviderFor(appConfigRepository)
final appConfigRepositoryProvider = AppConfigRepositoryProvider._();

/// Provides the [AppConfigRepository] instance.

final class AppConfigRepositoryProvider extends $FunctionalProvider<
    AppConfigRepository,
    AppConfigRepository,
    AppConfigRepository> with $Provider<AppConfigRepository> {
  /// Provides the [AppConfigRepository] instance.
  AppConfigRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appConfigRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppConfigRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppConfigRepository create(Ref ref) {
    return appConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfigRepository>(value),
    );
  }
}

String _$appConfigRepositoryHash() =>
    r'b51313d5775aab964669b4b2e7f32172b7435ebc';
