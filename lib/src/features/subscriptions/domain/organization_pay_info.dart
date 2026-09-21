import 'package:dart_mappable/dart_mappable.dart';

import 'organization_subscription.dart';
import 'platform_billing_settings.dart';
import 'subscription_payment.dart';

part 'organization_pay_info.mapper.dart';

/// Pay-screen payload: subscription, billing settings, and latest proof.
@MappableClass()
class OrganizationPayInfo with OrganizationPayInfoMappable {
  const OrganizationPayInfo({
    this.subscription,
    required this.settings,
    this.latestPayment,
    required this.organizationName,
  });

  final OrganizationSubscription? subscription;
  final PlatformBillingSettings settings;
  final SubscriptionPayment? latestPayment;
  final String organizationName;
}
