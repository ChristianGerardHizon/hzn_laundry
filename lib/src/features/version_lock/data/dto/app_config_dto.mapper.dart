// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'app_config_dto.dart';

class AppConfigDtoMapper extends ClassMapperBase<AppConfigDto> {
  AppConfigDtoMapper._();

  static AppConfigDtoMapper? _instance;
  static AppConfigDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppConfigDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AppConfigDto';

  static String _$id(AppConfigDto v) => v.id;
  static const Field<AppConfigDto, String> _f$id = Field('id', _$id);
  static int _$major(AppConfigDto v) => v.major;
  static const Field<AppConfigDto, int> _f$major = Field('major', _$major);
  static int _$minor(AppConfigDto v) => v.minor;
  static const Field<AppConfigDto, int> _f$minor = Field('minor', _$minor);
  static int _$patch(AppConfigDto v) => v.patch;
  static const Field<AppConfigDto, int> _f$patch = Field('patch', _$patch);
  static int _$minimumMajor(AppConfigDto v) => v.minimumMajor;
  static const Field<AppConfigDto, int> _f$minimumMajor = Field(
    'minimumMajor',
    _$minimumMajor,
  );
  static int _$minimumMinor(AppConfigDto v) => v.minimumMinor;
  static const Field<AppConfigDto, int> _f$minimumMinor = Field(
    'minimumMinor',
    _$minimumMinor,
  );
  static int _$minimumPatch(AppConfigDto v) => v.minimumPatch;
  static const Field<AppConfigDto, int> _f$minimumPatch = Field(
    'minimumPatch',
    _$minimumPatch,
  );
  static int _$buildNumber(AppConfigDto v) => v.buildNumber;
  static const Field<AppConfigDto, int> _f$buildNumber = Field(
    'buildNumber',
    _$buildNumber,
  );

  @override
  final MappableFields<AppConfigDto> fields = const {
    #id: _f$id,
    #major: _f$major,
    #minor: _f$minor,
    #patch: _f$patch,
    #minimumMajor: _f$minimumMajor,
    #minimumMinor: _f$minimumMinor,
    #minimumPatch: _f$minimumPatch,
    #buildNumber: _f$buildNumber,
  };

  static AppConfigDto _instantiate(DecodingData data) {
    return AppConfigDto(
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

  static AppConfigDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppConfigDto>(map);
  }

  static AppConfigDto fromJson(String json) {
    return ensureInitialized().decodeJson<AppConfigDto>(json);
  }
}

mixin AppConfigDtoMappable {
  String toJson() {
    return AppConfigDtoMapper.ensureInitialized().encodeJson<AppConfigDto>(
      this as AppConfigDto,
    );
  }

  Map<String, dynamic> toMap() {
    return AppConfigDtoMapper.ensureInitialized().encodeMap<AppConfigDto>(
      this as AppConfigDto,
    );
  }

  AppConfigDtoCopyWith<AppConfigDto, AppConfigDto, AppConfigDto> get copyWith =>
      _AppConfigDtoCopyWithImpl<AppConfigDto, AppConfigDto>(
        this as AppConfigDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AppConfigDtoMapper.ensureInitialized().stringifyValue(
      this as AppConfigDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return AppConfigDtoMapper.ensureInitialized().equalsValue(
      this as AppConfigDto,
      other,
    );
  }

  @override
  int get hashCode {
    return AppConfigDtoMapper.ensureInitialized().hashValue(
      this as AppConfigDto,
    );
  }
}

extension AppConfigDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AppConfigDto, $Out> {
  AppConfigDtoCopyWith<$R, AppConfigDto, $Out> get $asAppConfigDto =>
      $base.as((v, t, t2) => _AppConfigDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AppConfigDtoCopyWith<$R, $In extends AppConfigDto, $Out>
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
  AppConfigDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AppConfigDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppConfigDto, $Out>
    implements AppConfigDtoCopyWith<$R, AppConfigDto, $Out> {
  _AppConfigDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppConfigDto> $mapper =
      AppConfigDtoMapper.ensureInitialized();
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
  AppConfigDto $make(CopyWithData data) => AppConfigDto(
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
  AppConfigDtoCopyWith<$R2, AppConfigDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AppConfigDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

