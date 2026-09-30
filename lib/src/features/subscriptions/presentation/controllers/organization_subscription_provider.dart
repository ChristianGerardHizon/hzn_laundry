import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/provider_retry.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../domain/organization_subscription.dart';

part 'organization_subscription_provider.g.dart';

/// Single organization subscription by organization ID.
@Riverpod(retry: retryUnlessForbidden)
Future<OrganizationSubscription?> organizationSubscription(
  Ref ref,
  String organizationId,
) async {
  final result = await ref
      .read(subscriptionRepositoryProvider)
      .getOrgSubscription(organizationId);
  return result.fold(
    (failure) => throw failure,
    (subscription) => subscription,
  );
}
