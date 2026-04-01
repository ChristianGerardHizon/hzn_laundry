// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'promo_dto.dart';

class PromoDtoMapper extends ClassMapperBase<PromoDto> {
  PromoDtoMapper._();

  static PromoDtoMapper? _instance;
  static PromoDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PromoDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PromoDto';

  static String _$id(PromoDto v) => v.id;
  static const Field<PromoDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(PromoDto v) => v.collectionId;
  static const Field<PromoDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(PromoDto v) => v.collectionName;
  static const Field<PromoDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(PromoDto v) => v.name;
  static const Field<PromoDto, String> _f$name = Field('name', _$name);
  static String? _$description(PromoDto v) => v.description;
  static const Field<PromoDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static String? _$startDate(PromoDto v) => v.startDate;
  static const Field<PromoDto, String> _f$startDate = Field(
    'startDate',
    _$startDate,
    opt: true,
  );
  static String? _$endDate(PromoDto v) => v.endDate;
  static const Field<PromoDto, String> _f$endDate = Field(
    'endDate',
    _$endDate,
    opt: true,
  );
  static int _$requiredOrders(PromoDto v) => v.requiredOrders;
  static const Field<PromoDto, int> _f$requiredOrders = Field(
    'requiredOrders',
    _$requiredOrders,
    opt: true,
    def: 0,
  );
  static num _$rewardFreeWeight(PromoDto v) => v.rewardFreeWeight;
  static const Field<PromoDto, num> _f$rewardFreeWeight = Field(
    'rewardFreeWeight',
    _$rewardFreeWeight,
    opt: true,
    def: 0,
  );
  static bool _$isActive(PromoDto v) => v.isActive;
  static const Field<PromoDto, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static String? _$branch(PromoDto v) => v.branch;
  static const Field<PromoDto, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static bool _$isDeleted(PromoDto v) => v.isDeleted;
  static const Field<PromoDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(PromoDto v) => v.created;
  static const Field<PromoDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(PromoDto v) => v.updated;
  static const Field<PromoDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<PromoDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #description: _f$description,
    #startDate: _f$startDate,
    #endDate: _f$endDate,
    #requiredOrders: _f$requiredOrders,
    #rewardFreeWeight: _f$rewardFreeWeight,
    #isActive: _f$isActive,
    #branch: _f$branch,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static PromoDto _instantiate(DecodingData data) {
    return PromoDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      startDate: data.dec(_f$startDate),
      endDate: data.dec(_f$endDate),
      requiredOrders: data.dec(_f$requiredOrders),
      rewardFreeWeight: data.dec(_f$rewardFreeWeight),
      isActive: data.dec(_f$isActive),
      branch: data.dec(_f$branch),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PromoDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PromoDto>(map);
  }

  static PromoDto fromJson(String json) {
    return ensureInitialized().decodeJson<PromoDto>(json);
  }
}

mixin PromoDtoMappable {
  String toJson() {
    return PromoDtoMapper.ensureInitialized().encodeJson<PromoDto>(
      this as PromoDto,
    );
  }

  Map<String, dynamic> toMap() {
    return PromoDtoMapper.ensureInitialized().encodeMap<PromoDto>(
      this as PromoDto,
    );
  }

  PromoDtoCopyWith<PromoDto, PromoDto, PromoDto> get copyWith =>
      _PromoDtoCopyWithImpl<PromoDto, PromoDto>(
        this as PromoDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PromoDtoMapper.ensureInitialized().stringifyValue(this as PromoDto);
  }

  @override
  bool operator ==(Object other) {
    return PromoDtoMapper.ensureInitialized().equalsValue(
      this as PromoDto,
      other,
    );
  }

  @override
  int get hashCode {
    return PromoDtoMapper.ensureInitialized().hashValue(this as PromoDto);
  }
}

extension PromoDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, PromoDto, $Out> {
  PromoDtoCopyWith<$R, PromoDto, $Out> get $asPromoDto =>
      $base.as((v, t, t2) => _PromoDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PromoDtoCopyWith<$R, $In extends PromoDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? description,
    String? startDate,
    String? endDate,
    int? requiredOrders,
    num? rewardFreeWeight,
    bool? isActive,
    String? branch,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  PromoDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PromoDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PromoDto, $Out>
    implements PromoDtoCopyWith<$R, PromoDto, $Out> {
  _PromoDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PromoDto> $mapper =
      PromoDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    Object? description = $none,
    Object? startDate = $none,
    Object? endDate = $none,
    int? requiredOrders,
    num? rewardFreeWeight,
    bool? isActive,
    Object? branch = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (description != $none) #description: description,
      if (startDate != $none) #startDate: startDate,
      if (endDate != $none) #endDate: endDate,
      if (requiredOrders != null) #requiredOrders: requiredOrders,
      if (rewardFreeWeight != null) #rewardFreeWeight: rewardFreeWeight,
      if (isActive != null) #isActive: isActive,
      if (branch != $none) #branch: branch,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  PromoDto $make(CopyWithData data) => PromoDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    startDate: data.get(#startDate, or: $value.startDate),
    endDate: data.get(#endDate, or: $value.endDate),
    requiredOrders: data.get(#requiredOrders, or: $value.requiredOrders),
    rewardFreeWeight: data.get(#rewardFreeWeight, or: $value.rewardFreeWeight),
    isActive: data.get(#isActive, or: $value.isActive),
    branch: data.get(#branch, or: $value.branch),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  PromoDtoCopyWith<$R2, PromoDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PromoDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

