// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'platform_billing_settings.dart';

class PlatformBillingSettingsMapper
    extends ClassMapperBase<PlatformBillingSettings> {
  PlatformBillingSettingsMapper._();

  static PlatformBillingSettingsMapper? _instance;
  static PlatformBillingSettingsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = PlatformBillingSettingsMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'PlatformBillingSettings';

  static String _$id(PlatformBillingSettings v) => v.id;
  static const Field<PlatformBillingSettings, String> _f$id = Field('id', _$id);
  static String? _$qrphImageUrl(PlatformBillingSettings v) => v.qrphImageUrl;
  static const Field<PlatformBillingSettings, String> _f$qrphImageUrl = Field(
    'qrphImageUrl',
    _$qrphImageUrl,
    opt: true,
  );
  static String _$payeeName(PlatformBillingSettings v) => v.payeeName;
  static const Field<PlatformBillingSettings, String> _f$payeeName = Field(
    'payeeName',
    _$payeeName,
    opt: true,
    def: '',
  );
  static String _$instructions(PlatformBillingSettings v) => v.instructions;
  static const Field<PlatformBillingSettings, String> _f$instructions = Field(
    'instructions',
    _$instructions,
    opt: true,
    def: '',
  );
  static int _$defaultGraceDays(PlatformBillingSettings v) =>
      v.defaultGraceDays;
  static const Field<PlatformBillingSettings, int> _f$defaultGraceDays = Field(
    'defaultGraceDays',
    _$defaultGraceDays,
    opt: true,
    def: 7,
  );
  static int _$warningDaysBeforeDue(PlatformBillingSettings v) =>
      v.warningDaysBeforeDue;
  static const Field<PlatformBillingSettings, int> _f$warningDaysBeforeDue =
      Field('warningDaysBeforeDue', _$warningDaysBeforeDue, opt: true, def: 7);
  static bool _$enforceWarnings(PlatformBillingSettings v) => v.enforceWarnings;
  static const Field<PlatformBillingSettings, bool> _f$enforceWarnings = Field(
    'enforceWarnings',
    _$enforceWarnings,
    opt: true,
    def: true,
  );
  static bool _$enforceLockout(PlatformBillingSettings v) => v.enforceLockout;
  static const Field<PlatformBillingSettings, bool> _f$enforceLockout = Field(
    'enforceLockout',
    _$enforceLockout,
    opt: true,
    def: true,
  );
  static List<int> _$reminderDaysBeforeDue(PlatformBillingSettings v) =>
      v.reminderDaysBeforeDue;
  static const Field<PlatformBillingSettings, List<int>>
  _f$reminderDaysBeforeDue = Field(
    'reminderDaysBeforeDue',
    _$reminderDaysBeforeDue,
    opt: true,
    def: const [3, 0],
  );

  @override
  final MappableFields<PlatformBillingSettings> fields = const {
    #id: _f$id,
    #qrphImageUrl: _f$qrphImageUrl,
    #payeeName: _f$payeeName,
    #instructions: _f$instructions,
    #defaultGraceDays: _f$defaultGraceDays,
    #warningDaysBeforeDue: _f$warningDaysBeforeDue,
    #enforceWarnings: _f$enforceWarnings,
    #enforceLockout: _f$enforceLockout,
    #reminderDaysBeforeDue: _f$reminderDaysBeforeDue,
  };

  static PlatformBillingSettings _instantiate(DecodingData data) {
    return PlatformBillingSettings(
      id: data.dec(_f$id),
      qrphImageUrl: data.dec(_f$qrphImageUrl),
      payeeName: data.dec(_f$payeeName),
      instructions: data.dec(_f$instructions),
      defaultGraceDays: data.dec(_f$defaultGraceDays),
      warningDaysBeforeDue: data.dec(_f$warningDaysBeforeDue),
      enforceWarnings: data.dec(_f$enforceWarnings),
      enforceLockout: data.dec(_f$enforceLockout),
      reminderDaysBeforeDue: data.dec(_f$reminderDaysBeforeDue),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PlatformBillingSettings fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlatformBillingSettings>(map);
  }

  static PlatformBillingSettings fromJson(String json) {
    return ensureInitialized().decodeJson<PlatformBillingSettings>(json);
  }
}

mixin PlatformBillingSettingsMappable {
  String toJson() {
    return PlatformBillingSettingsMapper.ensureInitialized()
        .encodeJson<PlatformBillingSettings>(this as PlatformBillingSettings);
  }

  Map<String, dynamic> toMap() {
    return PlatformBillingSettingsMapper.ensureInitialized()
        .encodeMap<PlatformBillingSettings>(this as PlatformBillingSettings);
  }

  PlatformBillingSettingsCopyWith<
    PlatformBillingSettings,
    PlatformBillingSettings,
    PlatformBillingSettings
  >
  get copyWith =>
      _PlatformBillingSettingsCopyWithImpl<
        PlatformBillingSettings,
        PlatformBillingSettings
      >(this as PlatformBillingSettings, $identity, $identity);
  @override
  String toString() {
    return PlatformBillingSettingsMapper.ensureInitialized().stringifyValue(
      this as PlatformBillingSettings,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlatformBillingSettingsMapper.ensureInitialized().equalsValue(
      this as PlatformBillingSettings,
      other,
    );
  }

  @override
  int get hashCode {
    return PlatformBillingSettingsMapper.ensureInitialized().hashValue(
      this as PlatformBillingSettings,
    );
  }
}

extension PlatformBillingSettingsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlatformBillingSettings, $Out> {
  PlatformBillingSettingsCopyWith<$R, PlatformBillingSettings, $Out>
  get $asPlatformBillingSettings => $base.as(
    (v, t, t2) => _PlatformBillingSettingsCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class PlatformBillingSettingsCopyWith<
  $R,
  $In extends PlatformBillingSettings,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get reminderDaysBeforeDue;
  $R call({
    String? id,
    String? qrphImageUrl,
    String? payeeName,
    String? instructions,
    int? defaultGraceDays,
    int? warningDaysBeforeDue,
    bool? enforceWarnings,
    bool? enforceLockout,
    List<int>? reminderDaysBeforeDue,
  });
  PlatformBillingSettingsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PlatformBillingSettingsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlatformBillingSettings, $Out>
    implements
        PlatformBillingSettingsCopyWith<$R, PlatformBillingSettings, $Out> {
  _PlatformBillingSettingsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlatformBillingSettings> $mapper =
      PlatformBillingSettingsMapper.ensureInitialized();
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>>
  get reminderDaysBeforeDue => ListCopyWith(
    $value.reminderDaysBeforeDue,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(reminderDaysBeforeDue: v),
  );
  @override
  $R call({
    String? id,
    Object? qrphImageUrl = $none,
    String? payeeName,
    String? instructions,
    int? defaultGraceDays,
    int? warningDaysBeforeDue,
    bool? enforceWarnings,
    bool? enforceLockout,
    List<int>? reminderDaysBeforeDue,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (qrphImageUrl != $none) #qrphImageUrl: qrphImageUrl,
      if (payeeName != null) #payeeName: payeeName,
      if (instructions != null) #instructions: instructions,
      if (defaultGraceDays != null) #defaultGraceDays: defaultGraceDays,
      if (warningDaysBeforeDue != null)
        #warningDaysBeforeDue: warningDaysBeforeDue,
      if (enforceWarnings != null) #enforceWarnings: enforceWarnings,
      if (enforceLockout != null) #enforceLockout: enforceLockout,
      if (reminderDaysBeforeDue != null)
        #reminderDaysBeforeDue: reminderDaysBeforeDue,
    }),
  );
  @override
  PlatformBillingSettings $make(CopyWithData data) => PlatformBillingSettings(
    id: data.get(#id, or: $value.id),
    qrphImageUrl: data.get(#qrphImageUrl, or: $value.qrphImageUrl),
    payeeName: data.get(#payeeName, or: $value.payeeName),
    instructions: data.get(#instructions, or: $value.instructions),
    defaultGraceDays: data.get(#defaultGraceDays, or: $value.defaultGraceDays),
    warningDaysBeforeDue: data.get(
      #warningDaysBeforeDue,
      or: $value.warningDaysBeforeDue,
    ),
    enforceWarnings: data.get(#enforceWarnings, or: $value.enforceWarnings),
    enforceLockout: data.get(#enforceLockout, or: $value.enforceLockout),
    reminderDaysBeforeDue: data.get(
      #reminderDaysBeforeDue,
      or: $value.reminderDaysBeforeDue,
    ),
  );

  @override
  PlatformBillingSettingsCopyWith<$R2, PlatformBillingSettings, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PlatformBillingSettingsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

