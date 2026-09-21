import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/subscription_repository.dart';
import '../../domain/organization_pay_info.dart';

part 'organization_pay_info_provider.g.dart';

/// Pay-screen payload for an organization (subscription + QRPH settings).
@riverpod
Future<OrganizationPayInfo> organizationPayInfo(
  Ref ref,
  String organizationId,
) async {
  final result = await ref
      .read(subscriptionRepositoryProvider)
      .getPayInfo(organizationId);
  return result.fold(
    (failure) => throw failure,
    (info) => info,
  );
}
