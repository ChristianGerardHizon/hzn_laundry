import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/customer_promo.dart';
import '../../domain/promo.dart';
import 'promo_dto.dart';

part 'customer_promo_dto.mapper.dart';

/// Data Transfer Object for CustomerPromo from PocketBase.
@MappableClass()
class CustomerPromoDto with CustomerPromoDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String customer;
  final String promo;
  final int completedOrders;
  final bool isRewardEarned;
  final bool isRewardRedeemed;
  final String? redeemedOnSale;
  final Promo? promoExpanded;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const CustomerPromoDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.customer,
    required this.promo,
    this.completedOrders = 0,
    this.isRewardEarned = false,
    this.isRewardRedeemed = false,
    this.redeemedOnSale,
    this.promoExpanded,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory CustomerPromoDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    // Extract expanded promo
    Promo? promoExpanded;
    final expandData = json['expand'] as Map<String, dynamic>?;
    if (expandData != null && expandData['promo'] != null) {
      final promoData = expandData['promo'] as Map<String, dynamic>;
      final promoRecord = RecordModel.fromJson(promoData);
      promoExpanded = PromoDto.fromRecord(promoRecord).toEntity();
    }

    return CustomerPromoDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      customer: json['customer'] as String? ?? '',
      promo: json['promo'] as String? ?? '',
      completedOrders: json['completedOrders'] as int? ?? 0,
      isRewardEarned: json['isRewardEarned'] as bool? ?? false,
      isRewardRedeemed: json['isRewardRedeemed'] as bool? ?? false,
      redeemedOnSale: json['redeemedOnSale'] as String?,
      promoExpanded: promoExpanded,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain CustomerPromo entity.
  CustomerPromo toEntity() {
    return CustomerPromo(
      id: id,
      customerId: customer,
      promoId: promo,
      completedOrders: completedOrders,
      isRewardEarned: isRewardEarned,
      isRewardRedeemed: isRewardRedeemed,
      redeemedOnSaleId: redeemedOnSale,
      promo: promoExpanded,
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
