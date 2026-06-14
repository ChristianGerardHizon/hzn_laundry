// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'feature_flag.dart';

class FeatureFlagMapper extends ClassMapperBase<FeatureFlag> {
  FeatureFlagMapper._();

  static FeatureFlagMapper? _instance;
  static FeatureFlagMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FeatureFlagMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FeatureFlag';

  static String _$id(FeatureFlag v) => v.id;
  static const Field<FeatureFlag, String> _f$id = Field('id', _$id);
  static String _$key(FeatureFlag v) => v.key;
  static const Field<FeatureFlag, String> _f$key = Field('key', _$key);
  static bool _$enabled(FeatureFlag v) => v.enabled;
  static const Field<FeatureFlag, bool> _f$enabled = Field(
    'enabled',
    _$enabled,
  );
  static String? _$description(FeatureFlag v) => v.description;
  static const Field<FeatureFlag, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );

  @override
  final MappableFields<FeatureFlag> fields = const {
    #id: _f$id,
    #key: _f$key,
    #enabled: _f$enabled,
    #description: _f$description,
  };

  static FeatureFlag _instantiate(DecodingData data) {
    return FeatureFlag(
      id: data.dec(_f$id),
      key: data.dec(_f$key),
      enabled: data.dec(_f$enabled),
      description: data.dec(_f$description),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FeatureFlag fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FeatureFlag>(map);
  }

  static FeatureFlag fromJson(String json) {
    return ensureInitialized().decodeJson<FeatureFlag>(json);
  }
}

mixin FeatureFlagMappable {
  String toJson() {
    return FeatureFlagMapper.ensureInitialized().encodeJson<FeatureFlag>(
      this as FeatureFlag,
    );
  }

  Map<String, dynamic> toMap() {
    return FeatureFlagMapper.ensureInitialized().encodeMap<FeatureFlag>(
      this as FeatureFlag,
    );
  }

  FeatureFlagCopyWith<FeatureFlag, FeatureFlag, FeatureFlag> get copyWith =>
      _FeatureFlagCopyWithImpl<FeatureFlag, FeatureFlag>(
        this as FeatureFlag,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FeatureFlagMapper.ensureInitialized().stringifyValue(
      this as FeatureFlag,
    );
  }

  @override
  bool operator ==(Object other) {
    return FeatureFlagMapper.ensureInitialized().equalsValue(
      this as FeatureFlag,
      other,
    );
  }

  @override
  int get hashCode {
    return FeatureFlagMapper.ensureInitialized().hashValue(this as FeatureFlag);
  }
}

extension FeatureFlagValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FeatureFlag, $Out> {
  FeatureFlagCopyWith<$R, FeatureFlag, $Out> get $asFeatureFlag =>
      $base.as((v, t, t2) => _FeatureFlagCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FeatureFlagCopyWith<$R, $In extends FeatureFlag, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? key, bool? enabled, String? description});
  FeatureFlagCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _FeatureFlagCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FeatureFlag, $Out>
    implements FeatureFlagCopyWith<$R, FeatureFlag, $Out> {
  _FeatureFlagCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FeatureFlag> $mapper =
      FeatureFlagMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? key,
    bool? enabled,
    Object? description = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (key != null) #key: key,
      if (enabled != null) #enabled: enabled,
      if (description != $none) #description: description,
    }),
  );
  @override
  FeatureFlag $make(CopyWithData data) => FeatureFlag(
    id: data.get(#id, or: $value.id),
    key: data.get(#key, or: $value.key),
    enabled: data.get(#enabled, or: $value.enabled),
    description: data.get(#description, or: $value.description),
  );

  @override
  FeatureFlagCopyWith<$R2, FeatureFlag, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FeatureFlagCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

