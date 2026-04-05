// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'employee_deduction_dto.dart';

class EmployeeDeductionDtoMapper extends ClassMapperBase<EmployeeDeductionDto> {
  EmployeeDeductionDtoMapper._();

  static EmployeeDeductionDtoMapper? _instance;
  static EmployeeDeductionDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EmployeeDeductionDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EmployeeDeductionDto';

  static String _$id(EmployeeDeductionDto v) => v.id;
  static const Field<EmployeeDeductionDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(EmployeeDeductionDto v) => v.collectionId;
  static const Field<EmployeeDeductionDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(EmployeeDeductionDto v) => v.collectionName;
  static const Field<EmployeeDeductionDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$employee(EmployeeDeductionDto v) => v.employee;
  static const Field<EmployeeDeductionDto, String> _f$employee = Field(
    'employee',
    _$employee,
  );
  static String _$type(EmployeeDeductionDto v) => v.type;
  static const Field<EmployeeDeductionDto, String> _f$type = Field(
    'type',
    _$type,
  );
  static String _$valueType(EmployeeDeductionDto v) => v.valueType;
  static const Field<EmployeeDeductionDto, String> _f$valueType = Field(
    'valueType',
    _$valueType,
  );
  static num _$value(EmployeeDeductionDto v) => v.value;
  static const Field<EmployeeDeductionDto, num> _f$value = Field(
    'value',
    _$value,
  );
  static String? _$name(EmployeeDeductionDto v) => v.name;
  static const Field<EmployeeDeductionDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static String? _$startMonth(EmployeeDeductionDto v) => v.startMonth;
  static const Field<EmployeeDeductionDto, String> _f$startMonth = Field(
    'startMonth',
    _$startMonth,
    opt: true,
  );
  static String? _$endMonth(EmployeeDeductionDto v) => v.endMonth;
  static const Field<EmployeeDeductionDto, String> _f$endMonth = Field(
    'endMonth',
    _$endMonth,
    opt: true,
  );
  static bool _$isActive(EmployeeDeductionDto v) => v.isActive;
  static const Field<EmployeeDeductionDto, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static String? _$created(EmployeeDeductionDto v) => v.created;
  static const Field<EmployeeDeductionDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(EmployeeDeductionDto v) => v.updated;
  static const Field<EmployeeDeductionDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<EmployeeDeductionDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
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

  static EmployeeDeductionDto _instantiate(DecodingData data) {
    return EmployeeDeductionDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
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

  static EmployeeDeductionDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EmployeeDeductionDto>(map);
  }

  static EmployeeDeductionDto fromJson(String json) {
    return ensureInitialized().decodeJson<EmployeeDeductionDto>(json);
  }
}

mixin EmployeeDeductionDtoMappable {
  String toJson() {
    return EmployeeDeductionDtoMapper.ensureInitialized()
        .encodeJson<EmployeeDeductionDto>(this as EmployeeDeductionDto);
  }

  Map<String, dynamic> toMap() {
    return EmployeeDeductionDtoMapper.ensureInitialized()
        .encodeMap<EmployeeDeductionDto>(this as EmployeeDeductionDto);
  }

  EmployeeDeductionDtoCopyWith<
    EmployeeDeductionDto,
    EmployeeDeductionDto,
    EmployeeDeductionDto
  >
  get copyWith =>
      _EmployeeDeductionDtoCopyWithImpl<
        EmployeeDeductionDto,
        EmployeeDeductionDto
      >(this as EmployeeDeductionDto, $identity, $identity);
  @override
  String toString() {
    return EmployeeDeductionDtoMapper.ensureInitialized().stringifyValue(
      this as EmployeeDeductionDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return EmployeeDeductionDtoMapper.ensureInitialized().equalsValue(
      this as EmployeeDeductionDto,
      other,
    );
  }

  @override
  int get hashCode {
    return EmployeeDeductionDtoMapper.ensureInitialized().hashValue(
      this as EmployeeDeductionDto,
    );
  }
}

extension EmployeeDeductionDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EmployeeDeductionDto, $Out> {
  EmployeeDeductionDtoCopyWith<$R, EmployeeDeductionDto, $Out>
  get $asEmployeeDeductionDto => $base.as(
    (v, t, t2) => _EmployeeDeductionDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class EmployeeDeductionDtoCopyWith<
  $R,
  $In extends EmployeeDeductionDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? employee,
    String? type,
    String? valueType,
    num? value,
    String? name,
    String? startMonth,
    String? endMonth,
    bool? isActive,
    String? created,
    String? updated,
  });
  EmployeeDeductionDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EmployeeDeductionDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EmployeeDeductionDto, $Out>
    implements EmployeeDeductionDtoCopyWith<$R, EmployeeDeductionDto, $Out> {
  _EmployeeDeductionDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EmployeeDeductionDto> $mapper =
      EmployeeDeductionDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? employee,
    String? type,
    String? valueType,
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
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
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
  EmployeeDeductionDto $make(CopyWithData data) => EmployeeDeductionDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
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
  EmployeeDeductionDtoCopyWith<$R2, EmployeeDeductionDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _EmployeeDeductionDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

