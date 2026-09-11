import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../domain/printer_config.dart';
import '../../domain/printer_connection_type.dart';
import '../../domain/printer_paper_width.dart';

part 'printer_config_dto.mapper.dart';

/// Data Transfer Object for one-time import of printer configs from PocketBase.
@MappableClass()
class PrinterConfigDto with PrinterConfigDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String connectionType;
  final String? address;
  final int port;
  final String paperWidth;
  final bool isDefault;
  final bool isEnabled;
  final String? branch;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const PrinterConfigDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.connectionType,
    this.address,
    this.port = 9100,
    this.paperWidth = 'mm80',
    this.isDefault = false,
    this.isEnabled = true,
    this.branch,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory PrinterConfigDto.fromRecord(RecordModel record) {
    final json = record.toJson();

    return PrinterConfigDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      connectionType: json['connectionType'] as String? ?? 'bluetooth',
      address: json['address'] as String?,
      port: json['port'] as int? ?? 9100,
      paperWidth: json['paperWidth'] as String? ?? 'mm80',
      isDefault: json['isDefault'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
      branch: json['branch'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a local domain PrinterConfig entity.
  PrinterConfig toEntity() {
    return PrinterConfig(
      id: id,
      name: name,
      connectionType: _parseConnectionType(connectionType),
      address: address,
      port: port,
      paperWidth: _parsePaperWidth(paperWidth),
      isEnabled: isEnabled,
      created: created != null ? DateTime.tryParse(created!)?.toLocal() : null,
      updated: updated != null ? DateTime.tryParse(updated!)?.toLocal() : null,
    );
  }

  PrinterConnectionType _parseConnectionType(String value) {
    switch (value) {
      case 'network':
        return PrinterConnectionType.network;
      case 'bluetooth':
      default:
        return PrinterConnectionType.bluetooth;
    }
  }

  PrinterPaperWidth _parsePaperWidth(String value) {
    switch (value) {
      case 'mm58':
        return PrinterPaperWidth.mm58;
      case 'mm80':
      default:
        return PrinterPaperWidth.mm80;
    }
  }
}
