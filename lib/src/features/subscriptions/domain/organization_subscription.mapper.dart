// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_subscription.dart';

class OrganizationSubscriptionMapper
    extends ClassMapperBase<OrganizationSubscription> {
  OrganizationSubscriptionMapper._();

  static OrganizationSubscriptionMapper? _instance;
  static OrganizationSubscriptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = OrganizationSubscriptionMapper._(),
      );
      BillingIntervalUnitMapper.ensureInitialized();
      SubscriptionStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationSubscription';

  static String _$id(OrganizationSubscription v) => v.id;
  static const Field<OrganizationSubscription, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$organizationId(OrganizationSubscription v) =>
      v.organizationId;
  static const Field<OrganizationSubscription, String> _f$organizationId =
      Field('organizationId', _$organizationId);
  static String _$packageId(OrganizationSubscription v) => v.packageId;
  static const Field<OrganizationSubscription, String> _f$packageId = Field(
    'packageId',
    _$packageId,
  );
  static String _$packageName(OrganizationSubscription v) => v.packageName;
  static const Field<OrganizationSubscription, String> _f$packageName = Field(
    'packageName',
    _$packageName,
  );
  static num _$price(OrganizationSubscription v) => v.price;
  static const Field<OrganizationSubscription, num> _f$price = Field(
    'price',
    _$price,
  );
  static int _$intervalCount(OrganizationSubscription v) => v.intervalCount;
  static const Field<OrganizationSubscription, int> _f$intervalCount = Field(
    'intervalCount',
    _$intervalCount,
  );
  static BillingIntervalUnit _$intervalUnit(OrganizationSubscription v) =>
      v.intervalUnit;
  static const Field<OrganizationSubscription, BillingIntervalUnit>
  _f$intervalUnit = Field('intervalUnit', _$intervalUnit);
  static SubscriptionStatus _$status(OrganizationSubscription v) => v.status;
  static const Field<OrganizationSubscription, SubscriptionStatus> _f$status =
      Field('status', _$status);
  static DateTime _$periodStart(OrganizationSubscription v) => v.periodStart;
  static const Field<OrganizationSubscription, DateTime> _f$periodStart = Field(
    'periodStart',
    _$periodStart,
  );
  static DateTime _$periodEnd(OrganizationSubscription v) => v.periodEnd;
  static const Field<OrganizationSubscription, DateTime> _f$periodEnd = Field(
    'periodEnd',
    _$periodEnd,
  );
  static DateTime? _$graceEndsAt(OrganizationSubscription v) => v.graceEndsAt;
  static const Field<OrganizationSubscription, DateTime> _f$graceEndsAt = Field(
    'graceEndsAt',
    _$graceEndsAt,
    opt: true,
  );
  static DateTime? _$nextReminderAt(OrganizationSubscription v) =>
      v.nextReminderAt;
  static const Field<OrganizationSubscription, DateTime> _f$nextReminderAt =
      Field('nextReminderAt', _$nextReminderAt, opt: true);
  static DateTime? _$manualUnlockUntil(OrganizationSubscription v) =>
      v.manualUnlockUntil;
  static const Field<OrganizationSubscription, DateTime> _f$manualUnlockUntil =
      Field('manualUnlockUntil', _$manualUnlockUntil, opt: true);
  static DateTime? _$lastReminderSentAt(OrganizationSubscription v) =>
      v.lastReminderSentAt;
  static const Field<OrganizationSubscription, DateTime> _f$lastReminderSentAt =
      Field('lastReminderSentAt', _$lastReminderSentAt, opt: true);
  static bool _$isDeleted(OrganizationSubscription v) => v.isDeleted;
  static const Field<OrganizationSubscription, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<OrganizationSubscription> fields = const {
    #id: _f$id,
    #organizationId: _f$organizationId,
    #packageId: _f$packageId,
    #packageName: _f$packageName,
    #price: _f$price,
    #intervalCount: _f$intervalCount,
    #intervalUnit: _f$intervalUnit,
    #status: _f$status,
    #periodStart: _f$periodStart,
    #periodEnd: _f$periodEnd,
    #graceEndsAt: _f$graceEndsAt,
    #nextReminderAt: _f$nextReminderAt,
    #manualUnlockUntil: _f$manualUnlockUntil,
    #lastReminderSentAt: _f$lastReminderSentAt,
    #isDeleted: _f$isDeleted,
  };

  static OrganizationSubscription _instantiate(DecodingData data) {
    return OrganizationSubscription(
      id: data.dec(_f$id),
      organizationId: data.dec(_f$organizationId),
      packageId: data.dec(_f$packageId),
      packageName: data.dec(_f$packageName),
      price: data.dec(_f$price),
      intervalCount: data.dec(_f$intervalCount),
      intervalUnit: data.dec(_f$intervalUnit),
      status: data.dec(_f$status),
      periodStart: data.dec(_f$periodStart),
      periodEnd: data.dec(_f$periodEnd),
      graceEndsAt: data.dec(_f$graceEndsAt),
      nextReminderAt: data.dec(_f$nextReminderAt),
      manualUnlockUntil: data.dec(_f$manualUnlockUntil),
      lastReminderSentAt: data.dec(_f$lastReminderSentAt),
      isDeleted: data.dec(_f$isDeleted),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationSubscription fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationSubscription>(map);
  }

  static OrganizationSubscription fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationSubscription>(json);
  }
}

