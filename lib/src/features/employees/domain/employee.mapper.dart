// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'employee.dart';

class EmployeeMapper extends ClassMapperBase<Employee> {
  EmployeeMapper._();

  static EmployeeMapper? _instance;
  static EmployeeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EmployeeMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Employee';

  static String _$id(Employee v) => v.id;
  static const Field<Employee, String> _f$id = Field('id', _$id);
  static String _$name(Employee v) => v.name;
  static const Field<Employee, String> _f$name = Field('name', _$name);
  static num _$baseSalary(Employee v) => v.baseSalary;
  static const Field<Employee, num> _f$baseSalary = Field(
    'baseSalary',
    _$baseSalary,
    opt: true,
    def: 0,
  );
  static bool _$isDeleted(Employee v) => v.isDeleted;
  static const Field<Employee, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(Employee v) => v.created;
  static const Field<Employee, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Employee v) => v.updated;
  static const Field<Employee, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Employee> fields = const {
    #id: _f$id,
    #name: _f$name,
    #baseSalary: _f$baseSalary,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Employee _instantiate(DecodingData data) {
    return Employee(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      baseSalary: data.dec(_f$baseSalary),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Employee fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Employee>(map);
  }

  static Employee fromJson(String json) {
    return ensureInitialized().decodeJson<Employee>(json);
  }
}

mixin EmployeeMappable {
  String toJson() {
    return EmployeeMapper.ensureInitialized().encodeJson<Employee>(
      this as Employee,
    );
  }

  Map<String, dynamic> toMap() {
    return EmployeeMapper.ensureInitialized().encodeMap<Employee>(
      this as Employee,
    );
  }

  EmployeeCopyWith<Employee, Employee, Employee> get copyWith =>
      _EmployeeCopyWithImpl<Employee, Employee>(
        this as Employee,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EmployeeMapper.ensureInitialized().stringifyValue(this as Employee);
  }

  @override
  bool operator ==(Object other) {
    return EmployeeMapper.ensureInitialized().equalsValue(
      this as Employee,
      other,
    );
  }

  @override
  int get hashCode {
    return EmployeeMapper.ensureInitialized().hashValue(this as Employee);
  }
}

extension EmployeeValueCopy<$R, $Out> on ObjectCopyWith<$R, Employee, $Out> {
  EmployeeCopyWith<$R, Employee, $Out> get $asEmployee =>
      $base.as((v, t, t2) => _EmployeeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EmployeeCopyWith<$R, $In extends Employee, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    num? baseSalary,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  EmployeeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EmployeeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Employee, $Out>
    implements EmployeeCopyWith<$R, Employee, $Out> {
  _EmployeeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Employee> $mapper =
      EmployeeMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    num? baseSalary,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (baseSalary != null) #baseSalary: baseSalary,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Employee $make(CopyWithData data) => Employee(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    baseSalary: data.get(#baseSalary, or: $value.baseSalary),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  EmployeeCopyWith<$R2, Employee, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EmployeeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

