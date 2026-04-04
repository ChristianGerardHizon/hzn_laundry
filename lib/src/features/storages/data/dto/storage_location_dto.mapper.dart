// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'storage_location_dto.dart';

class StorageLocationDtoMapper extends ClassMapperBase<StorageLocationDto> {
  StorageLocationDtoMapper._();

  static StorageLocationDtoMapper? _instance;
  static StorageLocationDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StorageLocationDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'StorageLocationDto';

  static String _$id(StorageLocationDto v) => v.id;
  static const Field<StorageLocationDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(StorageLocationDto v) => v.collectionId;
  static const Field<StorageLocationDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(StorageLocationDto v) => v.collectionName;
  static const Field<StorageLocationDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(StorageLocationDto v) => v.name;
  static const Field<StorageLocationDto, String> _f$name = Field(
    'name',
    _$name,
  );
  static String? _$branch(StorageLocationDto v) => v.branch;
  static const Field<StorageLocationDto, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static bool _$isAvailable(StorageLocationDto v) => v.isAvailable;
  static const Field<StorageLocationDto, bool> _f$isAvailable = Field(
    'isAvailable',
    _$isAvailable,
    opt: true,
    def: true,
  );
  static bool _$isDeleted(StorageLocationDto v) => v.isDeleted;
  static const Field<StorageLocationDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(StorageLocationDto v) => v.created;
  static const Field<StorageLocationDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(StorageLocationDto v) => v.updated;
  static const Field<StorageLocationDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<StorageLocationDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #branch: _f$branch,
    #isAvailable: _f$isAvailable,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static StorageLocationDto _instantiate(DecodingData data) {
    return StorageLocationDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      branch: data.dec(_f$branch),
      isAvailable: data.dec(_f$isAvailable),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static StorageLocationDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StorageLocationDto>(map);
  }

  static StorageLocationDto fromJson(String json) {
    return ensureInitialized().decodeJson<StorageLocationDto>(json);
  }
}

mixin StorageLocationDtoMappable {
  String toJson() {
    return StorageLocationDtoMapper.ensureInitialized()
        .encodeJson<StorageLocationDto>(this as StorageLocationDto);
  }

  Map<String, dynamic> toMap() {
    return StorageLocationDtoMapper.ensureInitialized()
        .encodeMap<StorageLocationDto>(this as StorageLocationDto);
  }

  StorageLocationDtoCopyWith<
    StorageLocationDto,
    StorageLocationDto,
    StorageLocationDto
  >
  get copyWith =>
      _StorageLocationDtoCopyWithImpl<StorageLocationDto, StorageLocationDto>(
        this as StorageLocationDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return StorageLocationDtoMapper.ensureInitialized().stringifyValue(
      this as StorageLocationDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return StorageLocationDtoMapper.ensureInitialized().equalsValue(
      this as StorageLocationDto,
      other,
    );
  }

  @override
  int get hashCode {
    return StorageLocationDtoMapper.ensureInitialized().hashValue(
      this as StorageLocationDto,
    );
  }
}

extension StorageLocationDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StorageLocationDto, $Out> {
  StorageLocationDtoCopyWith<$R, StorageLocationDto, $Out>
  get $asStorageLocationDto => $base.as(
    (v, t, t2) => _StorageLocationDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class StorageLocationDtoCopyWith<
  $R,
  $In extends StorageLocationDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? branch,
    bool? isAvailable,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  StorageLocationDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _StorageLocationDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StorageLocationDto, $Out>
    implements StorageLocationDtoCopyWith<$R, StorageLocationDto, $Out> {
  _StorageLocationDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StorageLocationDto> $mapper =
      StorageLocationDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    Object? branch = $none,
    bool? isAvailable,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (branch != $none) #branch: branch,
      if (isAvailable != null) #isAvailable: isAvailable,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  StorageLocationDto $make(CopyWithData data) => StorageLocationDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    branch: data.get(#branch, or: $value.branch),
    isAvailable: data.get(#isAvailable, or: $value.isAvailable),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  StorageLocationDtoCopyWith<$R2, StorageLocationDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _StorageLocationDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

