import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/billing_interval_unit.dart';
import '../../domain/organization_pay_info.dart';
import '../../domain/organization_subscription.dart';
import '../../domain/platform_billing_settings.dart';
import '../../domain/subscription_package.dart';
import '../../domain/subscription_payment.dart';
import '../dto/organization_pay_info_dto.dart';
import '../dto/organization_subscription_dto.dart';
import '../dto/platform_billing_settings_dto.dart';
import '../dto/subscription_package_dto.dart';
import '../dto/subscription_payment_dto.dart';

part 'subscription_repository.g.dart';

abstract class SubscriptionRepository {
  FutureEither<List<SubscriptionPackage>> listPackages({
    bool premadeOnly = false,
  });

  FutureEither<SubscriptionPackage> createPackage({
    required String name,
    String description,
    required num price,
    required int intervalCount,
    required BillingIntervalUnit intervalUnit,
    required bool isPremade,
    String? organizationId,
  });

  FutureEither<SubscriptionPackage> updatePackage(
    String id, {
    String? name,
    String? description,
    num? price,
    int? intervalCount,
    BillingIntervalUnit? intervalUnit,
    bool? isPremade,
    bool? isActive,
    String? organizationId,
  });

  FutureEither<void> softDeletePackage(String id);

  FutureEither<OrganizationSubscription> assignSubscription(
    String organizationId, {
    String? packageId,
    Map<String, dynamic>? customPackage,
    DateTime? periodStart,
    DateTime? periodEnd,
  });

  FutureEither<OrganizationSubscription?> getOrgSubscription(
    String organizationId,
  );

  FutureEither<OrganizationPayInfo> getPayInfo(String organizationId);

  FutureEither<SubscriptionPayment> submitPayment(
    String organizationId, {
    String? note,
    required http.MultipartFile proofImage,
  });

  FutureEither<List<SubscriptionPayment>> listPendingPayments();

  FutureEither<SubscriptionPayment> reviewPayment(
    String paymentId, {
    required bool approved,
    String? adminNote,
  });

  FutureEither<OrganizationSubscription> unlockOrganization(
    String organizationId, {
    required DateTime until,
    String? note,
  });

  FutureEither<PlatformBillingSettings> getBillingSettings();

  FutureEither<PlatformBillingSettings> updateBillingSettings({
    String? payeeName,
    String? instructions,
    int? defaultGraceDays,
    List<int>? reminderDaysBeforeDue,
    http.MultipartFile? qrphImage,
  });
}

