import 'package:pocketbase/pocketbase.dart';

import '../../domain/delivery_rate.dart';

/// Maps a `branchDeliveryRates` PocketBase record to a [DeliveryRate].
class DeliveryRateDto {
  const DeliveryRateDto._();

  static DeliveryRate fromRecord(RecordModel record) => DeliveryRate(
        id: record.id,
        branchId: record.getStringValue('branch'),
        name: record.getStringValue('name'),
        baseFee: record.getDoubleValue('baseFee'),
        includedKm: record.getDoubleValue('includedKm'),
        ratePerKm: record.getDoubleValue('ratePerKm'),
        isDefault: record.getBoolValue('isDefault'),
      );

  static Map<String, dynamic> toBody(DeliveryRate rate) => {
        'branch': rate.branchId,
        'name': rate.name,
        'baseFee': rate.baseFee,
        'includedKm': rate.includedKm,
        'ratePerKm': rate.ratePerKm,
        'isDefault': rate.isDefault,
        'isDeleted': false,
      };
}
