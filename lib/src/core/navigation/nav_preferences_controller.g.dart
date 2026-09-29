// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_preferences_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and saves the current user's sidebar preferences on this device.
///
/// Stored locally (not on the server) and namespaced by user id so people who
/// share a machine keep separate pins.

@ProviderFor(NavPreferencesController)
final navPreferencesControllerProvider = NavPreferencesControllerProvider._();

/// Loads and saves the current user's sidebar preferences on this device.
///
/// Stored locally (not on the server) and namespaced by user id so people who
/// share a machine keep separate pins.
final class NavPreferencesControllerProvider
    extends $AsyncNotifierProvider<NavPreferencesController, NavPreferences> {
  /// Loads and saves the current user's sidebar preferences on this device.
  ///
  /// Stored locally (not on the server) and namespaced by user id so people who
  /// share a machine keep separate pins.
  NavPreferencesControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'navPreferencesControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$navPreferencesControllerHash();

  @$internal
  @override
  NavPreferencesController create() => NavPreferencesController();
}

String _$navPreferencesControllerHash() =>
    r'59ab85a313b5128acccc9dfb90d92f6156d4d112';

/// Loads and saves the current user's sidebar preferences on this device.
///
/// Stored locally (not on the server) and namespaced by user id so people who
/// share a machine keep separate pins.

abstract class _$NavPreferencesController
    extends $AsyncNotifier<NavPreferences> {
  FutureOr<NavPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<NavPreferences>, NavPreferences>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<NavPreferences>, NavPreferences>,
        AsyncValue<NavPreferences>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
