import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/user_role.dart';

part 'user_role_dto.mapper.dart';

/// Data Transfer Object for UserRole from PocketBase.
///
/// Handles conversion between PocketBase RecordModel and domain UserRole.
/// Permissions are stored as a JSON array in PocketBase.
@MappableClass()
class UserRoleDto with UserRoleDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String? description;
  final List<String> permissions;
  final bool isSystem;
  final bool isDeleted;
  final String? created;
  final String? updated;

  const UserRoleDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    this.description,
    this.permissions = const [],
    this.isSystem = false,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// Parses permissions from various formats.
  ///
  /// Handles:
  /// - List<dynamic> (from PocketBase JSON field)
  /// - String (JSON-encoded array, fallback)
  /// - null (returns empty list)
  static List<String> _parsePermissions(dynamic value) {
    if (value == null) return [];

    // Handle List (most common case from PocketBase JSON field)
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    // Handle String (JSON-encoded, fallback for edge cases)
    if (value is String) {
      if (value.isEmpty) return [];
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        // Not valid JSON, return empty
      }
    }

    return [];
  }

  /// Creates a DTO from a PocketBase RecordModel.
  factory UserRoleDto.fromRecord(RecordModel record) {
    return UserRoleDto.fromJson(record.toJson());
  }

  factory UserRoleDto.fromJson(Map<String, dynamic> json) {
    return UserRoleDto(
      id: json['id'] as String? ?? '',
      collectionId: json['collectionId'] as String? ?? '',
      collectionName: json['collectionName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      permissions: _parsePermissions(json['permissions']),
      isSystem: json['isSystem'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  /// Converts the DTO to a domain UserRole entity.
  UserRole toEntity() {
    return UserRole(
      id: id,
      name: name,
      description: description,
      permissions: permissions,
      isSystem: isSystem,
      isDeleted: isDeleted,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
