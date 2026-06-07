// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'machine.dart';

class MachineMapper extends ClassMapperBase<Machine> {
  MachineMapper._();

  static MachineMapper? _instance;
  static MachineMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MachineMapper._());
      MachineTypeMapper.ensureInitialized();
      MachineSizeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Machine';

  static String _$id(Machine v) => v.id;
  static const Field<Machine, String> _f$id = Field('id', _$id);
  static String _$name(Machine v) => v.name;
  static const Field<Machine, String> _f$name = Field('name', _$name);
  static MachineType _$type(Machine v) => v.type;
  static const Field<Machine, MachineType> _f$type = Field('type', _$type);
  static MachineSize? _$size(Machine v) => v.size;
  static const Field<Machine, MachineSize> _f$size = Field(
    'size',
    _$size,
    opt: true,
  );
  static String? _$branchId(Machine v) => v.branchId;
  static const Field<Machine, String> _f$branchId = Field(
    'branchId',
    _$branchId,
    opt: true,
  );
  static bool _$isAvailable(Machine v) => v.isAvailable;
  static const Field<Machine, bool> _f$isAvailable = Field(
    'isAvailable',
    _$isAvailable,
    opt: true,
    def: true,
  );
  static bool _$strictSingleUse(Machine v) => v.strictSingleUse;
  static const Field<Machine, bool> _f$strictSingleUse = Field(
    'strictSingleUse',
    _$strictSingleUse,
    opt: true,
    def: false,
  );
  static bool _$isDeleted(Machine v) => v.isDeleted;
  static const Field<Machine, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(Machine v) => v.created;
  static const Field<Machine, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Machine v) => v.updated;
  static const Field<Machine, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Machine> fields = const {
    #id: _f$id,
    #name: _f$name,
    #type: _f$type,
    #size: _f$size,
    #branchId: _f$branchId,
    #isAvailable: _f$isAvailable,
    #strictSingleUse: _f$strictSingleUse,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Machine _instantiate(DecodingData data) {
    return Machine(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      type: data.dec(_f$type),
      size: data.dec(_f$size),
      branchId: data.dec(_f$branchId),
      isAvailable: data.dec(_f$isAvailable),
      strictSingleUse: data.dec(_f$strictSingleUse),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Machine fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Machine>(map);
  }

  static Machine fromJson(String json) {
    return ensureInitialized().decodeJson<Machine>(json);
  }
}

mixin MachineMappable {
  String toJson() {
    return MachineMapper.ensureInitialized().encodeJson<Machine>(
      this as Machine,
    );
  }

  Map<String, dynamic> toMap() {
    return MachineMapper.ensureInitialized().encodeMap<Machine>(
      this as Machine,
    );
  }

  MachineCopyWith<Machine, Machine, Machine> get copyWith =>
      _MachineCopyWithImpl<Machine, Machine>(
        this as Machine,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MachineMapper.ensureInitialized().stringifyValue(this as Machine);
  }

  @override
  bool operator ==(Object other) {
    return MachineMapper.ensureInitialized().equalsValue(
      this as Machine,
      other,
    );
  }

  @override
  int get hashCode {
    return MachineMapper.ensureInitialized().hashValue(this as Machine);
  }
}

extension MachineValueCopy<$R, $Out> on ObjectCopyWith<$R, Machine, $Out> {
  MachineCopyWith<$R, Machine, $Out> get $asMachine =>
      $base.as((v, t, t2) => _MachineCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MachineCopyWith<$R, $In extends Machine, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    MachineType? type,
    MachineSize? size,
    String? branchId,
    bool? isAvailable,
    bool? strictSingleUse,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  MachineCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MachineCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Machine, $Out>
    implements MachineCopyWith<$R, Machine, $Out> {
  _MachineCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Machine> $mapper =
      MachineMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    MachineType? type,
    Object? size = $none,
    Object? branchId = $none,
    bool? isAvailable,
    bool? strictSingleUse,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (type != null) #type: type,
      if (size != $none) #size: size,
      if (branchId != $none) #branchId: branchId,
      if (isAvailable != null) #isAvailable: isAvailable,
      if (strictSingleUse != null) #strictSingleUse: strictSingleUse,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Machine $make(CopyWithData data) => Machine(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    type: data.get(#type, or: $value.type),
    size: data.get(#size, or: $value.size),
    branchId: data.get(#branchId, or: $value.branchId),
    isAvailable: data.get(#isAvailable, or: $value.isAvailable),
    strictSingleUse: data.get(#strictSingleUse, or: $value.strictSingleUse),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MachineCopyWith<$R2, Machine, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MachineCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

