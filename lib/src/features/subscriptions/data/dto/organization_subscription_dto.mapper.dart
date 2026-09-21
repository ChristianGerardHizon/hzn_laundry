// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_subscription_dto.dart';

class OrganizationSubscriptionDtoMapper
    extends ClassMapperBase<OrganizationSubscriptionDto> {
  OrganizationSubscriptionDtoMapper._();

  static OrganizationSubscriptionDtoMapper? _instance;
  static OrganizationSubscriptionDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = OrganizationSubscriptionDtoMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationSubscriptionDto';

  static String _$id(OrganizationSubscriptionDto v) => v.id;
  static const Field<OrganizationSubscriptionDto, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$organization(OrganizationSubscriptionDto v) => v.organization;
  static const Field<OrganizationSubscriptionDto, String> _f$organization =
      Field('organization', _$organization);
  static String _$package(OrganizationSubscriptionDto v) => v.package;
  static const Field<OrganizationSubscriptionDto, String> _f$package = Field(
    'package',
    _$package,
  );
  static String _$packageName(OrganizationSubscriptionDto v) => v.packageName;
  static const Field<OrganizationSubscriptionDto, String> _f$packageName =
      Field('packageName', _$packageName);
  static num _$price(OrganizationSubscriptionDto v) => v.price;
  static const Field<OrganizationSubscriptionDto, num> _f$price = Field(
    'price',
    _$price,
    opt: true,
    def: 0,
  );
  static int _$intervalCount(OrganizationSubscriptionDto v) => v.intervalCount;
  static const Field<OrganizationSubscriptionDto, int> _f$intervalCount = Field(
    'intervalCount',
    _$intervalCount,
    opt: true,
    def: 1,
  );
  static String _$intervalUnit(OrganizationSubscriptionDto v) => v.intervalUnit;
  static const Field<OrganizationSubscriptionDto, String> _f$intervalUnit =
      Field('intervalUnit', _$intervalUnit, opt: true, def: 'month');
  static String _$status(OrganizationSubscriptionDto v) => v.status;
  static const Field<OrganizationSubscriptionDto, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: 'active',
  );
  static String? _$periodStart(OrganizationSubscriptionDto v) => v.periodStart;
  static const Field<OrganizationSubscriptionDto, String> _f$periodStart =
      Field('periodStart', _$periodStart, opt: true);
  static String? _$periodEnd(OrganizationSubscriptionDto v) => v.periodEnd;
  static const Field<OrganizationSubscriptionDto, String> _f$periodEnd = Field(
    'periodEnd',
    _$periodEnd,
    opt: true,
  );
  static String? _$graceEndsAt(OrganizationSubscriptionDto v) => v.graceEndsAt;
  static const Field<OrganizationSubscriptionDto, String> _f$graceEndsAt =
      Field('graceEndsAt', _$graceEndsAt, opt: true);
  static String? _$nextReminderAt(OrganizationSubscriptionDto v) =>
      v.nextReminderAt;
  static const Field<OrganizationSubscriptionDto, String> _f$nextReminderAt =
      Field('nextReminderAt', _$nextReminderAt, opt: true);
  static String? _$manualUnlockUntil(OrganizationSubscriptionDto v) =>
      v.manualUnlockUntil;
  static const Field<OrganizationSubscriptionDto, String> _f$manualUnlockUntil =
      Field('manualUnlockUntil', _$manualUnlockUntil, opt: true);
  static String? _$lastReminderSentAt(OrganizationSubscriptionDto v) =>
      v.lastReminderSentAt;
  static const Field<OrganizationSubscriptionDto, String>
  _f$lastReminderSentAt = Field(
    'lastReminderSentAt',
    _$lastReminderSentAt,
    opt: true,
  );
  static bool _$isDeleted(OrganizationSubscriptionDto v) => v.isDeleted;
  static const Field<OrganizationSubscriptionDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<OrganizationSubscriptionDto> fields = const {
    #id: _f$id,
    #organization: _f$organization,
    #package: _f$package,
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

  static OrganizationSubscriptionDto _instantiate(DecodingData data) {
    return OrganizationSubscriptionDto(
      id: data.dec(_f$id),
      organization: data.dec(_f$organization),
      package: data.dec(_f$package),
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

  static OrganizationSubscriptionDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationSubscriptionDto>(map);
  }

  static OrganizationSubscriptionDto fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationSubscriptionDto>(json);
  }
}

