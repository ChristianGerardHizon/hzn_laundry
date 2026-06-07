// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'load_rule_dto.dart';

class LoadRuleDtoMapper extends ClassMapperBase<LoadRuleDto> {
  LoadRuleDtoMapper._();

  static LoadRuleDtoMapper? _instance;
  static LoadRuleDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LoadRuleDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LoadRuleDto';

  static String _$id(LoadRuleDto v) => v.id;
  static const Field<LoadRuleDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(LoadRuleDto v) => v.collectionId;
  static const Field<LoadRuleDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(LoadRuleDto v) => v.collectionName;
  static const Field<LoadRuleDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$machine(LoadRuleDto v) => v.machine;
  static const Field<LoadRuleDto, String> _f$machine = Field(
    'machine',
    _$machine,
  );
  static num _$loadCount(LoadRuleDto v) => v.loadCount;
  static const Field<LoadRuleDto, num> _f$loadCount = Field(
    'loadCount',
    _$loadCount,
  );
  static num? _$minWeight(LoadRuleDto v) => v.minWeight;
  static const Field<LoadRuleDto, num> _f$minWeight = Field(
    'minWeight',
    _$minWeight,
    opt: true,
  );
  static num? _$maxWeight(LoadRuleDto v) => v.maxWeight;
  static const Field<LoadRuleDto, num> _f$maxWeight = Field(
    'maxWeight',
    _$maxWeight,
    opt: true,
  );
  static bool _$isDeleted(LoadRuleDto v) => v.isDeleted;
  static const Field<LoadRuleDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(LoadRuleDto v) => v.created;
  static const Field<LoadRuleDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(LoadRuleDto v) => v.updated;
  static const Field<LoadRuleDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<LoadRuleDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #machine: _f$machine,
    #loadCount: _f$loadCount,
    #minWeight: _f$minWeight,
    #maxWeight: _f$maxWeight,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static LoadRuleDto _instantiate(DecodingData data) {
    return LoadRuleDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      machine: data.dec(_f$machine),
      loadCount: data.dec(_f$loadCount),
      minWeight: data.dec(_f$minWeight),
      maxWeight: data.dec(_f$maxWeight),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LoadRuleDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LoadRuleDto>(map);
  }

  static LoadRuleDto fromJson(String json) {
    return ensureInitialized().decodeJson<LoadRuleDto>(json);
  }
}

mixin LoadRuleDtoMappable {
  String toJson() {
    return LoadRuleDtoMapper.ensureInitialized().encodeJson<LoadRuleDto>(
      this as LoadRuleDto,
    );
  }

  Map<String, dynamic> toMap() {
    return LoadRuleDtoMapper.ensureInitialized().encodeMap<LoadRuleDto>(
      this as LoadRuleDto,
    );
  }

  LoadRuleDtoCopyWith<LoadRuleDto, LoadRuleDto, LoadRuleDto> get copyWith =>
      _LoadRuleDtoCopyWithImpl<LoadRuleDto, LoadRuleDto>(
        this as LoadRuleDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LoadRuleDtoMapper.ensureInitialized().stringifyValue(
      this as LoadRuleDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return LoadRuleDtoMapper.ensureInitialized().equalsValue(
      this as LoadRuleDto,
      other,
    );
  }

  @override
  int get hashCode {
    return LoadRuleDtoMapper.ensureInitialized().hashValue(this as LoadRuleDto);
  }
}

extension LoadRuleDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LoadRuleDto, $Out> {
  LoadRuleDtoCopyWith<$R, LoadRuleDto, $Out> get $asLoadRuleDto =>
      $base.as((v, t, t2) => _LoadRuleDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LoadRuleDtoCopyWith<$R, $In extends LoadRuleDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? machine,
    num? loadCount,
    num? minWeight,
    num? maxWeight,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  LoadRuleDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LoadRuleDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LoadRuleDto, $Out>
    implements LoadRuleDtoCopyWith<$R, LoadRuleDto, $Out> {
  _LoadRuleDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LoadRuleDto> $mapper =
      LoadRuleDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? machine,
    num? loadCount,
    Object? minWeight = $none,
    Object? maxWeight = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (machine != null) #machine: machine,
      if (loadCount != null) #loadCount: loadCount,
      if (minWeight != $none) #minWeight: minWeight,
      if (maxWeight != $none) #maxWeight: maxWeight,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  LoadRuleDto $make(CopyWithData data) => LoadRuleDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    machine: data.get(#machine, or: $value.machine),
    loadCount: data.get(#loadCount, or: $value.loadCount),
    minWeight: data.get(#minWeight, or: $value.minWeight),
    maxWeight: data.get(#maxWeight, or: $value.maxWeight),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  LoadRuleDtoCopyWith<$R2, LoadRuleDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LoadRuleDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