@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) {
  return SubscriptionRepositoryImpl(ref.watch(pocketbaseProvider));
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._pb);

  final PocketBase _pb;

  RecordService get _packages =>
      _pb.collection(PocketBaseCollections.subscriptionPackages);

  RecordService get _billingSettings =>
      _pb.collection(PocketBaseCollections.platformBillingSettings);

  @override
  FutureEither<List<SubscriptionPackage>> listPackages({
    bool premadeOnly = false,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final filter = premadeOnly
            ? 'isDeleted = false && isPremade = true'
            : 'isDeleted = false';
        final records = await _packages.getFullList(
          filter: filter,
          sort: 'name',
        );
        return records
            .map((r) => SubscriptionPackageDto.fromRecord(r).toEntity())
            .toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<SubscriptionPackage> createPackage({
    required String name,
    String description = '',
    required num price,
    required int intervalCount,
    required BillingIntervalUnit intervalUnit,
    required bool isPremade,
    String? organizationId,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final response = await _pb.send(
          '/api/super-admin/subscription-packages',
          method: 'POST',
          body: {
            'name': name,
            'description': description,
            'price': price,
            'intervalCount': intervalCount,
            'intervalUnit': intervalUnit.name,
            'isPremade': isPremade,
            if (organizationId != null && organizationId.isNotEmpty)
              'organizationId': organizationId,
          },
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid subscription package create response',
            null,
            'invalid_subscription_package_response',
          );
        }
        return SubscriptionPackageDto.fromJson(response).toEntity();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<SubscriptionPackage> updatePackage(
    String id, {
    String? name,
    String? description,
    num? price,
    int? intervalCount,
    BillingIntervalUnit? intervalUnit,
    bool? isPremade,
    bool? isActive,
    String? organizationId,
  }) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Package ID cannot be empty',
            null,
            'invalid_subscription_package_id',
          );
        }

        final body = <String, dynamic>{};
        if (name != null) body['name'] = name;
        if (description != null) body['description'] = description;
        if (price != null) body['price'] = price;
        if (intervalCount != null) body['intervalCount'] = intervalCount;
        if (intervalUnit != null) body['intervalUnit'] = intervalUnit.name;
        if (isPremade != null) body['isPremade'] = isPremade;
        if (isActive != null) body['isActive'] = isActive;
        if (organizationId != null) body['organizationId'] = organizationId;

        final response = await _pb.send(
          '/api/super-admin/subscription-packages/$id',
          method: 'PATCH',
          body: body,
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid subscription package update response',
            null,
            'invalid_subscription_package_response',
          );
        }
        return SubscriptionPackageDto.fromJson(response).toEntity();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> softDeletePackage(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Package ID cannot be empty',
            null,
            'invalid_subscription_package_id',
          );
        }
        await _pb.send(
          '/api/super-admin/subscription-packages/$id',
          method: 'PATCH',
          body: {'isDeleted': true, 'isActive': false},
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrganizationSubscription> assignSubscription(
    String organizationId, {
    String? packageId,
    Map<String, dynamic>? customPackage,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    return TaskEither.tryCatch(
      () async {
        if (organizationId.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        final body = <String, dynamic>{};
        if (packageId != null && packageId.isNotEmpty) {
          body['packageId'] = packageId;
        }
        if (customPackage != null) {
          body['customPackage'] = customPackage;
        }
        if (periodStart != null) {
          body['periodStart'] = periodStart.toUtc().toIso8601String();
        }
        if (periodEnd != null) {
          body['periodEnd'] = periodEnd.toUtc().toIso8601String();
        }

        final response = await _pb.send(
          '/api/organizations/$organizationId/subscription',
          method: 'POST',
          body: body,
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid assign subscription response',
            null,
            'invalid_organization_subscription_response',
          );
        }
        final subJson = response['subscription'];
        if (subJson is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid assign subscription response',
            null,
            'invalid_organization_subscription_response',
          );
        }
        return OrganizationSubscriptionDto.fromJson(subJson).toEntity();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrganizationSubscription?> getOrgSubscription(
    String organizationId,
  ) async {
    return TaskEither.tryCatch(
      () async {
        if (organizationId.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        final response = await _pb.send(
          '/api/organizations/$organizationId/subscription',
          method: 'GET',
        );
        if (response == null) return null;
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid organization subscription response',
            null,
            'invalid_organization_subscription_response',
          );
        }
        final subJson = response['subscription'];
        if (subJson == null) return null;
        if (subJson is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid organization subscription response',
            null,
            'invalid_organization_subscription_response',
          );
        }
        if ((subJson['id'] as String?)?.isEmpty ?? true) return null;
        return OrganizationSubscriptionDto.fromJson(subJson).toEntity();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrganizationPayInfo> getPayInfo(String organizationId) async {
    return TaskEither.tryCatch(
      () async {
        if (organizationId.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        final response = await _pb.send(
          '/api/organizations/$organizationId/subscription/pay-info',
          method: 'GET',
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid pay-info response',
            null,
            'invalid_pay_info_response',
          );
        }
        return OrganizationPayInfoDto.fromJson(response)
            .toEntity(baseUrl: _pb.baseURL);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<SubscriptionPayment> submitPayment(
    String organizationId, {
    String? note,
    required http.MultipartFile proofImage,
  }) async {
    return TaskEither.tryCatch(
      () async {
        if (organizationId.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        final response = await _pb.send(
          '/api/organizations/$organizationId/subscription/payments',
          method: 'POST',
          body: {
            if (note != null) 'note': note,
          },
          files: [proofImage],
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid subscription payment submit response',
            null,
            'invalid_subscription_payment_response',
          );
        }
        return SubscriptionPaymentDto.fromJson(response)
            .toEntity(baseUrl: _pb.baseURL);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<SubscriptionPayment>> listPendingPayments() async {
    return TaskEither.tryCatch(
      () async {
        final response = await _pb.send(
          '/api/super-admin/subscription-payments',
          method: 'GET',
          query: {'status': 'pending'},
        );

        final List<dynamic> items;
        if (response is List) {
          items = response;
        } else if (response is Map<String, dynamic>) {
          final nested = response['items'] ?? response['payments'];
          items = nested is List ? nested : const [];
        } else {
          throw const DataFailure(
            'Invalid pending payments response',
            null,
            'invalid_pending_payments_response',
          );
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map(
              (json) => SubscriptionPaymentDto.fromJson(json)
                  .toEntity(baseUrl: _pb.baseURL),
            )
            .toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<SubscriptionPayment> reviewPayment(
    String paymentId, {
    required bool approved,
    String? adminNote,
  }) async {
    return TaskEither.tryCatch(
      () async {
        if (paymentId.isEmpty) {
          throw const DataFailure(
            'Payment ID cannot be empty',
            null,
            'invalid_subscription_payment_id',
          );
        }

        final response = await _pb.send(
          '/api/super-admin/subscription-payments/$paymentId/review',
          method: 'POST',
          body: {
            'approved': approved,
            if (adminNote != null) 'adminNote': adminNote,
          },
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid payment review response',
            null,
            'invalid_subscription_payment_response',
          );
        }
        final paymentJson = response['payment'] ?? response;
        if (paymentJson is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid payment review response',
            null,
            'invalid_subscription_payment_response',
          );
        }
        return SubscriptionPaymentDto.fromJson(paymentJson)
            .toEntity(baseUrl: _pb.baseURL);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<OrganizationSubscription> unlockOrganization(
    String organizationId, {
    required DateTime until,
    String? note,
  }) async {
    return TaskEither.tryCatch(
      () async {
        if (organizationId.isEmpty) {
          throw const DataFailure(
            'Organization ID cannot be empty',
            null,
            'invalid_organization_id',
          );
        }

        final response = await _pb.send(
          '/api/super-admin/organizations/$organizationId/unlock',
          method: 'POST',
          body: {
            'until': until.toUtc().toIso8601String(),
            if (note != null) 'note': note,
          },
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid unlock organization response',
            null,
            'invalid_organization_subscription_response',
          );
        }
        final subJson = response['subscription'] ?? response;
        if (subJson is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid unlock organization response',
            null,
            'invalid_organization_subscription_response',
          );
        }
        return OrganizationSubscriptionDto.fromJson(subJson).toEntity();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<PlatformBillingSettings> getBillingSettings() async {
    return TaskEither.tryCatch(
      () async {
        final response = await _pb.send(
          '/api/super-admin/billing-settings',
          method: 'GET',
        );
        if (response is Map<String, dynamic>) {
          return PlatformBillingSettingsDto.fromJson(response)
              .toEntity(baseUrl: _pb.baseURL);
        }

        // Fallback: singleton collection row (listRule allows auth).
        final records = await _billingSettings.getList(page: 1, perPage: 1);
        if (records.items.isEmpty) {
          throw const DataFailure(
            'Billing settings not found',
            null,
            'billing_settings_not_found',
          );
        }
        return PlatformBillingSettingsDto.fromRecord(records.items.first)
            .toEntity(baseUrl: _pb.baseURL);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<PlatformBillingSettings> updateBillingSettings({
    String? payeeName,
    String? instructions,
    int? defaultGraceDays,
    List<int>? reminderDaysBeforeDue,
    http.MultipartFile? qrphImage,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{};
        if (payeeName != null) body['payeeName'] = payeeName;
        if (instructions != null) body['instructions'] = instructions;
        if (defaultGraceDays != null) {
          body['defaultGraceDays'] = defaultGraceDays;
        }
        if (reminderDaysBeforeDue != null) {
          body['reminderDaysBeforeDue'] = reminderDaysBeforeDue;
        }

        final response = await _pb.send(
          '/api/super-admin/billing-settings',
          method: 'PATCH',
          body: body,
          files: qrphImage != null ? [qrphImage] : const [],
        );
        if (response is! Map<String, dynamic>) {
          throw const DataFailure(
            'Invalid billing settings update response',
            null,
            'invalid_billing_settings_response',
          );
        }
        return PlatformBillingSettingsDto.fromJson(response)
            .toEntity(baseUrl: _pb.baseURL);
      },
      Failure.handle,
    ).run();
  }
}
