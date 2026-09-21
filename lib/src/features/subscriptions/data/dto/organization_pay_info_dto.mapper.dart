// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_pay_info_dto.dart';

class OrganizationPayInfoDtoMapper
    extends ClassMapperBase<OrganizationPayInfoDto> {
  OrganizationPayInfoDtoMapper._();

  static OrganizationPayInfoDtoMapper? _instance;
  static OrganizationPayInfoDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrganizationPayInfoDtoMapper._());
      OrganizationSubscriptionDtoMapper.ensureInitialized();
      PlatformBillingSettingsDtoMapper.ensureInitialized();
      SubscriptionPaymentDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationPayInfoDto';

  static OrganizationSubscriptionDto? _$subscription(
    OrganizationPayInfoDto v,
  ) => v.subscription;
  static const Field<OrganizationPayInfoDto, OrganizationSubscriptionDto>
  _f$subscription = Field('subscription', _$subscription, opt: true);
  static PlatformBillingSettingsDto _$settings(OrganizationPayInfoDto v) =>
      v.settings;
  static const Field<OrganizationPayInfoDto, PlatformBillingSettingsDto>
  _f$settings = Field('settings', _$settings);
  static SubscriptionPaymentDto? _$latestPayment(OrganizationPayInfoDto v) =>
      v.latestPayment;
  static const Field<OrganizationPayInfoDto, SubscriptionPaymentDto>
  _f$latestPayment = Field('latestPayment', _$latestPayment, opt: true);
  static String _$organizationName(OrganizationPayInfoDto v) =>
      v.organizationName;
  static const Field<OrganizationPayInfoDto, String> _f$organizationName =
      Field('organizationName', _$organizationName, opt: true, def: '');

  @override
  final MappableFields<OrganizationPayInfoDto> fields = const {
    #subscription: _f$subscription,
    #settings: _f$settings,
    #latestPayment: _f$latestPayment,
    #organizationName: _f$organizationName,
  };

  static OrganizationPayInfoDto _instantiate(DecodingData data) {
    return OrganizationPayInfoDto(
      subscription: data.dec(_f$subscription),
      settings: data.dec(_f$settings),
      latestPayment: data.dec(_f$latestPayment),
      organizationName: data.dec(_f$organizationName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationPayInfoDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationPayInfoDto>(map);
  }

  static OrganizationPayInfoDto fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationPayInfoDto>(json);
  }
}

mixin OrganizationPayInfoDtoMappable {
  String toJson() {
    return OrganizationPayInfoDtoMapper.ensureInitialized()
        .encodeJson<OrganizationPayInfoDto>(this as OrganizationPayInfoDto);
  }

  Map<String, dynamic> toMap() {
    return OrganizationPayInfoDtoMapper.ensureInitialized()
        .encodeMap<OrganizationPayInfoDto>(this as OrganizationPayInfoDto);
  }

  OrganizationPayInfoDtoCopyWith<
    OrganizationPayInfoDto,
    OrganizationPayInfoDto,
    OrganizationPayInfoDto
  >
  get copyWith =>
      _OrganizationPayInfoDtoCopyWithImpl<
        OrganizationPayInfoDto,
        OrganizationPayInfoDto
      >(this as OrganizationPayInfoDto, $identity, $identity);
  @override
  String toString() {
    return OrganizationPayInfoDtoMapper.ensureInitialized().stringifyValue(
      this as OrganizationPayInfoDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationPayInfoDtoMapper.ensureInitialized().equalsValue(
      this as OrganizationPayInfoDto,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationPayInfoDtoMapper.ensureInitialized().hashValue(
      this as OrganizationPayInfoDto,
    );
  }
}

extension OrganizationPayInfoDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationPayInfoDto, $Out> {
  OrganizationPayInfoDtoCopyWith<$R, OrganizationPayInfoDto, $Out>
  get $asOrganizationPayInfoDto => $base.as(
    (v, t, t2) => _OrganizationPayInfoDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationPayInfoDtoCopyWith<
  $R,
  $In extends OrganizationPayInfoDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  OrganizationSubscriptionDtoCopyWith<
    $R,
    OrganizationSubscriptionDto,
    OrganizationSubscriptionDto
  >?
  get subscription;
  PlatformBillingSettingsDtoCopyWith<
    $R,
    PlatformBillingSettingsDto,
    PlatformBillingSettingsDto
  >
  get settings;
  SubscriptionPaymentDtoCopyWith<
    $R,
    SubscriptionPaymentDto,
    SubscriptionPaymentDto
  >?
  get latestPayment;
  $R call({
    OrganizationSubscriptionDto? subscription,
    PlatformBillingSettingsDto? settings,
    SubscriptionPaymentDto? latestPayment,
    String? organizationName,
  });
  OrganizationPayInfoDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationPayInfoDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationPayInfoDto, $Out>
    implements
        OrganizationPayInfoDtoCopyWith<$R, OrganizationPayInfoDto, $Out> {
  _OrganizationPayInfoDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrganizationPayInfoDto> $mapper =
      OrganizationPayInfoDtoMapper.ensureInitialized();
  @override
  OrganizationSubscriptionDtoCopyWith<
    $R,
    OrganizationSubscriptionDto,
    OrganizationSubscriptionDto
  >?
  get subscription =>
      $value.subscription?.copyWith.$chain((v) => call(subscription: v));
  @override
  PlatformBillingSettingsDtoCopyWith<
    $R,
    PlatformBillingSettingsDto,
    PlatformBillingSettingsDto
  >
  get settings => $value.settings.copyWith.$chain((v) => call(settings: v));
  @override
  SubscriptionPaymentDtoCopyWith<
    $R,
    SubscriptionPaymentDto,
    SubscriptionPaymentDto
  >?
  get latestPayment =>
      $value.latestPayment?.copyWith.$chain((v) => call(latestPayment: v));
  @override
  $R call({
    Object? subscription = $none,
    PlatformBillingSettingsDto? settings,
    Object? latestPayment = $none,
    String? organizationName,
  }) => $apply(
    FieldCopyWithData({
      if (subscription != $none) #subscription: subscription,
      if (settings != null) #settings: settings,
      if (latestPayment != $none) #latestPayment: latestPayment,
      if (organizationName != null) #organizationName: organizationName,
    }),
  );
  @override
  OrganizationPayInfoDto $make(CopyWithData data) => OrganizationPayInfoDto(
    subscription: data.get(#subscription, or: $value.subscription),
    settings: data.get(#settings, or: $value.settings),
    latestPayment: data.get(#latestPayment, or: $value.latestPayment),
    organizationName: data.get(#organizationName, or: $value.organizationName),
  );

  @override
  OrganizationPayInfoDtoCopyWith<$R2, OrganizationPayInfoDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationPayInfoDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

