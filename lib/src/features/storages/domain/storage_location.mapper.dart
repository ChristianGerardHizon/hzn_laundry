// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'storage_location.dart';

class StorageLocationMapper extends ClassMapperBase<StorageLocation> {
  StorageLocationMapper._();

  static StorageLocationMapper? _instance;
  static StorageLocationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StorageLocationMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'StorageLocation';

  static String _$id(StorageLocation v) => v.id;
  static const Field<StorageLocation, String> _f$id = Field('id', _$id);
  static String _$name(StorageLocation v) => v.name;
  static const Field<StorageLocation, String> _f$name = Field('name', _$name);
  static String? _$branchId(StorageLocation v) => v.branchId;
  static const Field<StorageLocation, String> _f$branchId = Field(
    'branchId',
    _$branchId,
    opt: true,
  );
  static bool _$isAvailable(StorageLocation v) => v.isAvailable;
  static const Field<StorageLocation, bool> _f$isAvailable = Field(
    'isAvailable',
    _$isAvailable,
    opt: true,
    def: true,
  );
  static bool _$isDeleted(StorageLocation v) => v.isDeleted;
  static const Field<StorageLocation, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(StorageLocation v) => v.created;
  static const Field<StorageLocation, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(StorageLocation v) => v.updated;
  static const Field<StorageLocation, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<StorageLocation> fields = const {
    #id: _f$id,
    #name: _f$name,
    #branchId: _f$branchId,
    #isAvailable: _f$isAvailable,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static StorageLocation _instantiate(DecodingData data) {
    return StorageLocation(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      branchId: data.dec(_f$branchId),
      isAvailable: data.dec(_f$isAvailable),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static StorageLocation fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StorageLocation>(map);
  }

  static StorageLocation fromJson(String json) {
    return ensureInitialized().decodeJson<StorageLocation>(json);
  }
}

mixin StorageLocationMappable {
  String toJson() {
    return StorageLocationMapper.ensureInitialized()
        .encodeJson<StorageLocation>(this as StorageLocation);
  }

  Map<String, dynamic> toMap() {
    return StorageLocationMapper.ensureInitialized().encodeMap<StorageLocation>(
      this as StorageLocation,
    );
  }

  StorageLocationCopyWith<StorageLocation, StorageLocation, StorageLocation>
  get copyWith =>
      _StorageLocationCopyWithImpl<StorageLocation, StorageLocation>(
        this as StorageLocation,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return StorageLocationMapper.ensureInitialized().stringifyValue(
      this as StorageLocation,
    );
  }

  @override
  bool operator ==(Object other) {
    return StorageLocationMapper.ensureInitialized().equalsValue(
      this as StorageLocation,
      other,
    );
  }

  @override
  int get hashCode {
    return StorageLocationMapper.ensureInitialized().hashValue(
      this as StorageLocation,
    );
  }
}

extension StorageLocationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StorageLocation, $Out> {
  StorageLocationCopyWith<$R, StorageLocation, $Out> get $asStorageLocation =>
      $base.as((v, t, t2) => _StorageLocationCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class StorageLocationCopyWith<$R, $In extends StorageLocation, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? branchId,
    bool? isAvailable,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  StorageLocationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _StorageLocationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StorageLocation, $Out>
    implements StorageLocationCopyWith<$R, StorageLocation, $Out> {
  _StorageLocationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StorageLocation> $mapper =
      StorageLocationMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    Object? branchId = $none,
    bool? isAvailable,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (branchId != $none) #branchId: branchId,
      if (isAvailable != null) #isAvailable: isAvailable,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  StorageLocation $make(CopyWithData data) => StorageLocation(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    branchId: data.get(#branchId, or: $value.branchId),
    isAvailable: data.get(#isAvailable, or: $value.isAvailable),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  StorageLocationCopyWith<$R2, StorageLocation, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _StorageLocationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