mixin OrganizationSubscriptionMappable {
  String toJson() {
    return OrganizationSubscriptionMapper.ensureInitialized()
        .encodeJson<OrganizationSubscription>(this as OrganizationSubscription);
  }

  Map<String, dynamic> toMap() {
    return OrganizationSubscriptionMapper.ensureInitialized()
        .encodeMap<OrganizationSubscription>(this as OrganizationSubscription);
  }

  OrganizationSubscriptionCopyWith<
    OrganizationSubscription,
    OrganizationSubscription,
    OrganizationSubscription
  >
  get copyWith =>
      _OrganizationSubscriptionCopyWithImpl<
        OrganizationSubscription,
        OrganizationSubscription
      >(this as OrganizationSubscription, $identity, $identity);
  @override
  String toString() {
    return OrganizationSubscriptionMapper.ensureInitialized().stringifyValue(
      this as OrganizationSubscription,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationSubscriptionMapper.ensureInitialized().equalsValue(
      this as OrganizationSubscription,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationSubscriptionMapper.ensureInitialized().hashValue(
      this as OrganizationSubscription,
    );
  }
}

extension OrganizationSubscriptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationSubscription, $Out> {
  OrganizationSubscriptionCopyWith<$R, OrganizationSubscription, $Out>
  get $asOrganizationSubscription => $base.as(
    (v, t, t2) => _OrganizationSubscriptionCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationSubscriptionCopyWith<
  $R,
  $In extends OrganizationSubscription,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? organizationId,
    String? packageId,
    String? packageName,
    num? price,
    int? intervalCount,
    BillingIntervalUnit? intervalUnit,
    SubscriptionStatus? status,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? graceEndsAt,
    DateTime? nextReminderAt,
    DateTime? manualUnlockUntil,
    DateTime? lastReminderSentAt,
    bool? isDeleted,
  });
  OrganizationSubscriptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationSubscriptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationSubscription, $Out>
    implements
        OrganizationSubscriptionCopyWith<$R, OrganizationSubscription, $Out> {
  _OrganizationSubscriptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrganizationSubscription> $mapper =
      OrganizationSubscriptionMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? organizationId,
    String? packageId,
    String? packageName,
    num? price,
    int? intervalCount,
    BillingIntervalUnit? intervalUnit,
    SubscriptionStatus? status,
    DateTime? periodStart,
    DateTime? periodEnd,
    Object? graceEndsAt = $none,
    Object? nextReminderAt = $none,
    Object? manualUnlockUntil = $none,
    Object? lastReminderSentAt = $none,
    bool? isDeleted,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (organizationId != null) #organizationId: organizationId,
      if (packageId != null) #packageId: packageId,
      if (packageName != null) #packageName: packageName,
      if (price != null) #price: price,
      if (intervalCount != null) #intervalCount: intervalCount,
      if (intervalUnit != null) #intervalUnit: intervalUnit,
      if (status != null) #status: status,
      if (periodStart != null) #periodStart: periodStart,
      if (periodEnd != null) #periodEnd: periodEnd,
      if (graceEndsAt != $none) #graceEndsAt: graceEndsAt,
      if (nextReminderAt != $none) #nextReminderAt: nextReminderAt,
      if (manualUnlockUntil != $none) #manualUnlockUntil: manualUnlockUntil,
      if (lastReminderSentAt != $none) #lastReminderSentAt: lastReminderSentAt,
      if (isDeleted != null) #isDeleted: isDeleted,
    }),
  );
  @override
  OrganizationSubscription $make(CopyWithData data) => OrganizationSubscription(
    id: data.get(#id, or: $value.id),
    organizationId: data.get(#organizationId, or: $value.organizationId),
    packageId: data.get(#packageId, or: $value.packageId),
    packageName: data.get(#packageName, or: $value.packageName),
    price: data.get(#price, or: $value.price),
    intervalCount: data.get(#intervalCount, or: $value.intervalCount),
    intervalUnit: data.get(#intervalUnit, or: $value.intervalUnit),
    status: data.get(#status, or: $value.status),
    periodStart: data.get(#periodStart, or: $value.periodStart),
    periodEnd: data.get(#periodEnd, or: $value.periodEnd),
    graceEndsAt: data.get(#graceEndsAt, or: $value.graceEndsAt),
    nextReminderAt: data.get(#nextReminderAt, or: $value.nextReminderAt),
    manualUnlockUntil: data.get(
      #manualUnlockUntil,
      or: $value.manualUnlockUntil,
    ),
    lastReminderSentAt: data.get(
      #lastReminderSentAt,
      or: $value.lastReminderSentAt,
    ),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
  );

  @override
  OrganizationSubscriptionCopyWith<$R2, OrganizationSubscription, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationSubscriptionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

