// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_permissions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the current user's role (resolved from auth -> user -> role chain).

@ProviderFor(currentUserRole)
final currentUserRoleProvider = CurrentUserRoleProvider._();

/// Provides the current user's role (resolved from auth -> user -> role chain).

final class CurrentUserRoleProvider extends $FunctionalProvider<
        AsyncValue<UserRole?>, UserRole?, FutureOr<UserRole?>>
    with $FutureModifier<UserRole?>, $FutureProvider<UserRole?> {
  /// Provides the current user's role (resolved from auth -> user -> role chain).
  CurrentUserRoleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentUserRoleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentUserRoleHash();

  @$internal
  @override
  $FutureProviderElement<UserRole?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserRole?> create(Ref ref) {
    return currentUserRole(ref);
  }
}

String _$currentUserRoleHash() => r'88f6fea9ed540eef10db79bef4a7107014ad3100';
