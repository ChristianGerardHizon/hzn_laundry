// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_payments_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Payment history (newest first) for one organization's subscription.

@ProviderFor(OrganizationPaymentsController)
final organizationPaymentsControllerProvider =
    OrganizationPaymentsControllerFamily._();

/// Payment history (newest first) for one organization's subscription.
final class OrganizationPaymentsControllerProvider
    extends $AsyncNotifierProvider<OrganizationPaymentsController,
        List<SubscriptionPayment>> {
  /// Payment history (newest first) for one organization's subscription.
  OrganizationPaymentsControllerProvider._(
      {required OrganizationPaymentsControllerFamily super.from,
      required String super.argument})
      : super(
          retry: retryUnlessForbidden,
          name: r'organizationPaymentsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$organizationPaymentsControllerHash();

  @override
  String toString() {
    return r'organizationPaymentsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OrganizationPaymentsController create() => OrganizationPaymentsController();

  @override
  bool operator ==(Object other) {
    return other is OrganizationPaymentsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$organizationPaymentsControllerHash() =>
    r'd63801eea5733d8ae93299fd03179885432eb8de';

/// Payment history (newest first) for one organization's subscription.

final class OrganizationPaymentsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            OrganizationPaymentsController,
            AsyncValue<List<SubscriptionPayment>>,
            List<SubscriptionPayment>,
            FutureOr<List<SubscriptionPayment>>,
            String> {
  OrganizationPaymentsControllerFamily._()
      : super(
          retry: retryUnlessForbidden,
          name: r'organizationPaymentsControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Payment history (newest first) for one organization's subscription.

  OrganizationPaymentsControllerProvider call(
    String organizationId,
  ) =>
      OrganizationPaymentsControllerProvider._(
          argument: organizationId, from: this);

  @override
  String toString() => r'organizationPaymentsControllerProvider';
}

/// Payment history (newest first) for one organization's subscription.

abstract class _$OrganizationPaymentsController
    extends $AsyncNotifier<List<SubscriptionPayment>> {
  late final _$args = ref.$arg as String;
  String get organizationId => _$args;

  FutureOr<List<SubscriptionPayment>> build(
    String organizationId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<SubscriptionPayment>>,
        List<SubscriptionPayment>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<SubscriptionPayment>>,
            List<SubscriptionPayment>>,
        AsyncValue<List<SubscriptionPayment>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
