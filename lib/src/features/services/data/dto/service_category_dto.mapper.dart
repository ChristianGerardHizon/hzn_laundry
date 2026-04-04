// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'service_category_dto.dart';

class ServiceCategoryDtoMapper extends ClassMapperBase<ServiceCategoryDto> {
  ServiceCategoryDtoMapper._();

  static ServiceCategoryDtoMapper? _instance;
  static ServiceCategoryDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServiceCategoryDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ServiceCategoryDto';

  static String _$id(ServiceCategoryDto v) => v.id;
  static const Field<ServiceCategoryDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(ServiceCategoryDto v) => v.collectionId;
  static const Field<ServiceCategoryDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(ServiceCategoryDto v) => v.collectionName;
  static const Field<ServiceCategoryDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(ServiceCategoryDto v) => v.name;
  static const Field<ServiceCategoryDto, String> _f$name = Field(
    'name',
    _$name,
  );
  static bool _$isDeleted(ServiceCategoryDto v) => v.isDeleted;
  static const Field<ServiceCategoryDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(ServiceCategoryDto v) => v.created;
  static const Field<ServiceCategoryDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(ServiceCategoryDto v) => v.updated;
  static const Field<ServiceCategoryDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ServiceCategoryDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ServiceCategoryDto _instantiate(DecodingData data) {
    return ServiceCategoryDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServiceCategoryDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServiceCategoryDto>(map);
  }

  static ServiceCategoryDto fromJson(String json) {
    return ensureInitialized().decodeJson<ServiceCategoryDto>(json);
  }
}

mixin ServiceCategoryDtoMappable {
  String toJson() {
    return ServiceCategoryDtoMapper.ensureInitialized()
        .encodeJson<ServiceCategoryDto>(this as ServiceCategoryDto);
  }

  Map<String, dynamic> toMap() {
    return ServiceCategoryDtoMapper.ensureInitialized()
        .encodeMap<ServiceCategoryDto>(this as ServiceCategoryDto);
  }

  ServiceCategoryDtoCopyWith<
    ServiceCategoryDto,
    ServiceCategoryDto,
    ServiceCategoryDto
  >
  get copyWith =>
      _ServiceCategoryDtoCopyWithImpl<ServiceCategoryDto, ServiceCategoryDto>(
        this as ServiceCategoryDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ServiceCategoryDtoMapper.ensureInitialized().stringifyValue(
      this as ServiceCategoryDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServiceCategoryDtoMapper.ensureInitialized().equalsValue(
      this as ServiceCategoryDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ServiceCategoryDtoMapper.ensureInitialized().hashValue(
      this as ServiceCategoryDto,
    );
  }
}

extension ServiceCategoryDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServiceCategoryDto, $Out> {
  ServiceCategoryDtoCopyWith<$R, ServiceCategoryDto, $Out>
  get $asServiceCategoryDto => $base.as(
    (v, t, t2) => _ServiceCategoryDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ServiceCategoryDtoCopyWith<
  $R,
  $In extends ServiceCategoryDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  ServiceCategoryDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ServiceCategoryDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServiceCategoryDto, $Out>
    implements ServiceCategoryDtoCopyWith<$R, ServiceCategoryDto, $Out> {
  _ServiceCategoryDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServiceCategoryDto> $mapper =
      ServiceCategoryDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ServiceCategoryDto $make(CopyWithData data) => ServiceCategoryDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ServiceCategoryDtoCopyWith<$R2, ServiceCategoryDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServiceCategoryDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

