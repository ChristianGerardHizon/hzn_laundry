// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'incentive_tier_dto.dart';

class IncentiveTierDtoMapper extends ClassMapperBase<IncentiveTierDto> {
  IncentiveTierDtoMapper._();

  static IncentiveTierDtoMapper? _instance;
  static IncentiveTierDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IncentiveTierDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'IncentiveTierDto';

  static String _$id(IncentiveTierDto v) => v.id;
  static const Field<IncentiveTierDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(IncentiveTierDto v) => v.collectionId;
  static const Field<IncentiveTierDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(IncentiveTierDto v) => v.collectionName;
  static const Field<IncentiveTierDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$branch(IncentiveTierDto v) => v.branch;
  static const Field<IncentiveTierDto, String> _f$branch = Field(
    'branch',
    _$branch,
  );
  static num _$minAmount(IncentiveTierDto v) => v.minAmount;
  static const Field<IncentiveTierDto, num> _f$minAmount = Field(
    'minAmount',
    _$minAmount,
  );
  static num? _$maxAmount(IncentiveTierDto v) => v.maxAmount;
  static const Field<IncentiveTierDto, num> _f$maxAmount = Field(
    'maxAmount',
    _$maxAmount,
    opt: true,
  );
  static num _$incentiveAmount(IncentiveTierDto v) => v.incentiveAmount;
  static const Field<IncentiveTierDto, num> _f$incentiveAmount = Field(
    'incentiveAmount',
    _$incentiveAmount,
  );
  static int _$sortOrder(IncentiveTierDto v) => v.sortOrder;
  static const Field<IncentiveTierDto, int> _f$sortOrder = Field(
    'sortOrder',
    _$sortOrder,
    opt: true,
    def: 0,
  );
  static String? _$created(IncentiveTierDto v) => v.created;
  static const Field<IncentiveTierDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(IncentiveTierDto v) => v.updated;
  static const Field<IncentiveTierDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<IncentiveTierDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #branch: _f$branch,
    #minAmount: _f$minAmount,
    #maxAmount: _f$maxAmount,
    #incentiveAmount: _f$incentiveAmount,
    #sortOrder: _f$sortOrder,
    #created: _f$created,
    #updated: _f$updated,
  };

  static IncentiveTierDto _instantiate(DecodingData data) {
    return IncentiveTierDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
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

  static IncentiveTierDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IncentiveTierDto>(map);
  }

  static IncentiveTierDto fromJson(String json) {
    return ensureInitialized().decodeJson<IncentiveTierDto>(json);
  }
}

mixin IncentiveTierDtoMappable {
  String toJson() {
    return IncentiveTierDtoMapper.ensureInitialized()
        .encodeJson<IncentiveTierDto>(this as IncentiveTierDto);
  }

  Map<String, dynamic> toMap() {
    return IncentiveTierDtoMapper.ensureInitialized()
        .encodeMap<IncentiveTierDto>(this as IncentiveTierDto);
  }

  IncentiveTierDtoCopyWith<IncentiveTierDto, IncentiveTierDto, IncentiveTierDto>
  get copyWith =>
      _IncentiveTierDtoCopyWithImpl<IncentiveTierDto, IncentiveTierDto>(
        this as IncentiveTierDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return IncentiveTierDtoMapper.ensureInitialized().stringifyValue(
      this as IncentiveTierDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return IncentiveTierDtoMapper.ensureInitialized().equalsValue(
      this as IncentiveTierDto,
      other,
    );
  }

  @override
  int get hashCode {
    return IncentiveTierDtoMapper.ensureInitialized().hashValue(
      this as IncentiveTierDto,
    );
  }
}

extension IncentiveTierDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, IncentiveTierDto, $Out> {
  IncentiveTierDtoCopyWith<$R, IncentiveTierDto, $Out>
  get $asIncentiveTierDto =>
      $base.as((v, t, t2) => _IncentiveTierDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IncentiveTierDtoCopyWith<$R, $In extends IncentiveTierDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? branch,
    num? minAmount,
    num? maxAmount,
    num? incentiveAmount,
    int? sortOrder,
    String? created,
    String? updated,
  });
  IncentiveTierDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _IncentiveTierDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, IncentiveTierDto, $Out>
    implements IncentiveTierDtoCopyWith<$R, IncentiveTierDto, $Out> {
  _IncentiveTierDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<IncentiveTierDto> $mapper =
      IncentiveTierDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
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
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
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
  IncentiveTierDto $make(CopyWithData data) => IncentiveTierDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    branch: data.get(#branch, or: $value.branch),
    minAmount: data.get(#minAmount, or: $value.minAmount),
    maxAmount: data.get(#maxAmount, or: $value.maxAmount),
    incentiveAmount: data.get(#incentiveAmount, or: $value.incentiveAmount),
    sortOrder: data.get(#sortOrder, or: $value.sortOrder),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  IncentiveTierDtoCopyWith<$R2, IncentiveTierDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _IncentiveTierDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

