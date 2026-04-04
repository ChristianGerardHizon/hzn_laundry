// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'incentive_tier.dart';

class IncentiveTierMapper extends ClassMapperBase<IncentiveTier> {
  IncentiveTierMapper._();

  static IncentiveTierMapper? _instance;
  static IncentiveTierMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IncentiveTierMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'IncentiveTier';

  static String _$id(IncentiveTier v) => v.id;
  static const Field<IncentiveTier, String> _f$id = Field('id', _$id);
  static String _$branch(IncentiveTier v) => v.branch;
  static const Field<IncentiveTier, String> _f$branch = Field(
    'branch',
    _$branch,
  );
  static num _$minAmount(IncentiveTier v) => v.minAmount;
  static const Field<IncentiveTier, num> _f$minAmount = Field(
    'minAmount',
    _$minAmount,
  );
  static num? _$maxAmount(IncentiveTier v) => v.maxAmount;
  static const Field<IncentiveTier, num> _f$maxAmount = Field(
    'maxAmount',
    _$maxAmount,
    opt: true,
  );
  static num _$incentiveAmount(IncentiveTier v) => v.incentiveAmount;
  static const Field<IncentiveTier, num> _f$incentiveAmount = Field(
    'incentiveAmount',
    _$incentiveAmount,
  );
  static int _$sortOrder(IncentiveTier v) => v.sortOrder;
  static const Field<IncentiveTier, int> _f$sortOrder = Field(
    'sortOrder',
    _$sortOrder,
    opt: true,
    def: 0,
  );
  static DateTime? _$created(IncentiveTier v) => v.created;
  static const Field<IncentiveTier, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(IncentiveTier v) => v.updated;
  static const Field<IncentiveTier, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<IncentiveTier> fields = const {
    #id: _f$id,
    #branch: _f$branch,
    #minAmount: _f$minAmount,
    #maxAmount: _f$maxAmount,
    #incentiveAmount: _f$incentiveAmount,
    #sortOrder: _f$sortOrder,
    #created: _f$created,
    #updated: _f$updated,
  };

  static IncentiveTier _instantiate(DecodingData data) {
    return IncentiveTier(
      id: data.dec(_f$id),
      branch: data.dec(_f$branch),
      minAmount: data.dec(_f$minAmount),
      maxAmount: data.dec(_f$maxAmount),
      incentiveAmount: data.dec(_f$incentiveAmount),
      sortOrder: data.dec(_f$sortOrder),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static IncentiveTier fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IncentiveTier>(map);
  }

  static IncentiveTier fromJson(String json) {
    return ensureInitialized().decodeJson<IncentiveTier>(json);
  }
}

mixin IncentiveTierMappable {
  String toJson() {
    return IncentiveTierMapper.ensureInitialized().encodeJson<IncentiveTier>(
      this as IncentiveTier,
    );
  }

  Map<String, dynamic> toMap() {
    return IncentiveTierMapper.ensureInitialized().encodeMap<IncentiveTier>(
      this as IncentiveTier,
    );
  }

  IncentiveTierCopyWith<IncentiveTier, IncentiveTier, IncentiveTier>
  get copyWith => _IncentiveTierCopyWithImpl<IncentiveTier, IncentiveTier>(
    this as IncentiveTier,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return IncentiveTierMapper.ensureInitialized().stringifyValue(
      this as IncentiveTier,
    );
  }

  @override
  bool operator ==(Object other) {
    return IncentiveTierMapper.ensureInitialized().equalsValue(
      this as IncentiveTier,
      other,
    );
  }

  @override
  int get hashCode {
    return IncentiveTierMapper.ensureInitialized().hashValue(
      this as IncentiveTier,
    );
  }
}

extension IncentiveTierValueCopy<$R, $Out>
    on ObjectCopyWith<$R, IncentiveTier, $Out> {
  IncentiveTierCopyWith<$R, IncentiveTier, $Out> get $asIncentiveTier =>
      $base.as((v, t, t2) => _IncentiveTierCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IncentiveTierCopyWith<$R, $In extends IncentiveTier, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? branch,
    num? minAmount,
    num? maxAmount,
    num? incentiveAmount,
    int? sortOrder,
    DateTime? created,
    DateTime? updated,
  });
  IncentiveTierCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IncentiveTierCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, IncentiveTier, $Out>
    implements IncentiveTierCopyWith<$R, IncentiveTier, $Out> {
  _IncentiveTierCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<IncentiveTier> $mapper =
      IncentiveTierMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? branch,
    num? minAmount,
    Object? maxAmount = $none,
    num? incentiveAmount,
    int? sortOrder,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (branch != null) #branch: branch,
      if (minAmount != null) #minAmount: minAmount,
      if (maxAmount != $none) #maxAmount: maxAmount,
      if (incentiveAmount != null) #incentiveAmount: incentiveAmount,
      if (sortOrder != null) #sortOrder: sortOrder,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  IncentiveTier $make(CopyWithData data) => IncentiveTier(
    id: data.get(#id, or: $value.id),
    branch: data.get(#branch, or: $value.branch),
    minAmount: data.get(#minAmount, or: $value.minAmount),
    maxAmount: data.get(#maxAmount, or: $value.maxAmount),
    incentiveAmount: data.get(#incentiveAmount, or: $value.incentiveAmount),
    sortOrder: data.get(#sortOrder, or: $value.sortOrder),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  IncentiveTierCopyWith<$R2, IncentiveTier, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _IncentiveTierCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

