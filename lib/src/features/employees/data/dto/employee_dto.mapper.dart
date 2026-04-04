// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'employee_dto.dart';

class EmployeeDtoMapper extends ClassMapperBase<EmployeeDto> {
  EmployeeDtoMapper._();

  static EmployeeDtoMapper? _instance;
  static EmployeeDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EmployeeDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EmployeeDto';

  static String _$id(EmployeeDto v) => v.id;
  static const Field<EmployeeDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(EmployeeDto v) => v.collectionId;
  static const Field<EmployeeDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(EmployeeDto v) => v.collectionName;
  static const Field<EmployeeDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(EmployeeDto v) => v.name;
  static const Field<EmployeeDto, String> _f$name = Field('name', _$name);
  static num _$baseSalary(EmployeeDto v) => v.baseSalary;
  static const Field<EmployeeDto, num> _f$baseSalary = Field(
    'baseSalary',
    _$baseSalary,
    opt: true,
    def: 0,
  );
  static bool _$isDeleted(EmployeeDto v) => v.isDeleted;
  static const Field<EmployeeDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(EmployeeDto v) => v.created;
  static const Field<EmployeeDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(EmployeeDto v) => v.updated;
  static const Field<EmployeeDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<EmployeeDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #baseSalary: _f$baseSalary,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static EmployeeDto _instantiate(DecodingData data) {
    return EmployeeDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      baseSalary: data.dec(_f$baseSalary),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EmployeeDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EmployeeDto>(map);
  }

  static EmployeeDto fromJson(String json) {
    return ensureInitialized().decodeJson<EmployeeDto>(json);
  }
}

mixin EmployeeDtoMappable {
  String toJson() {
    return EmployeeDtoMapper.ensureInitialized().encodeJson<EmployeeDto>(
      this as EmployeeDto,
    );
  }

  Map<String, dynamic> toMap() {
    return EmployeeDtoMapper.ensureInitialized().encodeMap<EmployeeDto>(
      this as EmployeeDto,
    );
  }

  EmployeeDtoCopyWith<EmployeeDto, EmployeeDto, EmployeeDto> get copyWith =>
      _EmployeeDtoCopyWithImpl<EmployeeDto, EmployeeDto>(
        this as EmployeeDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EmployeeDtoMapper.ensureInitialized().stringifyValue(
      this as EmployeeDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return EmployeeDtoMapper.ensureInitialized().equalsValue(
      this as EmployeeDto,
      other,
    );
  }

  @override
  int get hashCode {
    return EmployeeDtoMapper.ensureInitialized().hashValue(this as EmployeeDto);
  }
}

extension EmployeeDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EmployeeDto, $Out> {
  EmployeeDtoCopyWith<$R, EmployeeDto, $Out> get $asEmployeeDto =>
      $base.as((v, t, t2) => _EmployeeDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EmployeeDtoCopyWith<$R, $In extends EmployeeDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    num? baseSalary,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  EmployeeDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EmployeeDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EmployeeDto, $Out>
    implements EmployeeDtoCopyWith<$R, EmployeeDto, $Out> {
  _EmployeeDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EmployeeDto> $mapper =
      EmployeeDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    num? baseSalary,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (baseSalary != null) #baseSalary: baseSalary,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  EmployeeDto $make(CopyWithData data) => EmployeeDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    baseSalary: data.get(#baseSalary, or: $value.baseSalary),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  EmployeeDtoCopyWith<$R2, EmployeeDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EmployeeDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

