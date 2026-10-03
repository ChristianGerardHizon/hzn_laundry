import 'package:pocketbase/pocketbase.dart';

import '../../domain/customer_address.dart';

/// Maps a `customerAddresses` PocketBase record to a [CustomerAddress].
class CustomerAddressDto {
  const CustomerAddressDto._();

  static CustomerAddress fromRecord(RecordModel record) {
    String? nonEmpty(String key) {
      final v = record.getStringValue(key);
      return v.isEmpty ? null : v;
    }

    final distance = record.data['distanceKm'];
    return CustomerAddress(
      id: record.id,
      customerId: record.getStringValue('customer'),
      label: nonEmpty('label'),
      address: record.getStringValue('address'),
      notes: nonEmpty('notes'),
      // PocketBase returns 0 for an unset number; treat that as "no distance".
      distanceKm: distance is num && distance > 0 ? distance : null,
      deliveryRateId: nonEmpty('deliveryRate'),
      isDefault: record.getBoolValue('isDefault'),
    );
  }

  static Map<String, dynamic> toBody(CustomerAddress a) => {
        'customer': a.customerId,
        'label': a.label ?? '',
        'address': a.address,
        'notes': a.notes ?? '',
        'distanceKm': a.distanceKm ?? 0,
        'deliveryRate': a.deliveryRateId ?? '',
        'isDefault': a.isDefault,
        'isDeleted': false,
      };
}
