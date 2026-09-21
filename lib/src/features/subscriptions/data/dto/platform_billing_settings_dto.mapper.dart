// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'platform_billing_settings_dto.dart';

class PlatformBillingSettingsDtoMapper
    extends ClassMapperBase<PlatformBillingSettingsDto> {
  PlatformBillingSettingsDtoMapper._();

  static PlatformBillingSettingsDtoMapper? _instance;
  static PlatformBillingSettingsDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = PlatformBillingSettingsDtoMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'PlatformBillingSettingsDto';

  static String _$id(PlatformBillingSettingsDto v) => v.id;
  static const Field<PlatformBillingSettingsDto, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$collectionId(PlatformBillingSettingsDto v) => v.collectionId;
  static const Field<PlatformBillingSettingsDto, String> _f$collectionId =
      Field('collectionId', _$collectionId, opt: true, def: '');
  static String _$collectionName(PlatformBillingSettingsDto v) =>
      v.collectionName;
  static const Field<PlatformBillingSettingsDto, String> _f$collectionName =
      Field('collectionName', _$collectionName, opt: true, def: '');
  static String? _$qrphImage(PlatformBillingSettingsDto v) => v.qrphImage;
  static const Field<PlatformBillingSettingsDto, String> _f$qrphImage = Field(
    'qrphImage',
    _$qrphImage,
    opt: true,
  );
  static String? _$qrphImageUrl(PlatformBillingSettingsDto v) => v.qrphImageUrl;
  static const Field<PlatformBillingSettingsDto, String> _f$qrphImageUrl =
      Field('qrphImageUrl', _$qrphImageUrl, opt: true);
  static String _$payeeName(PlatformBillingSettingsDto v) => v.payeeName;
  static const Field<PlatformBillingSettingsDto, String> _f$payeeName = Field(
    'payeeName',
    _$payeeName,
    opt: true,
    def: '',
  );
  static String _$instructions(PlatformBillingSettingsDto v) => v.instructions;
  static const Field<PlatformBillingSettingsDto, String> _f$instructions =
      Field('instructions', _$instructions, opt: true, def: '');
  static int _$defaultGraceDays(PlatformBillingSettingsDto v) =>
      v.defaultGraceDays;
  static const Field<PlatformBillingSettingsDto, int> _f$defaultGraceDays =
      Field('defaultGraceDays', _$defaultGraceDays, opt: true, def: 7);
  static List<int> _$reminderDaysBeforeDue(PlatformBillingSettingsDto v) =>
      v.reminderDaysBeforeDue;
  static const Field<PlatformBillingSettingsDto, List<int>>
  _f$reminderDaysBeforeDue = Field(
    'reminderDaysBeforeDue',
    _$reminderDaysBeforeDue,
    opt: true,
    def: const [3, 0],
  );

  @override
  final MappableFields<PlatformBillingSettingsDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #qrphImage: _f$qrphImage,
    #qrphImageUrl: _f$qrphImageUrl,
    #payeeName: _f$payeeName,
    #instructions: _f$instructions,
    #defaultGraceDays: _f$defaultGraceDays,
    #reminderDaysBeforeDue: _f$reminderDaysBeforeDue,
  };

  static PlatformBillingSettingsDto _instantiate(DecodingData data) {
    return PlatformBillingSettingsDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      qrphImage: data.dec(_f$qrphImage),
      qrphImageUrl: data.dec(_f$qrphImageUrl),
      payeeName: data.dec(_f$payeeName),
      instructions: data.dec(_f$instructions),
      defaultGraceDays: data.dec(_f$defaultGraceDays),
      reminderDaysBeforeDue: data.dec(_f$reminderDaysBeforeDue),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PlatformBillingSettingsDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlatformBillingSettingsDto>(map);
  }

  static PlatformBillingSettingsDto fromJson(String json) {
    return ensureInitialized().decodeJson<PlatformBillingSettingsDto>(json);
  }
}

