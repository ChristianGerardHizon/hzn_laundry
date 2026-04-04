// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'promo.dart';

class PromoMapper extends ClassMapperBase<Promo> {
  PromoMapper._();

  static PromoMapper? _instance;
  static PromoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PromoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Promo';

  static String _$id(Promo v) => v.id;
  static const Field<Promo, String> _f$id = Field('id', _$id);
  static String _$name(Promo v) => v.name;
  static const Field<Promo, String> _f$name = Field('name', _$name);
  static String? _$description(Promo v) => v.description;
  static const Field<Promo, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static DateTime _$startDate(Promo v) => v.startDate;
  static const Field<Promo, DateTime> _f$startDate = Field(
    'startDate',
    _$startDate,
  );
  static DateTime _$endDate(Promo v) => v.endDate;
  static const Field<Promo, DateTime> _f$endDate = Field('endDate', _$endDate);
  static int _$requiredOrders(Promo v) => v.requiredOrders;
  static const Field<Promo, int> _f$requiredOrders = Field(
    'requiredOrders',
    _$requiredOrders,
  );
  static num _$rewardFreeWeight(Promo v) => v.rewardFreeWeight;
  static const Field<Promo, num> _f$rewardFreeWeight = Field(
    'rewardFreeWeight',
    _$rewardFreeWeight,
  );
  static bool _$isActive(Promo v) => v.isActive;
  static const Field<Promo, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static String? _$branch(Promo v) => v.branch;
  static const Field<Promo, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static bool _$isDeleted(Promo v) => v.isDeleted;
  static const Field<Promo, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(Promo v) => v.created;
  static const Field<Promo, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Promo v) => v.updated;
  static const Field<Promo, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Promo> fields = const {
    #id: _f$id,
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

  static Promo _instantiate(DecodingData data) {
    return Promo(
      id: data.dec(_f$id),
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

  static Promo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Promo>(map);
  }

  static Promo fromJson(String json) {
    return ensureInitialized().decodeJson<Promo>(json);
  }
}

mixin PromoMappable {
  String toJson() {
    return PromoMapper.ensureInitialized().encodeJson<Promo>(this as Promo);
  }

  Map<String, dynamic> toMap() {
    return PromoMapper.ensureInitialized().encodeMap<Promo>(this as Promo);
  }

  PromoCopyWith<Promo, Promo, Promo> get copyWith =>
      _PromoCopyWithImpl<Promo, Promo>(this as Promo, $identity, $identity);
  @override
  String toString() {
    return PromoMapper.ensureInitialized().stringifyValue(this as Promo);
  }

  @override
  bool operator ==(Object other) {
    return PromoMapper.ensureInitialized().equalsValue(this as Promo, other);
  }

  @override
  int get hashCode {
    return PromoMapper.ensureInitialized().hashValue(this as Promo);
  }
}

extension PromoValueCopy<$R, $Out> on ObjectCopyWith<$R, Promo, $Out> {
  PromoCopyWith<$R, Promo, $Out> get $asPromo =>
      $base.as((v, t, t2) => _PromoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PromoCopyWith<$R, $In extends Promo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int? requiredOrders,
    num? rewardFreeWeight,
    bool? isActive,
    String? branch,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  PromoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PromoCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Promo, $Out>
    implements PromoCopyWith<$R, Promo, $Out> {
  _PromoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Promo> $mapper = PromoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    Object? description = $none,
    DateTime? startDate,
    DateTime? endDate,
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
      if (name != null) #name: name,
      if (description != $none) #description: description,
      if (startDate != null) #startDate: startDate,
      if (endDate != null) #endDate: endDate,
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
  Promo $make(CopyWithData data) => Promo(
    id: data.get(#id, or: $value.id),
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
  PromoCopyWith<$R2, Promo, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PromoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

