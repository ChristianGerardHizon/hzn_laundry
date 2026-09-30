import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/provider_retry.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../domain/subscription_payment.dart';

part 'organization_payments_controller.g.dart';

/// Payment history (newest first) for one organization's subscription.
@Riverpod(retry: retryUnlessForbidden)
class OrganizationPaymentsController extends _$OrganizationPaymentsController {
  @override
  Future<List<SubscriptionPayment>> build(String organizationId) async {
    final result = await ref
        .read(subscriptionRepositoryProvider)
        .listOrgPayments(organizationId);
    return result.fold(
      (failure) => throw failure,
      (payments) => payments,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } catch (_) {
      // Error state is surfaced by the provider; refresh must not throw.
    }
  }
}
