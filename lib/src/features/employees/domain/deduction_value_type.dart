import 'package:dart_mappable/dart_mappable.dart';

part 'deduction_value_type.mapper.dart';

/// Whether a deduction is a fixed amount or percentage of base salary.
@MappableEnum()
enum DeductionValueType {
  fixed,
  percentage;

  String get displayName => switch (this) {
        DeductionValueType.fixed => 'Fixed Amount',
        DeductionValueType.percentage => 'Percentage',
      };
}
