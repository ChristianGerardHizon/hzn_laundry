// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'employee_attendance_dto.dart';

class EmployeeAttendanceDtoMapper
    extends ClassMapperBase<EmployeeAttendanceDto> {
  EmployeeAttendanceDtoMapper._();

  static EmployeeAttendanceDtoMapper? _instance;
  static EmployeeAttendanceDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EmployeeAttendanceDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EmployeeAttendanceDto';

  static String _$id(EmployeeAttendanceDto v) => v.id;
  static const Field<EmployeeAttendanceDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(EmployeeAttendanceDto v) => v.collectionId;
  static const Field<EmployeeAttendanceDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(EmployeeAttendanceDto v) => v.collectionName;
  static const Field<EmployeeAttendanceDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$employee(EmployeeAttendanceDto v) => v.employee;
  static const Field<EmployeeAttendanceDto, String> _f$employee = Field(
    'employee',
    _$employee,
  );
  static String? _$date(EmployeeAttendanceDto v) => v.date;
  static const Field<EmployeeAttendanceDto, String> _f$date = Field(
    'date',
    _$date,
    opt: true,
  );
  static bool _$isPresent(EmployeeAttendanceDto v) => v.isPresent;
  static const Field<EmployeeAttendanceDto, bool> _f$isPresent = Field(
    'isPresent',
    _$isPresent,
    opt: true,
    def: true,
  );
  static String? _$notes(EmployeeAttendanceDto v) => v.notes;
  static const Field<EmployeeAttendanceDto, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static String? _$created(EmployeeAttendanceDto v) => v.created;
  static const Field<EmployeeAttendanceDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(EmployeeAttendanceDto v) => v.updated;
  static const Field<EmployeeAttendanceDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<EmployeeAttendanceDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #employee: _f$employee,
    #date: _f$date,
    #isPresent: _f$isPresent,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
  };

  static EmployeeAttendanceDto _instantiate(DecodingData data) {
    return EmployeeAttendanceDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      employee: data.dec(_f$employee),
      date: data.dec(_f$date),
      isPresent: data.dec(_f$isPresent),
      notes: data.dec(_f$notes),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EmployeeAttendanceDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EmployeeAttendanceDto>(map);
  }

  static EmployeeAttendanceDto fromJson(String json) {
    return ensureInitialized().decodeJson<EmployeeAttendanceDto>(json);
  }
}

mixin EmployeeAttendanceDtoMappable {
  String toJson() {
    return EmployeeAttendanceDtoMapper.ensureInitialized()
        .encodeJson<EmployeeAttendanceDto>(this as EmployeeAttendanceDto);
  }

  Map<String, dynamic> toMap() {
    return EmployeeAttendanceDtoMapper.ensureInitialized()
        .encodeMap<EmployeeAttendanceDto>(this as EmployeeAttendanceDto);
  }

  EmployeeAttendanceDtoCopyWith<
    EmployeeAttendanceDto,
    EmployeeAttendanceDto,
    EmployeeAttendanceDto
  >
  get copyWith =>
      _EmployeeAttendanceDtoCopyWithImpl<
        EmployeeAttendanceDto,
        EmployeeAttendanceDto
      >(this as EmployeeAttendanceDto, $identity, $identity);
  @override
  String toString() {
    return EmployeeAttendanceDtoMapper.ensureInitialized().stringifyValue(
      this as EmployeeAttendanceDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return EmployeeAttendanceDtoMapper.ensureInitialized().equalsValue(
      this as EmployeeAttendanceDto,
      other,
    );
  }

  @override
  int get hashCode {
    return EmployeeAttendanceDtoMapper.ensureInitialized().hashValue(
      this as EmployeeAttendanceDto,
    );
  }
}

extension EmployeeAttendanceDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EmployeeAttendanceDto, $Out> {
  EmployeeAttendanceDtoCopyWith<$R, EmployeeAttendanceDto, $Out>
  get $asEmployeeAttendanceDto => $base.as(
    (v, t, t2) => _EmployeeAttendanceDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class EmployeeAttendanceDtoCopyWith<
  $R,
  $In extends EmployeeAttendanceDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? employee,
    String? date,
    bool? isPresent,
    String? notes,
    String? created,
    String? updated,
  });
  EmployeeAttendanceDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EmployeeAttendanceDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EmployeeAttendanceDto, $Out>
    implements EmployeeAttendanceDtoCopyWith<$R, EmployeeAttendanceDto, $Out> {
  _EmployeeAttendanceDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EmployeeAttendanceDto> $mapper =
      EmployeeAttendanceDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? employee,
    Object? date = $none,
    bool? isPresent,
    Object? notes = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (employee != null) #employee: employee,
      if (date != $none) #date: date,
      if (isPresent != null) #isPresent: isPresent,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  EmployeeAttendanceDto $make(CopyWithData data) => EmployeeAttendanceDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    employee: data.get(#employee, or: $value.employee),
    date: data.get(#date, or: $value.date),
    isPresent: data.get(#isPresent, or: $value.isPresent),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  EmployeeAttendanceDtoCopyWith<$R2, EmployeeAttendanceDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _EmployeeAttendanceDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

