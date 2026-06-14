// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'feature_flag_dto.dart';

class FeatureFlagDtoMapper extends ClassMapperBase<FeatureFlagDto> {
  FeatureFlagDtoMapper._();

  static FeatureFlagDtoMapper? _instance;
  static FeatureFlagDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FeatureFlagDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FeatureFlagDto';

  static String _$id(FeatureFlagDto v) => v.id;
  static const Field<FeatureFlagDto, String> _f$id = Field('id', _$id);
  static String _$key(FeatureFlagDto v) => v.key;
  static const Field<FeatureFlagDto, String> _f$key = Field('key', _$key);
  static bool _$enabled(FeatureFlagDto v) => v.enabled;
  static const Field<FeatureFlagDto, bool> _f$enabled = Field(
    'enabled',
    _$enabled,
  );
  static String? _$description(FeatureFlagDto v) => v.description;
  static const Field<FeatureFlagDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );

  @override
  final MappableFields<FeatureFlagDto> fields = const {
    #id: _f$id,
    #key: _f$key,
    #enabled: _f$enabled,
    #description: _f$description,
  };

  static FeatureFlagDto _instantiate(DecodingData data) {
    return FeatureFlagDto(
      id: data.dec(_f$id),
      key: data.dec(_f$key),
      enabled: data.dec(_f$enabled),
      description: data.dec(_f$description),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FeatureFlagDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FeatureFlagDto>(map);
  }

  static FeatureFlagDto fromJson(String json) {
    return ensureInitialized().decodeJson<FeatureFlagDto>(json);
  }
}

mixin FeatureFlagDtoMappable {
  String toJson() {
    return FeatureFlagDtoMapper.ensureInitialized().encodeJson<FeatureFlagDto>(
      this as FeatureFlagDto,
    );
  }

  Map<String, dynamic> toMap() {
    return FeatureFlagDtoMapper.ensureInitialized().encodeMap<FeatureFlagDto>(
      this as FeatureFlagDto,
    );
  }

  FeatureFlagDtoCopyWith<FeatureFlagDto, FeatureFlagDto, FeatureFlagDto>
  get copyWith => _FeatureFlagDtoCopyWithImpl<FeatureFlagDto, FeatureFlagDto>(
    this as FeatureFlagDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return FeatureFlagDtoMapper.ensureInitialized().stringifyValue(
      this as FeatureFlagDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return FeatureFlagDtoMapper.ensureInitialized().equalsValue(
      this as FeatureFlagDto,
      other,
    );
  }

  @override
  int get hashCode {
    return FeatureFlagDtoMapper.ensureInitialized().hashValue(
      this as FeatureFlagDto,
    );
  }
}

extension FeatureFlagDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FeatureFlagDto, $Out> {
  FeatureFlagDtoCopyWith<$R, FeatureFlagDto, $Out> get $asFeatureFlagDto =>
      $base.as((v, t, t2) => _FeatureFlagDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FeatureFlagDtoCopyWith<$R, $In extends FeatureFlagDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? key, bool? enabled, String? description});
  FeatureFlagDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FeatureFlagDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FeatureFlagDto, $Out>
    implements FeatureFlagDtoCopyWith<$R, FeatureFlagDto, $Out> {
  _FeatureFlagDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FeatureFlagDto> $mapper =
      FeatureFlagDtoMapper.ensureInitialized();
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
  FeatureFlagDto $make(CopyWithData data) => FeatureFlagDto(
    id: data.get(#id, or: $value.id),
    key: data.get(#key, or: $value.key),
    enabled: data.get(#enabled, or: $value.enabled),
    description: data.get(#description, or: $value.description),
  );

  @override
  FeatureFlagDtoCopyWith<$R2, FeatureFlagDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FeatureFlagDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

