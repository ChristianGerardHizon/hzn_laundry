import 'package:dart_mappable/dart_mappable.dart';

part 'deduction_type.mapper.dart';

/// Types of employee deductions.
@MappableEnum()
enum DeductionType {
  cashAdvance,
  sss,
  philHealth,
  pagIbig,
  other;

  String get displayName => switch (this) {
        DeductionType.cashAdvance => 'Cash Advance',
        DeductionType.sss => 'SSS',
        DeductionType.philHealth => 'PhilHealth',
        DeductionType.pagIbig => 'Pag-IBIG',
        DeductionType.other => 'Other',
      };
}
