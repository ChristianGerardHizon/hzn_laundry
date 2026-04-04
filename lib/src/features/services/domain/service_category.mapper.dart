// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'service_category.dart';

class ServiceCategoryMapper extends ClassMapperBase<ServiceCategory> {
  ServiceCategoryMapper._();

  static ServiceCategoryMapper? _instance;
  static ServiceCategoryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ServiceCategoryMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ServiceCategory';

  static String _$id(ServiceCategory v) => v.id;
  static const Field<ServiceCategory, String> _f$id = Field('id', _$id);
  static String _$name(ServiceCategory v) => v.name;
  static const Field<ServiceCategory, String> _f$name = Field('name', _$name);
  static bool _$isDeleted(ServiceCategory v) => v.isDeleted;
  static const Field<ServiceCategory, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(ServiceCategory v) => v.created;
  static const Field<ServiceCategory, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(ServiceCategory v) => v.updated;
  static const Field<ServiceCategory, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ServiceCategory> fields = const {
    #id: _f$id,
    #name: _f$name,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ServiceCategory _instantiate(DecodingData data) {
    return ServiceCategory(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ServiceCategory fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ServiceCategory>(map);
  }

  static ServiceCategory fromJson(String json) {
    return ensureInitialized().decodeJson<ServiceCategory>(json);
  }
}

mixin ServiceCategoryMappable {
  String toJson() {
    return ServiceCategoryMapper.ensureInitialized()
        .encodeJson<ServiceCategory>(this as ServiceCategory);
  }

  Map<String, dynamic> toMap() {
    return ServiceCategoryMapper.ensureInitialized().encodeMap<ServiceCategory>(
      this as ServiceCategory,
    );
  }

  ServiceCategoryCopyWith<ServiceCategory, ServiceCategory, ServiceCategory>
  get copyWith =>
      _ServiceCategoryCopyWithImpl<ServiceCategory, ServiceCategory>(
        this as ServiceCategory,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ServiceCategoryMapper.ensureInitialized().stringifyValue(
      this as ServiceCategory,
    );
  }

  @override
  bool operator ==(Object other) {
    return ServiceCategoryMapper.ensureInitialized().equalsValue(
      this as ServiceCategory,
      other,
    );
  }

  @override
  int get hashCode {
    return ServiceCategoryMapper.ensureInitialized().hashValue(
      this as ServiceCategory,
    );
  }
}

extension ServiceCategoryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ServiceCategory, $Out> {
  ServiceCategoryCopyWith<$R, ServiceCategory, $Out> get $asServiceCategory =>
      $base.as((v, t, t2) => _ServiceCategoryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ServiceCategoryCopyWith<$R, $In extends ServiceCategory, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  ServiceCategoryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ServiceCategoryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ServiceCategory, $Out>
    implements ServiceCategoryCopyWith<$R, ServiceCategory, $Out> {
  _ServiceCategoryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ServiceCategory> $mapper =
      ServiceCategoryMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ServiceCategory $make(CopyWithData data) => ServiceCategory(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ServiceCategoryCopyWith<$R2, ServiceCategory, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ServiceCategoryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

