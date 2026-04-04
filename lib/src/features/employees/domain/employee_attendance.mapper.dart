// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'employee_attendance.dart';

class EmployeeAttendanceMapper extends ClassMapperBase<EmployeeAttendance> {
  EmployeeAttendanceMapper._();

  static EmployeeAttendanceMapper? _instance;
  static EmployeeAttendanceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EmployeeAttendanceMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EmployeeAttendance';

  static String _$id(EmployeeAttendance v) => v.id;
  static const Field<EmployeeAttendance, String> _f$id = Field('id', _$id);
  static String _$employee(EmployeeAttendance v) => v.employee;
  static const Field<EmployeeAttendance, String> _f$employee = Field(
    'employee',
    _$employee,
  );
  static DateTime _$date(EmployeeAttendance v) => v.date;
  static const Field<EmployeeAttendance, DateTime> _f$date = Field(
    'date',
    _$date,
  );
  static bool _$isPresent(EmployeeAttendance v) => v.isPresent;
  static const Field<EmployeeAttendance, bool> _f$isPresent = Field(
    'isPresent',
    _$isPresent,
    opt: true,
    def: true,
  );
  static String? _$notes(EmployeeAttendance v) => v.notes;
  static const Field<EmployeeAttendance, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static DateTime? _$created(EmployeeAttendance v) => v.created;
  static const Field<EmployeeAttendance, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(EmployeeAttendance v) => v.updated;
  static const Field<EmployeeAttendance, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<EmployeeAttendance> fields = const {
    #id: _f$id,
    #employee: _f$employee,
    #date: _f$date,
    #isPresent: _f$isPresent,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
  };

  static EmployeeAttendance _instantiate(DecodingData data) {
    return EmployeeAttendance(
      id: data.dec(_f$id),
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

  static EmployeeAttendance fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EmployeeAttendance>(map);
  }

  static EmployeeAttendance fromJson(String json) {
    return ensureInitialized().decodeJson<EmployeeAttendance>(json);
  }
}

mixin EmployeeAttendanceMappable {
  String toJson() {
    return EmployeeAttendanceMapper.ensureInitialized()
        .encodeJson<EmployeeAttendance>(this as EmployeeAttendance);
  }

  Map<String, dynamic> toMap() {
    return EmployeeAttendanceMapper.ensureInitialized()
        .encodeMap<EmployeeAttendance>(this as EmployeeAttendance);
  }

  EmployeeAttendanceCopyWith<
    EmployeeAttendance,
    EmployeeAttendance,
    EmployeeAttendance
  >
  get copyWith =>
      _EmployeeAttendanceCopyWithImpl<EmployeeAttendance, EmployeeAttendance>(
        this as EmployeeAttendance,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EmployeeAttendanceMapper.ensureInitialized().stringifyValue(
      this as EmployeeAttendance,
    );
  }

  @override
  bool operator ==(Object other) {
    return EmployeeAttendanceMapper.ensureInitialized().equalsValue(
      this as EmployeeAttendance,
      other,
    );
  }

  @override
  int get hashCode {
    return EmployeeAttendanceMapper.ensureInitialized().hashValue(
      this as EmployeeAttendance,
    );
  }
}

extension EmployeeAttendanceValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EmployeeAttendance, $Out> {
  EmployeeAttendanceCopyWith<$R, EmployeeAttendance, $Out>
  get $asEmployeeAttendance => $base.as(
    (v, t, t2) => _EmployeeAttendanceCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class EmployeeAttendanceCopyWith<
  $R,
  $In extends EmployeeAttendance,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? employee,
    DateTime? date,
    bool? isPresent,
    String? notes,
    DateTime? created,
    DateTime? updated,
  });
  EmployeeAttendanceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EmployeeAttendanceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EmployeeAttendance, $Out>
    implements EmployeeAttendanceCopyWith<$R, EmployeeAttendance, $Out> {
  _EmployeeAttendanceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EmployeeAttendance> $mapper =
      EmployeeAttendanceMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? employee,
    DateTime? date,
    bool? isPresent,
    Object? notes = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (employee != null) #employee: employee,
      if (date != null) #date: date,
      if (isPresent != null) #isPresent: isPresent,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  EmployeeAttendance $make(CopyWithData data) => EmployeeAttendance(
    id: data.get(#id, or: $value.id),
    employee: data.get(#employee, or: $value.employee),
    date: data.get(#date, or: $value.date),
    isPresent: data.get(#isPresent, or: $value.isPresent),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  EmployeeAttendanceCopyWith<$R2, EmployeeAttendance, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EmployeeAttendanceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

