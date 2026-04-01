import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/customer.dart';

part 'customer_dto.mapper.dart';

/// Data Transfer Object for Customer from PocketBase.
@MappableClass()
class CustomerDto with CustomerDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final String? created;
  final String? updated;

  const CustomerDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    this.created,
    this.updated,
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory CustomerDto.fromRecord(RecordModel record) {
    return CustomerDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      name: record.getStringValue('name'),
      phone: record.getStringValue('phone'),
      address: record.getStringValue('address'),
      notes: record.getStringValue('notes'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  /// Converts the DTO to a domain Customer entity.
  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      phone: phone != null && phone!.isNotEmpty ? phone : null,
      address: address != null && address!.isNotEmpty ? address : null,
      notes: notes != null && notes!.isNotEmpty ? notes : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }
}
