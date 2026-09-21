import 'package:dart_mappable/dart_mappable.dart';

import '../../domain/organization_pay_info.dart';
import 'organization_subscription_dto.dart';
import 'platform_billing_settings_dto.dart';
import 'subscription_payment_dto.dart';

part 'organization_pay_info_dto.mapper.dart';

@MappableClass()
class OrganizationPayInfoDto with OrganizationPayInfoDtoMappable {
  const OrganizationPayInfoDto({
    this.subscription,
    required this.settings,
    this.latestPayment,
    this.organizationName = '',
  });

  final OrganizationSubscriptionDto? subscription;
  final PlatformBillingSettingsDto settings;
  final SubscriptionPaymentDto? latestPayment;
  final String organizationName;

  factory OrganizationPayInfoDto.fromJson(Map<String, dynamic> json) {
    final subscriptionJson = json['subscription'];
    final settingsJson = json['settings'];
    final paymentJson = json['latestPayment'];

    return OrganizationPayInfoDto(
      subscription: subscriptionJson is Map<String, dynamic>
          ? OrganizationSubscriptionDto.fromJson(subscriptionJson)
          : null,
      settings: settingsJson is Map<String, dynamic>
          ? PlatformBillingSettingsDto.fromJson(settingsJson)
          : const PlatformBillingSettingsDto(id: ''),
      latestPayment: paymentJson is Map<String, dynamic>
          ? SubscriptionPaymentDto.fromJson(paymentJson)
          : null,
      organizationName: json['organizationName'] as String? ?? '',
    );
  }

  OrganizationPayInfo toEntity({String? baseUrl}) {
    return OrganizationPayInfo(
      subscription: subscription?.toEntity(),
      settings: settings.toEntity(baseUrl: baseUrl),
      latestPayment: latestPayment?.toEntity(baseUrl: baseUrl),
      organizationName: organizationName,
    );
  }
}