mixin PlatformBillingSettingsDtoMappable {
  String toJson() {
    return PlatformBillingSettingsDtoMapper.ensureInitialized()
        .encodeJson<PlatformBillingSettingsDto>(
          this as PlatformBillingSettingsDto,
        );
  }

  Map<String, dynamic> toMap() {
    return PlatformBillingSettingsDtoMapper.ensureInitialized()
        .encodeMap<PlatformBillingSettingsDto>(
          this as PlatformBillingSettingsDto,
        );
  }

  PlatformBillingSettingsDtoCopyWith<
    PlatformBillingSettingsDto,
    PlatformBillingSettingsDto,
    PlatformBillingSettingsDto
  >
  get copyWith =>
      _PlatformBillingSettingsDtoCopyWithImpl<
        PlatformBillingSettingsDto,
        PlatformBillingSettingsDto
      >(this as PlatformBillingSettingsDto, $identity, $identity);
  @override
  String toString() {
    return PlatformBillingSettingsDtoMapper.ensureInitialized().stringifyValue(
      this as PlatformBillingSettingsDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlatformBillingSettingsDtoMapper.ensureInitialized().equalsValue(
      this as PlatformBillingSettingsDto,
      other,
    );
  }

  @override
  int get hashCode {
    return PlatformBillingSettingsDtoMapper.ensureInitialized().hashValue(
      this as PlatformBillingSettingsDto,
    );
  }
}

extension PlatformBillingSettingsDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlatformBillingSettingsDto, $Out> {
  PlatformBillingSettingsDtoCopyWith<$R, PlatformBillingSettingsDto, $Out>
  get $asPlatformBillingSettingsDto => $base.as(
    (v, t, t2) => _PlatformBillingSettingsDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class PlatformBillingSettingsDtoCopyWith<
  $R,
  $In extends PlatformBillingSettingsDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get reminderDaysBeforeDue;
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? qrphImage,
    String? qrphImageUrl,
    String? payeeName,
    String? instructions,
    int? defaultGraceDays,
    List<int>? reminderDaysBeforeDue,
  });
  PlatformBillingSettingsDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PlatformBillingSettingsDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlatformBillingSettingsDto, $Out>
    implements
        PlatformBillingSettingsDtoCopyWith<
          $R,
          PlatformBillingSettingsDto,
          $Out
        > {
  _PlatformBillingSettingsDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlatformBillingSettingsDto> $mapper =
      PlatformBillingSettingsDtoMapper.ensureInitialized();
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
    String? collectionId,
    String? collectionName,
    Object? qrphImage = $none,
    Object? qrphImageUrl = $none,
    String? payeeName,
    String? instructions,
    int? defaultGraceDays,
    List<int>? reminderDaysBeforeDue,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (qrphImage != $none) #qrphImage: qrphImage,
      if (qrphImageUrl != $none) #qrphImageUrl: qrphImageUrl,
      if (payeeName != null) #payeeName: payeeName,
      if (instructions != null) #instructions: instructions,
      if (defaultGraceDays != null) #defaultGraceDays: defaultGraceDays,
      if (reminderDaysBeforeDue != null)
        #reminderDaysBeforeDue: reminderDaysBeforeDue,
    }),
  );
  @override
  PlatformBillingSettingsDto $make(CopyWithData data) =>
      PlatformBillingSettingsDto(
        id: data.get(#id, or: $value.id),
        collectionId: data.get(#collectionId, or: $value.collectionId),
        collectionName: data.get(#collectionName, or: $value.collectionName),
        qrphImage: data.get(#qrphImage, or: $value.qrphImage),
        qrphImageUrl: data.get(#qrphImageUrl, or: $value.qrphImageUrl),
        payeeName: data.get(#payeeName, or: $value.payeeName),
        instructions: data.get(#instructions, or: $value.instructions),
        defaultGraceDays: data.get(
          #defaultGraceDays,
          or: $value.defaultGraceDays,
        ),
        reminderDaysBeforeDue: data.get(
          #reminderDaysBeforeDue,
          or: $value.reminderDaysBeforeDue,
        ),
      );

  @override
  PlatformBillingSettingsDtoCopyWith<$R2, PlatformBillingSettingsDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PlatformBillingSettingsDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

