import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/subscription_payment.dart';
import '../../domain/subscription_payment_status.dart';

part 'subscription_payment_dto.mapper.dart';

@MappableClass()
class SubscriptionPaymentDto with SubscriptionPaymentDtoMappable {
  const SubscriptionPaymentDto({
    required this.id,
    this.collectionId = '',
    this.collectionName = '',
    required this.organization,
    required this.subscription,
    this.amount = 0,
    this.status = 'pending',
    this.proofImage,
    this.proofImageUrl,
    this.note,
    this.adminNote,
    required this.submittedBy,
    this.reviewedBy,
    this.reviewedAt,
    this.created,
    this.organizationName,
  });

  final String id;
  final String collectionId;
  final String collectionName;
  final String organization;
  final String subscription;
  final num amount;
  final String status;
  final String? proofImage;
  final String? proofImageUrl;
  final String? note;
  final String? adminNote;
  final String submittedBy;
  final String? reviewedBy;
  final String? reviewedAt;
  final String? created;
  final String? organizationName;

  factory SubscriptionPaymentDto.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      organization: _relationId(json['organization']) ?? '',
      subscription: _relationId(json['subscription']) ?? '',
      amount: _asNum(json['amount']),
      status: json['status'] as String? ?? 'pending',
      proofImage: json['proofImage'] as String?,
      proofImageUrl: json['proofImageUrl'] as String?,
      note: json['note'] as String?,
      adminNote: json['adminNote'] as String?,
      submittedBy: _relationId(json['submittedBy']) ?? '',
      reviewedBy: _relationId(json['reviewedBy']),
      reviewedAt: json['reviewedAt'] as String?,
      created: json['created'] as String?,
      organizationName: json['organizationName'] as String?,
    );
  }

  factory SubscriptionPaymentDto.fromRecord(RecordModel record) {
    return SubscriptionPaymentDto.fromJson(record.toJson());
  }

  SubscriptionPayment toEntity({String? baseUrl}) {
    return SubscriptionPayment(
      id: id,
      organizationId: organization,
      subscriptionId: subscription,
      amount: amount,
      status: SubscriptionPaymentStatus.fromString(status),
      proofImageUrl: (proofImageUrl != null && proofImageUrl!.isNotEmpty)
          ? proofImageUrl
          : _buildFileUrl(baseUrl, proofImage),
      note: note != null && note!.isNotEmpty ? note : null,
      adminNote: adminNote != null && adminNote!.isNotEmpty ? adminNote : null,
      submittedById: submittedBy,
      reviewedById: reviewedBy != null && reviewedBy!.isNotEmpty
          ? reviewedBy
          : null,
      reviewedAt: parseToLocal(reviewedAt),
      created: parseToLocal(created),
      organizationName: organizationName,
    );
  }

  String? _buildFileUrl(String? baseUrl, String? filename) {
    if (filename == null || filename.isEmpty || baseUrl == null) {
      return null;
    }
    final collection =
        collectionName.isNotEmpty ? collectionName : 'subscriptionPayments';
    return '$baseUrl/api/files/$collection/$id/$filename';
  }
}

String? _relationId(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  if (value is Map) return value['id'] as String?;
  return value.toString();
}

num _asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}
