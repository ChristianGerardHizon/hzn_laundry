// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'app_config.dart';

class AppConfigMapper extends ClassMapperBase<AppConfig> {
  AppConfigMapper._();

  static AppConfigMapper? _instance;
  static AppConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppConfigMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AppConfig';

  static String _$id(AppConfig v) => v.id;
  static const Field<AppConfig, String> _f$id = Field('id', _$id);
  static int _$major(AppConfig v) => v.major;
  static const Field<AppConfig, int> _f$major = Field('major', _$major);
  static int _$minor(AppConfig v) => v.minor;
  static const Field<AppConfig, int> _f$minor = Field('minor', _$minor);
  static int _$patch(AppConfig v) => v.patch;
  static const Field<AppConfig, int> _f$patch = Field('patch', _$patch);
  static int _$minimumMajor(AppConfig v) => v.minimumMajor;
  static const Field<AppConfig, int> _f$minimumMajor = Field(
    'minimumMajor',
    _$minimumMajor,
  );
  static int _$minimumMinor(AppConfig v) => v.minimumMinor;
  static const Field<AppConfig, int> _f$minimumMinor = Field(
    'minimumMinor',
    _$minimumMinor,
  );
  static int _$minimumPatch(AppConfig v) => v.minimumPatch;
  static const Field<AppConfig, int> _f$minimumPatch = Field(
    'minimumPatch',
    _$minimumPatch,
  );
  static int _$buildNumber(AppConfig v) => v.buildNumber;
  static const Field<AppConfig, int> _f$buildNumber = Field(
    'buildNumber',
    _$buildNumber,
  );

  @override
  final MappableFields<AppConfig> fields = const {
    #id: _f$id,
    #major: _f$major,
    #minor: _f$minor,
    #patch: _f$patch,
    #minimumMajor: _f$minimumMajor,
    #minimumMinor: _f$minimumMinor,
    #minimumPatch: _f$minimumPatch,
    #buildNumber: _f$buildNumber,
  };

  static AppConfig _instantiate(DecodingData data) {
    return AppConfig(
      id: data.dec(_f$id),
      major: data.dec(_f$major),
      minor: data.dec(_f$minor),
      patch: data.dec(_f$patch),
      minimumMajor: data.dec(_f$minimumMajor),
      minimumMinor: data.dec(_f$minimumMinor),
      minimumPatch: data.dec(_f$minimumPatch),
      buildNumber: data.dec(_f$buildNumber),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AppConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppConfig>(map);
  }

  static AppConfig fromJson(String json) {
    return ensureInitialized().decodeJson<AppConfig>(json);
  }
}

mixin AppConfigMappable {
  String toJson() {
    return AppConfigMapper.ensureInitialized().encodeJson<AppConfig>(
      this as AppConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return AppConfigMapper.ensureInitialized().encodeMap<AppConfig>(
      this as AppConfig,
    );
  }

  AppConfigCopyWith<AppConfig, AppConfig, AppConfig> get copyWith =>
      _AppConfigCopyWithImpl<AppConfig, AppConfig>(
        this as AppConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AppConfigMapper.ensureInitialized().stringifyValue(
      this as AppConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return AppConfigMapper.ensureInitialized().equalsValue(
      this as AppConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return AppConfigMapper.ensureInitialized().hashValue(this as AppConfig);
  }
}

extension AppConfigValueCopy<$R, $Out> on ObjectCopyWith<$R, AppConfig, $Out> {
  AppConfigCopyWith<$R, AppConfig, $Out> get $asAppConfig =>
      $base.as((v, t, t2) => _AppConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AppConfigCopyWith<$R, $In extends AppConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    int? major,
    int? minor,
    int? patch,
    int? minimumMajor,
    int? minimumMinor,
    int? minimumPatch,
    int? buildNumber,
  });
  AppConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AppConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppConfig, $Out>
    implements AppConfigCopyWith<$R, AppConfig, $Out> {
  _AppConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppConfig> $mapper =
      AppConfigMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    int? major,
    int? minor,
    int? patch,
    int? minimumMajor,
    int? minimumMinor,
    int? minimumPatch,
    int? buildNumber,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (major != null) #major: major,
      if (minor != null) #minor: minor,
      if (patch != null) #patch: patch,
      if (minimumMajor != null) #minimumMajor: minimumMajor,
      if (minimumMinor != null) #minimumMinor: minimumMinor,
      if (minimumPatch != null) #minimumPatch: minimumPatch,
      if (buildNumber != null) #buildNumber: buildNumber,
    }),
  );
  @override
  AppConfig $make(CopyWithData data) => AppConfig(
    id: data.get(#id, or: $value.id),
    major: data.get(#major, or: $value.major),
    minor: data.get(#minor, or: $value.minor),
    patch: data.get(#patch, or: $value.patch),
    minimumMajor: data.get(#minimumMajor, or: $value.minimumMajor),
    minimumMinor: data.get(#minimumMinor, or: $value.minimumMinor),
    minimumPatch: data.get(#minimumPatch, or: $value.minimumPatch),
    buildNumber: data.get(#buildNumber, or: $value.buildNumber),
  );

  @override
  AppConfigCopyWith<$R2, AppConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AppConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

