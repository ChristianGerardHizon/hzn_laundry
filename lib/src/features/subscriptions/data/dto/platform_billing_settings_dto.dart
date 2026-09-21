import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../domain/platform_billing_settings.dart';

part 'platform_billing_settings_dto.mapper.dart';

@MappableClass()
class PlatformBillingSettingsDto with PlatformBillingSettingsDtoMappable {
  const PlatformBillingSettingsDto({
    required this.id,
    this.collectionId = '',
    this.collectionName = '',
    this.qrphImage,
    this.qrphImageUrl,
    this.payeeName = '',
    this.instructions = '',
    this.defaultGraceDays = 7,
    this.reminderDaysBeforeDue = const [3, 0],
  });

  final String id;
  final String collectionId;
  final String collectionName;
  final String? qrphImage;
  final String? qrphImageUrl;
  final String payeeName;
  final String instructions;
  final int defaultGraceDays;
  final List<int> reminderDaysBeforeDue;

  factory PlatformBillingSettingsDto.fromJson(Map<String, dynamic> json) {
    return PlatformBillingSettingsDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      qrphImage: json['qrphImage'] as String?,
      qrphImageUrl: json['qrphImageUrl'] as String?,
      payeeName: json['payeeName'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      defaultGraceDays: _asInt(json['defaultGraceDays'], fallback: 7),
      reminderDaysBeforeDue: _asIntList(json['reminderDaysBeforeDue']),
    );
  }

  factory PlatformBillingSettingsDto.fromRecord(RecordModel record) {
    return PlatformBillingSettingsDto.fromJson(record.toJson());
  }

  PlatformBillingSettings toEntity({String? baseUrl}) {
    return PlatformBillingSettings(
      id: id,
      qrphImageUrl: (qrphImageUrl != null && qrphImageUrl!.isNotEmpty)
          ? qrphImageUrl
          : _buildFileUrl(baseUrl, qrphImage),
      payeeName: payeeName,
      instructions: instructions,
      defaultGraceDays: defaultGraceDays,
      reminderDaysBeforeDue: reminderDaysBeforeDue,
    );
  }

  String? _buildFileUrl(String? baseUrl, String? filename) {
    if (filename == null || filename.isEmpty || baseUrl == null) {
      return null;
    }
    final collection =
        collectionName.isNotEmpty ? collectionName : 'platformBillingSettings';
    return '$baseUrl/api/files/$collection/$id/$filename';
  }
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

List<int> _asIntList(dynamic value) {
  if (value is! List) return const [3, 0];
  return value.map((e) {
    if (e is int) return e;
    if (e is num) return e.toInt();
    if (e is String) return int.tryParse(e) ?? 0;
    return 0;
  }).toList();
}