mixin OrganizationSubscriptionDtoMappable {
  String toJson() {
    return OrganizationSubscriptionDtoMapper.ensureInitialized()
        .encodeJson<OrganizationSubscriptionDto>(
          this as OrganizationSubscriptionDto,
        );
  }

  Map<String, dynamic> toMap() {
    return OrganizationSubscriptionDtoMapper.ensureInitialized()
        .encodeMap<OrganizationSubscriptionDto>(
          this as OrganizationSubscriptionDto,
        );
  }

  OrganizationSubscriptionDtoCopyWith<
    OrganizationSubscriptionDto,
    OrganizationSubscriptionDto,
    OrganizationSubscriptionDto
  >
  get copyWith =>
      _OrganizationSubscriptionDtoCopyWithImpl<
        OrganizationSubscriptionDto,
        OrganizationSubscriptionDto
      >(this as OrganizationSubscriptionDto, $identity, $identity);
  @override
  String toString() {
    return OrganizationSubscriptionDtoMapper.ensureInitialized().stringifyValue(
      this as OrganizationSubscriptionDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationSubscriptionDtoMapper.ensureInitialized().equalsValue(
      this as OrganizationSubscriptionDto,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationSubscriptionDtoMapper.ensureInitialized().hashValue(
      this as OrganizationSubscriptionDto,
    );
  }
}

extension OrganizationSubscriptionDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationSubscriptionDto, $Out> {
  OrganizationSubscriptionDtoCopyWith<$R, OrganizationSubscriptionDto, $Out>
  get $asOrganizationSubscriptionDto => $base.as(
    (v, t, t2) => _OrganizationSubscriptionDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationSubscriptionDtoCopyWith<
  $R,
  $In extends OrganizationSubscriptionDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? organization,
    String? package,
    String? packageName,
    num? price,
    int? intervalCount,
    String? intervalUnit,
    String? status,
    String? periodStart,
    String? periodEnd,
    String? graceEndsAt,
    String? nextReminderAt,
    String? manualUnlockUntil,
    String? lastReminderSentAt,
    bool? isDeleted,
  });
  OrganizationSubscriptionDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationSubscriptionDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationSubscriptionDto, $Out>
    implements
        OrganizationSubscriptionDtoCopyWith<
          $R,
          OrganizationSubscriptionDto,
          $Out
        > {
  _OrganizationSubscriptionDtoCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<OrganizationSubscriptionDto> $mapper =
      OrganizationSubscriptionDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? organization,
    String? package,
    String? packageName,
    num? price,
    int? intervalCount,
    String? intervalUnit,
    String? status,
    Object? periodStart = $none,
    Object? periodEnd = $none,
    Object? graceEndsAt = $none,
    Object? nextReminderAt = $none,
    Object? manualUnlockUntil = $none,
    Object? lastReminderSentAt = $none,
    bool? isDeleted,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (organization != null) #organization: organization,
      if (package != null) #package: package,
      if (packageName != null) #packageName: packageName,
      if (price != null) #price: price,
      if (intervalCount != null) #intervalCount: intervalCount,
      if (intervalUnit != null) #intervalUnit: intervalUnit,
      if (status != null) #status: status,
      if (periodStart != $none) #periodStart: periodStart,
      if (periodEnd != $none) #periodEnd: periodEnd,
      if (graceEndsAt != $none) #graceEndsAt: graceEndsAt,
      if (nextReminderAt != $none) #nextReminderAt: nextReminderAt,
      if (manualUnlockUntil != $none) #manualUnlockUntil: manualUnlockUntil,
      if (lastReminderSentAt != $none) #lastReminderSentAt: lastReminderSentAt,
      if (isDeleted != null) #isDeleted: isDeleted,
    }),
  );
  @override
  OrganizationSubscriptionDto $make(CopyWithData data) =>
      OrganizationSubscriptionDto(
        id: data.get(#id, or: $value.id),
        organization: data.get(#organization, or: $value.organization),
        package: data.get(#package, or: $value.package),
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
  OrganizationSubscriptionDtoCopyWith<$R2, OrganizationSubscriptionDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationSubscriptionDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

