// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_pay_info.dart';

class OrganizationPayInfoMapper extends ClassMapperBase<OrganizationPayInfo> {
  OrganizationPayInfoMapper._();

  static OrganizationPayInfoMapper? _instance;
  static OrganizationPayInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrganizationPayInfoMapper._());
      OrganizationSubscriptionMapper.ensureInitialized();
      PlatformBillingSettingsMapper.ensureInitialized();
      SubscriptionPaymentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationPayInfo';

  static OrganizationSubscription? _$subscription(OrganizationPayInfo v) =>
      v.subscription;
  static const Field<OrganizationPayInfo, OrganizationSubscription>
  _f$subscription = Field('subscription', _$subscription, opt: true);
  static PlatformBillingSettings _$settings(OrganizationPayInfo v) =>
      v.settings;
  static const Field<OrganizationPayInfo, PlatformBillingSettings> _f$settings =
      Field('settings', _$settings);
  static SubscriptionPayment? _$latestPayment(OrganizationPayInfo v) =>
      v.latestPayment;
  static const Field<OrganizationPayInfo, SubscriptionPayment>
  _f$latestPayment = Field('latestPayment', _$latestPayment, opt: true);
  static String _$organizationName(OrganizationPayInfo v) => v.organizationName;
  static const Field<OrganizationPayInfo, String> _f$organizationName = Field(
    'organizationName',
    _$organizationName,
  );

  @override
  final MappableFields<OrganizationPayInfo> fields = const {
    #subscription: _f$subscription,
    #settings: _f$settings,
    #latestPayment: _f$latestPayment,
    #organizationName: _f$organizationName,
  };

  static OrganizationPayInfo _instantiate(DecodingData data) {
    return OrganizationPayInfo(
      subscription: data.dec(_f$subscription),
      settings: data.dec(_f$settings),
      latestPayment: data.dec(_f$latestPayment),
      organizationName: data.dec(_f$organizationName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationPayInfo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationPayInfo>(map);
  }

  static OrganizationPayInfo fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationPayInfo>(json);
  }
}

mixin OrganizationPayInfoMappable {
  String toJson() {
    return OrganizationPayInfoMapper.ensureInitialized()
        .encodeJson<OrganizationPayInfo>(this as OrganizationPayInfo);
  }

  Map<String, dynamic> toMap() {
    return OrganizationPayInfoMapper.ensureInitialized()
        .encodeMap<OrganizationPayInfo>(this as OrganizationPayInfo);
  }

  OrganizationPayInfoCopyWith<
    OrganizationPayInfo,
    OrganizationPayInfo,
    OrganizationPayInfo
  >
  get copyWith =>
      _OrganizationPayInfoCopyWithImpl<
        OrganizationPayInfo,
        OrganizationPayInfo
      >(this as OrganizationPayInfo, $identity, $identity);
  @override
  String toString() {
    return OrganizationPayInfoMapper.ensureInitialized().stringifyValue(
      this as OrganizationPayInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationPayInfoMapper.ensureInitialized().equalsValue(
      this as OrganizationPayInfo,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationPayInfoMapper.ensureInitialized().hashValue(
      this as OrganizationPayInfo,
    );
  }
}

extension OrganizationPayInfoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationPayInfo, $Out> {
  OrganizationPayInfoCopyWith<$R, OrganizationPayInfo, $Out>
  get $asOrganizationPayInfo => $base.as(
    (v, t, t2) => _OrganizationPayInfoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationPayInfoCopyWith<
  $R,
  $In extends OrganizationPayInfo,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  OrganizationSubscriptionCopyWith<
    $R,
    OrganizationSubscription,
    OrganizationSubscription
  >?
  get subscription;
  PlatformBillingSettingsCopyWith<
    $R,
    PlatformBillingSettings,
    PlatformBillingSettings
  >
  get settings;
  SubscriptionPaymentCopyWith<$R, SubscriptionPayment, SubscriptionPayment>?
  get latestPayment;
  $R call({
    OrganizationSubscription? subscription,
    PlatformBillingSettings? settings,
    SubscriptionPayment? latestPayment,
    String? organizationName,
  });
  OrganizationPayInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationPayInfoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationPayInfo, $Out>
    implements OrganizationPayInfoCopyWith<$R, OrganizationPayInfo, $Out> {
  _OrganizationPayInfoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrganizationPayInfo> $mapper =
      OrganizationPayInfoMapper.ensureInitialized();
  @override
  OrganizationSubscriptionCopyWith<
    $R,
    OrganizationSubscription,
    OrganizationSubscription
  >?
  get subscription =>
      $value.subscription?.copyWith.$chain((v) => call(subscription: v));
  @override
  PlatformBillingSettingsCopyWith<
    $R,
    PlatformBillingSettings,
    PlatformBillingSettings
  >
  get settings => $value.settings.copyWith.$chain((v) => call(settings: v));
  @override
  SubscriptionPaymentCopyWith<$R, SubscriptionPayment, SubscriptionPayment>?
  get latestPayment =>
      $value.latestPayment?.copyWith.$chain((v) => call(latestPayment: v));
  @override
  $R call({
    Object? subscription = $none,
    PlatformBillingSettings? settings,
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
  OrganizationPayInfo $make(CopyWithData data) => OrganizationPayInfo(
    subscription: data.get(#subscription, or: $value.subscription),
    settings: data.get(#settings, or: $value.settings),
    latestPayment: data.get(#latestPayment, or: $value.latestPayment),
    organizationName: data.get(#organizationName, or: $value.organizationName),
  );

  @override
  OrganizationPayInfoCopyWith<$R2, OrganizationPayInfo, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationPayInfoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

