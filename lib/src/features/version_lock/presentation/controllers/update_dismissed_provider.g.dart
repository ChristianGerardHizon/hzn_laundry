// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_dismissed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks whether the optional update dialog has been dismissed this session.
///
/// Prevents the dialog from showing again after the user taps "Later".

@ProviderFor(UpdateDismissed)
final updateDismissedProvider = UpdateDismissedProvider._();

/// Tracks whether the optional update dialog has been dismissed this session.
///
/// Prevents the dialog from showing again after the user taps "Later".
final class UpdateDismissedProvider
    extends $NotifierProvider<UpdateDismissed, bool> {
  /// Tracks whether the optional update dialog has been dismissed this session.
  ///
  /// Prevents the dialog from showing again after the user taps "Later".
  UpdateDismissedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateDismissedProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateDismissedHash();

  @$internal
  @override
  UpdateDismissed create() => UpdateDismissed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$updateDismissedHash() => r'e330a94ac616217436fbab282940014837e06c2f';

/// Tracks whether the optional update dialog has been dismissed this session.
///
/// Prevents the dialog from showing again after the user taps "Later".

abstract class _$UpdateDismissed extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
