// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'machine_dto.dart';

class MachineDtoMapper extends ClassMapperBase<MachineDto> {
  MachineDtoMapper._();

  static MachineDtoMapper? _instance;
  static MachineDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MachineDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MachineDto';

  static String _$id(MachineDto v) => v.id;
  static const Field<MachineDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(MachineDto v) => v.collectionId;
  static const Field<MachineDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(MachineDto v) => v.collectionName;
  static const Field<MachineDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(MachineDto v) => v.name;
  static const Field<MachineDto, String> _f$name = Field('name', _$name);
  static String _$type(MachineDto v) => v.type;
  static const Field<MachineDto, String> _f$type = Field('type', _$type);
  static String? _$branch(MachineDto v) => v.branch;
  static const Field<MachineDto, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static bool _$isAvailable(MachineDto v) => v.isAvailable;
  static const Field<MachineDto, bool> _f$isAvailable = Field(
    'isAvailable',
    _$isAvailable,
    opt: true,
    def: true,
  );
  static bool _$strictSingleUse(MachineDto v) => v.strictSingleUse;
  static const Field<MachineDto, bool> _f$strictSingleUse = Field(
    'strictSingleUse',
    _$strictSingleUse,
    opt: true,
    def: false,
  );
  static bool _$isDeleted(MachineDto v) => v.isDeleted;
  static const Field<MachineDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(MachineDto v) => v.created;
  static const Field<MachineDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(MachineDto v) => v.updated;
  static const Field<MachineDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<MachineDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #type: _f$type,
    #branch: _f$branch,
    #isAvailable: _f$isAvailable,
    #strictSingleUse: _f$strictSingleUse,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static MachineDto _instantiate(DecodingData data) {
    return MachineDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      type: data.dec(_f$type),
      branch: data.dec(_f$branch),
      isAvailable: data.dec(_f$isAvailable),
      strictSingleUse: data.dec(_f$strictSingleUse),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MachineDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MachineDto>(map);
  }

  static MachineDto fromJson(String json) {
    return ensureInitialized().decodeJson<MachineDto>(json);
  }
}

mixin MachineDtoMappable {
  String toJson() {
    return MachineDtoMapper.ensureInitialized().encodeJson<MachineDto>(
      this as MachineDto,
    );
  }

  Map<String, dynamic> toMap() {
    return MachineDtoMapper.ensureInitialized().encodeMap<MachineDto>(
      this as MachineDto,
    );
  }

  MachineDtoCopyWith<MachineDto, MachineDto, MachineDto> get copyWith =>
      _MachineDtoCopyWithImpl<MachineDto, MachineDto>(
        this as MachineDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MachineDtoMapper.ensureInitialized().stringifyValue(
      this as MachineDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return MachineDtoMapper.ensureInitialized().equalsValue(
      this as MachineDto,
      other,
    );
  }

  @override
  int get hashCode {
    return MachineDtoMapper.ensureInitialized().hashValue(this as MachineDto);
  }
}

extension MachineDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MachineDto, $Out> {
  MachineDtoCopyWith<$R, MachineDto, $Out> get $asMachineDto =>
      $base.as((v, t, t2) => _MachineDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MachineDtoCopyWith<$R, $In extends MachineDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? type,
    String? branch,
    bool? isAvailable,
    bool? strictSingleUse,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  MachineDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MachineDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MachineDto, $Out>
    implements MachineDtoCopyWith<$R, MachineDto, $Out> {
  _MachineDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MachineDto> $mapper =
      MachineDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? type,
    Object? branch = $none,
    bool? isAvailable,
    bool? strictSingleUse,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (type != null) #type: type,
      if (branch != $none) #branch: branch,
      if (isAvailable != null) #isAvailable: isAvailable,
      if (strictSingleUse != null) #strictSingleUse: strictSingleUse,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  MachineDto $make(CopyWithData data) => MachineDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    type: data.get(#type, or: $value.type),
    branch: data.get(#branch, or: $value.branch),
    isAvailable: data.get(#isAvailable, or: $value.isAvailable),
    strictSingleUse: data.get(#strictSingleUse, or: $value.strictSingleUse),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MachineDtoCopyWith<$R2, MachineDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MachineDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

