// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'employee_deduction.dart';

class EmployeeDeductionMapper extends ClassMapperBase<EmployeeDeduction> {
  EmployeeDeductionMapper._();

  static EmployeeDeductionMapper? _instance;
  static EmployeeDeductionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EmployeeDeductionMapper._());
      DeductionTypeMapper.ensureInitialized();
      DeductionValueTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EmployeeDeduction';

  static String _$id(EmployeeDeduction v) => v.id;
  static const Field<EmployeeDeduction, String> _f$id = Field('id', _$id);
  static String _$employee(EmployeeDeduction v) => v.employee;
  static const Field<EmployeeDeduction, String> _f$employee = Field(
    'employee',
    _$employee,
  );
  static DeductionType _$type(EmployeeDeduction v) => v.type;
  static const Field<EmployeeDeduction, DeductionType> _f$type = Field(
    'type',
    _$type,
  );
  static DeductionValueType _$valueType(EmployeeDeduction v) => v.valueType;
  static const Field<EmployeeDeduction, DeductionValueType> _f$valueType =
      Field('valueType', _$valueType);
  static num _$value(EmployeeDeduction v) => v.value;
  static const Field<EmployeeDeduction, num> _f$value = Field('value', _$value);
  static String? _$name(EmployeeDeduction v) => v.name;
  static const Field<EmployeeDeduction, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static DateTime? _$startMonth(EmployeeDeduction v) => v.startMonth;
  static const Field<EmployeeDeduction, DateTime> _f$startMonth = Field(
    'startMonth',
    _$startMonth,
    opt: true,
  );
  static DateTime? _$endMonth(EmployeeDeduction v) => v.endMonth;
  static const Field<EmployeeDeduction, DateTime> _f$endMonth = Field(
    'endMonth',
    _$endMonth,
    opt: true,
  );
  static bool _$isActive(EmployeeDeduction v) => v.isActive;
  static const Field<EmployeeDeduction, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static DateTime? _$created(EmployeeDeduction v) => v.created;
  static const Field<EmployeeDeduction, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(EmployeeDeduction v) => v.updated;
  static const Field<EmployeeDeduction, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<EmployeeDeduction> fields = const {
    #id: _f$id,
    #employee: _f$employee,
    #type: _f$type,
    #valueType: _f$valueType,
    #value: _f$value,
    #name: _f$name,
    #startMonth: _f$startMonth,
    #endMonth: _f$endMonth,
    #isActive: _f$isActive,
    #created: _f$created,
    #updated: _f$updated,
  };

  static EmployeeDeduction _instantiate(DecodingData data) {
    return EmployeeDeduction(
      id: data.dec(_f$id),
      employee: data.dec(_f$employee),
      type: data.dec(_f$type),
      valueType: data.dec(_f$valueType),
      value: data.dec(_f$value),
      name: data.dec(_f$name),
      startMonth: data.dec(_f$startMonth),
      endMonth: data.dec(_f$endMonth),
      isActive: data.dec(_f$isActive),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EmployeeDeduction fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EmployeeDeduction>(map);
  }

  static EmployeeDeduction fromJson(String json) {
    return ensureInitialized().decodeJson<EmployeeDeduction>(json);
  }
}

mixin EmployeeDeductionMappable {
  String toJson() {
    return EmployeeDeductionMapper.ensureInitialized()
        .encodeJson<EmployeeDeduction>(this as EmployeeDeduction);
  }

  Map<String, dynamic> toMap() {
    return EmployeeDeductionMapper.ensureInitialized()
        .encodeMap<EmployeeDeduction>(this as EmployeeDeduction);
  }

  EmployeeDeductionCopyWith<
    EmployeeDeduction,
    EmployeeDeduction,
    EmployeeDeduction
  >
  get copyWith =>
      _EmployeeDeductionCopyWithImpl<EmployeeDeduction, EmployeeDeduction>(
        this as EmployeeDeduction,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EmployeeDeductionMapper.ensureInitialized().stringifyValue(
      this as EmployeeDeduction,
    );
  }

  @override
  bool operator ==(Object other) {
    return EmployeeDeductionMapper.ensureInitialized().equalsValue(
      this as EmployeeDeduction,
      other,
    );
  }

  @override
  int get hashCode {
    return EmployeeDeductionMapper.ensureInitialized().hashValue(
      this as EmployeeDeduction,
    );
  }
}

extension EmployeeDeductionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EmployeeDeduction, $Out> {
  EmployeeDeductionCopyWith<$R, EmployeeDeduction, $Out>
  get $asEmployeeDeduction => $base.as(
    (v, t, t2) => _EmployeeDeductionCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class EmployeeDeductionCopyWith<
  $R,
  $In extends EmployeeDeduction,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? employee,
    DeductionType? type,
    DeductionValueType? valueType,
    num? value,
    String? name,
    DateTime? startMonth,
    DateTime? endMonth,
    bool? isActive,
    DateTime? created,
    DateTime? updated,
  });
  EmployeeDeductionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EmployeeDeductionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EmployeeDeduction, $Out>
    implements EmployeeDeductionCopyWith<$R, EmployeeDeduction, $Out> {
  _EmployeeDeductionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EmployeeDeduction> $mapper =
      EmployeeDeductionMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? employee,
    DeductionType? type,
    DeductionValueType? valueType,
    num? value,
    Object? name = $none,
    Object? startMonth = $none,
    Object? endMonth = $none,
    bool? isActive,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (employee != null) #employee: employee,
      if (type != null) #type: type,
      if (valueType != null) #valueType: valueType,
      if (value != null) #value: value,
      if (name != $none) #name: name,
      if (startMonth != $none) #startMonth: startMonth,
      if (endMonth != $none) #endMonth: endMonth,
      if (isActive != null) #isActive: isActive,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  EmployeeDeduction $make(CopyWithData data) => EmployeeDeduction(
    id: data.get(#id, or: $value.id),
    employee: data.get(#employee, or: $value.employee),
    type: data.get(#type, or: $value.type),
    valueType: data.get(#valueType, or: $value.valueType),
    value: data.get(#value, or: $value.value),
    name: data.get(#name, or: $value.name),
    startMonth: data.get(#startMonth, or: $value.startMonth),
    endMonth: data.get(#endMonth, or: $value.endMonth),
    isActive: data.get(#isActive, or: $value.isActive),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  EmployeeDeductionCopyWith<$R2, EmployeeDeduction, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EmployeeDeductionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

