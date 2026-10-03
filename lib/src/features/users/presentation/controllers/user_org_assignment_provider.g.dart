// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_org_assignment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Assignment for [userId] in the currently selected organization.
///
/// Role comes from `organizationMemberships`; branch from the users record.

@ProviderFor(userOrgAssignment)
final userOrgAssignmentProvider = UserOrgAssignmentFamily._();

/// Assignment for [userId] in the currently selected organization.
///
/// Role comes from `organizationMemberships`; branch from the users record.

final class UserOrgAssignmentProvider extends $FunctionalProvider<
        AsyncValue<UserOrgAssignment>,
        UserOrgAssignment,
        FutureOr<UserOrgAssignment>>
    with
        $FutureModifier<UserOrgAssignment>,
        $FutureProvider<UserOrgAssignment> {
  /// Assignment for [userId] in the currently selected organization.
  ///
  /// Role comes from `organizationMemberships`; branch from the users record.
  UserOrgAssignmentProvider._(
      {required UserOrgAssignmentFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'userOrgAssignmentProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userOrgAssignmentHash();

  @override
  String toString() {
    return r'userOrgAssignmentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserOrgAssignment> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserOrgAssignment> create(Ref ref) {
    final argument = this.argument as String;
    return userOrgAssignment(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserOrgAssignmentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userOrgAssignmentHash() => r'9e5c191c0827c608aabcc9676b876faecfcded60';

/// Assignment for [userId] in the currently selected organization.
///
/// Role comes from `organizationMemberships`; branch from the users record.

final class UserOrgAssignmentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserOrgAssignment>, String> {
  UserOrgAssignmentFamily._()
      : super(
          retry: null,
          name: r'userOrgAssignmentProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Assignment for [userId] in the currently selected organization.
  ///
  /// Role comes from `organizationMemberships`; branch from the users record.

  UserOrgAssignmentProvider call(
    String userId,
  ) =>
      UserOrgAssignmentProvider._(argument: userId, from: this);

  @override
  String toString() => r'userOrgAssignmentProvider';
}
