// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'delivery_rate.dart';

class DeliveryRateMapper extends ClassMapperBase<DeliveryRate> {
  DeliveryRateMapper._();

  static DeliveryRateMapper? _instance;
  static DeliveryRateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DeliveryRateMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DeliveryRate';

  static String _$id(DeliveryRate v) => v.id;
  static const Field<DeliveryRate, String> _f$id = Field('id', _$id);
  static String _$branchId(DeliveryRate v) => v.branchId;
  static const Field<DeliveryRate, String> _f$branchId = Field(
    'branchId',
    _$branchId,
  );
  static String _$name(DeliveryRate v) => v.name;
  static const Field<DeliveryRate, String> _f$name = Field('name', _$name);
  static num _$baseFee(DeliveryRate v) => v.baseFee;
  static const Field<DeliveryRate, num> _f$baseFee = Field(
    'baseFee',
    _$baseFee,
    opt: true,
    def: 0,
  );
  static num _$includedKm(DeliveryRate v) => v.includedKm;
  static const Field<DeliveryRate, num> _f$includedKm = Field(
    'includedKm',
    _$includedKm,
    opt: true,
    def: 0,
  );
  static num _$ratePerKm(DeliveryRate v) => v.ratePerKm;
  static const Field<DeliveryRate, num> _f$ratePerKm = Field(
    'ratePerKm',
    _$ratePerKm,
    opt: true,
    def: 0,
  );
  static bool _$isDefault(DeliveryRate v) => v.isDefault;
  static const Field<DeliveryRate, bool> _f$isDefault = Field(
    'isDefault',
    _$isDefault,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<DeliveryRate> fields = const {
    #id: _f$id,
    #branchId: _f$branchId,
    #name: _f$name,
    #baseFee: _f$baseFee,
    #includedKm: _f$includedKm,
    #ratePerKm: _f$ratePerKm,
    #isDefault: _f$isDefault,
  };

  static DeliveryRate _instantiate(DecodingData data) {
    return DeliveryRate(
      id: data.dec(_f$id),
      branchId: data.dec(_f$branchId),
      name: data.dec(_f$name),
      baseFee: data.dec(_f$baseFee),
      includedKm: data.dec(_f$includedKm),
      ratePerKm: data.dec(_f$ratePerKm),
      isDefault: data.dec(_f$isDefault),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DeliveryRate fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DeliveryRate>(map);
  }

  static DeliveryRate fromJson(String json) {
    return ensureInitialized().decodeJson<DeliveryRate>(json);
  }
}

mixin DeliveryRateMappable {
  String toJson() {
    return DeliveryRateMapper.ensureInitialized().encodeJson<DeliveryRate>(
      this as DeliveryRate,
    );
  }

  Map<String, dynamic> toMap() {
    return DeliveryRateMapper.ensureInitialized().encodeMap<DeliveryRate>(
      this as DeliveryRate,
    );
  }

  DeliveryRateCopyWith<DeliveryRate, DeliveryRate, DeliveryRate> get copyWith =>
      _DeliveryRateCopyWithImpl<DeliveryRate, DeliveryRate>(
        this as DeliveryRate,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DeliveryRateMapper.ensureInitialized().stringifyValue(
      this as DeliveryRate,
    );
  }

  @override
  bool operator ==(Object other) {
    return DeliveryRateMapper.ensureInitialized().equalsValue(
      this as DeliveryRate,
      other,
    );
  }

  @override
  int get hashCode {
    return DeliveryRateMapper.ensureInitialized().hashValue(
      this as DeliveryRate,
    );
  }
}

extension DeliveryRateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DeliveryRate, $Out> {
  DeliveryRateCopyWith<$R, DeliveryRate, $Out> get $asDeliveryRate =>
      $base.as((v, t, t2) => _DeliveryRateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DeliveryRateCopyWith<$R, $In extends DeliveryRate, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? branchId,
    String? name,
    num? baseFee,
    num? includedKm,
    num? ratePerKm,
    bool? isDefault,
  });
  DeliveryRateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DeliveryRateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DeliveryRate, $Out>
    implements DeliveryRateCopyWith<$R, DeliveryRate, $Out> {
  _DeliveryRateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DeliveryRate> $mapper =
      DeliveryRateMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? branchId,
    String? name,
    num? baseFee,
    num? includedKm,
    num? ratePerKm,
    bool? isDefault,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (branchId != null) #branchId: branchId,
      if (name != null) #name: name,
      if (baseFee != null) #baseFee: baseFee,
      if (includedKm != null) #includedKm: includedKm,
      if (ratePerKm != null) #ratePerKm: ratePerKm,
      if (isDefault != null) #isDefault: isDefault,
    }),
  );
  @override
  DeliveryRate $make(CopyWithData data) => DeliveryRate(
    id: data.get(#id, or: $value.id),
    branchId: data.get(#branchId, or: $value.branchId),
    name: data.get(#name, or: $value.name),
    baseFee: data.get(#baseFee, or: $value.baseFee),
    includedKm: data.get(#includedKm, or: $value.includedKm),
    ratePerKm: data.get(#ratePerKm, or: $value.ratePerKm),
    isDefault: data.get(#isDefault, or: $value.isDefault),
  );

  @override
  DeliveryRateCopyWith<$R2, DeliveryRate, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DeliveryRateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

