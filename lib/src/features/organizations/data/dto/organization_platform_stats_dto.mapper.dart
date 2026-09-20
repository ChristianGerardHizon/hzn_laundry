// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_platform_stats_dto.dart';

class OrganizationPlatformSummaryDtoMapper
    extends ClassMapperBase<OrganizationPlatformSummaryDto> {
  OrganizationPlatformSummaryDtoMapper._();

  static OrganizationPlatformSummaryDtoMapper? _instance;
  static OrganizationPlatformSummaryDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = OrganizationPlatformSummaryDtoMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationPlatformSummaryDto';

  static int _$organizationCount(OrganizationPlatformSummaryDto v) =>
      v.organizationCount;
  static const Field<OrganizationPlatformSummaryDto, int> _f$organizationCount =
      Field('organizationCount', _$organizationCount, opt: true, def: 0);
  static int _$orderCount(OrganizationPlatformSummaryDto v) => v.orderCount;
  static const Field<OrganizationPlatformSummaryDto, int> _f$orderCount = Field(
    'orderCount',
    _$orderCount,
    opt: true,
    def: 0,
  );
  static int _$customerCount(OrganizationPlatformSummaryDto v) =>
      v.customerCount;
  static const Field<OrganizationPlatformSummaryDto, int> _f$customerCount =
      Field('customerCount', _$customerCount, opt: true, def: 0);
  static num _$revenue(OrganizationPlatformSummaryDto v) => v.revenue;
  static const Field<OrganizationPlatformSummaryDto, num> _f$revenue = Field(
    'revenue',
    _$revenue,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<OrganizationPlatformSummaryDto> fields = const {
    #organizationCount: _f$organizationCount,
    #orderCount: _f$orderCount,
    #customerCount: _f$customerCount,
    #revenue: _f$revenue,
  };

  static OrganizationPlatformSummaryDto _instantiate(DecodingData data) {
    return OrganizationPlatformSummaryDto(
      organizationCount: data.dec(_f$organizationCount),
      orderCount: data.dec(_f$orderCount),
      customerCount: data.dec(_f$customerCount),
      revenue: data.dec(_f$revenue),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationPlatformSummaryDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationPlatformSummaryDto>(map);
  }

  static OrganizationPlatformSummaryDto fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationPlatformSummaryDto>(json);
  }
}

mixin OrganizationPlatformSummaryDtoMappable {
  String toJson() {
    return OrganizationPlatformSummaryDtoMapper.ensureInitialized()
        .encodeJson<OrganizationPlatformSummaryDto>(
          this as OrganizationPlatformSummaryDto,
        );
  }

  Map<String, dynamic> toMap() {
    return OrganizationPlatformSummaryDtoMapper.ensureInitialized()
        .encodeMap<OrganizationPlatformSummaryDto>(
          this as OrganizationPlatformSummaryDto,
        );
  }

  OrganizationPlatformSummaryDtoCopyWith<
    OrganizationPlatformSummaryDto,
    OrganizationPlatformSummaryDto,
    OrganizationPlatformSummaryDto
  >
  get copyWith =>
      _OrganizationPlatformSummaryDtoCopyWithImpl<
        OrganizationPlatformSummaryDto,
        OrganizationPlatformSummaryDto
      >(this as OrganizationPlatformSummaryDto, $identity, $identity);
  @override
  String toString() {
    return OrganizationPlatformSummaryDtoMapper.ensureInitialized()
        .stringifyValue(this as OrganizationPlatformSummaryDto);
  }

  @override
  bool operator ==(Object other) {
    return OrganizationPlatformSummaryDtoMapper.ensureInitialized().equalsValue(
      this as OrganizationPlatformSummaryDto,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationPlatformSummaryDtoMapper.ensureInitialized().hashValue(
      this as OrganizationPlatformSummaryDto,
    );
  }
}

extension OrganizationPlatformSummaryDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationPlatformSummaryDto, $Out> {
  OrganizationPlatformSummaryDtoCopyWith<
    $R,
    OrganizationPlatformSummaryDto,
    $Out
  >
  get $asOrganizationPlatformSummaryDto => $base.as(
    (v, t, t2) =>
        _OrganizationPlatformSummaryDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationPlatformSummaryDtoCopyWith<
  $R,
  $In extends OrganizationPlatformSummaryDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? organizationCount,
    int? orderCount,
    int? customerCount,
    num? revenue,
  });
  OrganizationPlatformSummaryDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationPlatformSummaryDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationPlatformSummaryDto, $Out>
    implements
        OrganizationPlatformSummaryDtoCopyWith<
          $R,
          OrganizationPlatformSummaryDto,
          $Out
        > {
  _OrganizationPlatformSummaryDtoCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<OrganizationPlatformSummaryDto> $mapper =
      OrganizationPlatformSummaryDtoMapper.ensureInitialized();
  @override
  $R call({
    int? organizationCount,
    int? orderCount,
    int? customerCount,
    num? revenue,
  }) => $apply(
    FieldCopyWithData({
      if (organizationCount != null) #organizationCount: organizationCount,
      if (orderCount != null) #orderCount: orderCount,
      if (customerCount != null) #customerCount: customerCount,
      if (revenue != null) #revenue: revenue,
    }),
  );
  @override
  OrganizationPlatformSummaryDto $make(CopyWithData data) =>
      OrganizationPlatformSummaryDto(
        organizationCount: data.get(
          #organizationCount,
          or: $value.organizationCount,
        ),
        orderCount: data.get(#orderCount, or: $value.orderCount),
        customerCount: data.get(#customerCount, or: $value.customerCount),
        revenue: data.get(#revenue, or: $value.revenue),
      );

  @override
  OrganizationPlatformSummaryDtoCopyWith<
    $R2,
    OrganizationPlatformSummaryDto,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationPlatformSummaryDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OrganizationPlatformStatsDtoMapper
    extends ClassMapperBase<OrganizationPlatformStatsDto> {
  OrganizationPlatformStatsDtoMapper._();

  static OrganizationPlatformStatsDtoMapper? _instance;
  static OrganizationPlatformStatsDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = OrganizationPlatformStatsDtoMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationPlatformStatsDto';

  static String _$id(OrganizationPlatformStatsDto v) => v.id;
  static const Field<OrganizationPlatformStatsDto, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$name(OrganizationPlatformStatsDto v) => v.name;
  static const Field<OrganizationPlatformStatsDto, String> _f$name = Field(
    'name',
    _$name,
  );
  static String _$slug(OrganizationPlatformStatsDto v) => v.slug;
  static const Field<OrganizationPlatformStatsDto, String> _f$slug = Field(
    'slug',
    _$slug,
    opt: true,
    def: '',
  );
  static String? _$onboardingCompletedAt(OrganizationPlatformStatsDto v) =>
      v.onboardingCompletedAt;
  static const Field<OrganizationPlatformStatsDto, String>
  _f$onboardingCompletedAt = Field(
    'onboardingCompletedAt',
    _$onboardingCompletedAt,
    opt: true,
  );
  static int _$branchCount(OrganizationPlatformStatsDto v) => v.branchCount;
  static const Field<OrganizationPlatformStatsDto, int> _f$branchCount = Field(
    'branchCount',
    _$branchCount,
    opt: true,
    def: 0,
  );
  static int _$memberCount(OrganizationPlatformStatsDto v) => v.memberCount;
  static const Field<OrganizationPlatformStatsDto, int> _f$memberCount = Field(
    'memberCount',
    _$memberCount,
    opt: true,
    def: 0,
  );
  static int _$orderCount(OrganizationPlatformStatsDto v) => v.orderCount;
  static const Field<OrganizationPlatformStatsDto, int> _f$orderCount = Field(
    'orderCount',
    _$orderCount,
    opt: true,
    def: 0,
  );
  static int _$customerCount(OrganizationPlatformStatsDto v) => v.customerCount;
  static const Field<OrganizationPlatformStatsDto, int> _f$customerCount =
      Field('customerCount', _$customerCount, opt: true, def: 0);
  static num _$revenue(OrganizationPlatformStatsDto v) => v.revenue;
  static const Field<OrganizationPlatformStatsDto, num> _f$revenue = Field(
    'revenue',
    _$revenue,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<OrganizationPlatformStatsDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #slug: _f$slug,
    #onboardingCompletedAt: _f$onboardingCompletedAt,
    #branchCount: _f$branchCount,
    #memberCount: _f$memberCount,
    #orderCount: _f$orderCount,
    #customerCount: _f$customerCount,
    #revenue: _f$revenue,
  };

  static OrganizationPlatformStatsDto _instantiate(DecodingData data) {
    return OrganizationPlatformStatsDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      slug: data.dec(_f$slug),
      onboardingCompletedAt: data.dec(_f$onboardingCompletedAt),
      branchCount: data.dec(_f$branchCount),
      memberCount: data.dec(_f$memberCount),
      orderCount: data.dec(_f$orderCount),
      customerCount: data.dec(_f$customerCount),
      revenue: data.dec(_f$revenue),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationPlatformStatsDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationPlatformStatsDto>(map);
  }

  static OrganizationPlatformStatsDto fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationPlatformStatsDto>(json);
  }
}

mixin OrganizationPlatformStatsDtoMappable {
  String toJson() {
    return OrganizationPlatformStatsDtoMapper.ensureInitialized()
        .encodeJson<OrganizationPlatformStatsDto>(
          this as OrganizationPlatformStatsDto,
        );
  }

  Map<String, dynamic> toMap() {
    return OrganizationPlatformStatsDtoMapper.ensureInitialized()
        .encodeMap<OrganizationPlatformStatsDto>(
          this as OrganizationPlatformStatsDto,
        );
  }

  OrganizationPlatformStatsDtoCopyWith<
    OrganizationPlatformStatsDto,
    OrganizationPlatformStatsDto,
    OrganizationPlatformStatsDto
  >
  get copyWith =>
      _OrganizationPlatformStatsDtoCopyWithImpl<
        OrganizationPlatformStatsDto,
        OrganizationPlatformStatsDto
      >(this as OrganizationPlatformStatsDto, $identity, $identity);
  @override
  String toString() {
    return OrganizationPlatformStatsDtoMapper.ensureInitialized()
        .stringifyValue(this as OrganizationPlatformStatsDto);
  }

  @override
  bool operator ==(Object other) {
    return OrganizationPlatformStatsDtoMapper.ensureInitialized().equalsValue(
      this as OrganizationPlatformStatsDto,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationPlatformStatsDtoMapper.ensureInitialized().hashValue(
      this as OrganizationPlatformStatsDto,
    );
  }
}

extension OrganizationPlatformStatsDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationPlatformStatsDto, $Out> {
  OrganizationPlatformStatsDtoCopyWith<$R, OrganizationPlatformStatsDto, $Out>
  get $asOrganizationPlatformStatsDto => $base.as(
    (v, t, t2) => _OrganizationPlatformStatsDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationPlatformStatsDtoCopyWith<
  $R,
  $In extends OrganizationPlatformStatsDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? slug,
    String? onboardingCompletedAt,
    int? branchCount,
    int? memberCount,
    int? orderCount,
    int? customerCount,
    num? revenue,
  });
  OrganizationPlatformStatsDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationPlatformStatsDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationPlatformStatsDto, $Out>
    implements
        OrganizationPlatformStatsDtoCopyWith<
          $R,
          OrganizationPlatformStatsDto,
          $Out
        > {
  _OrganizationPlatformStatsDtoCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<OrganizationPlatformStatsDto> $mapper =
      OrganizationPlatformStatsDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? slug,
    Object? onboardingCompletedAt = $none,
    int? branchCount,
    int? memberCount,
    int? orderCount,
    int? customerCount,
    num? revenue,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (slug != null) #slug: slug,
      if (onboardingCompletedAt != $none)
        #onboardingCompletedAt: onboardingCompletedAt,
      if (branchCount != null) #branchCount: branchCount,
      if (memberCount != null) #memberCount: memberCount,
      if (orderCount != null) #orderCount: orderCount,
      if (customerCount != null) #customerCount: customerCount,
      if (revenue != null) #revenue: revenue,
    }),
  );
  @override
  OrganizationPlatformStatsDto $make(CopyWithData data) =>
      OrganizationPlatformStatsDto(
        id: data.get(#id, or: $value.id),
        name: data.get(#name, or: $value.name),
        slug: data.get(#slug, or: $value.slug),
        onboardingCompletedAt: data.get(
          #onboardingCompletedAt,
          or: $value.onboardingCompletedAt,
        ),
        branchCount: data.get(#branchCount, or: $value.branchCount),
        memberCount: data.get(#memberCount, or: $value.memberCount),
        orderCount: data.get(#orderCount, or: $value.orderCount),
        customerCount: data.get(#customerCount, or: $value.customerCount),
        revenue: data.get(#revenue, or: $value.revenue),
      );

  @override
  OrganizationPlatformStatsDtoCopyWith<$R2, OrganizationPlatformStatsDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationPlatformStatsDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OrganizationPlatformStatsResponseDtoMapper
    extends ClassMapperBase<OrganizationPlatformStatsResponseDto> {
  OrganizationPlatformStatsResponseDtoMapper._();

  static OrganizationPlatformStatsResponseDtoMapper? _instance;
  static OrganizationPlatformStatsResponseDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = OrganizationPlatformStatsResponseDtoMapper._(),
      );
      OrganizationPlatformSummaryDtoMapper.ensureInitialized();
      OrganizationPlatformStatsDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationPlatformStatsResponseDto';

  static OrganizationPlatformSummaryDto _$summary(
    OrganizationPlatformStatsResponseDto v,
  ) => v.summary;
  static const Field<
    OrganizationPlatformStatsResponseDto,
    OrganizationPlatformSummaryDto
  >
  _f$summary = Field('summary', _$summary);
  static List<OrganizationPlatformStatsDto> _$organizations(
    OrganizationPlatformStatsResponseDto v,
  ) => v.organizations;
  static const Field<
    OrganizationPlatformStatsResponseDto,
    List<OrganizationPlatformStatsDto>
  >
  _f$organizations = Field('organizations', _$organizations);

  @override
  final MappableFields<OrganizationPlatformStatsResponseDto> fields = const {
    #summary: _f$summary,
    #organizations: _f$organizations,
  };

  static OrganizationPlatformStatsResponseDto _instantiate(DecodingData data) {
    return OrganizationPlatformStatsResponseDto(
      summary: data.dec(_f$summary),
      organizations: data.dec(_f$organizations),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationPlatformStatsResponseDto fromMap(
    Map<String, dynamic> map,
  ) {
    return ensureInitialized().decodeMap<OrganizationPlatformStatsResponseDto>(
      map,
    );
  }

  static OrganizationPlatformStatsResponseDto fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationPlatformStatsResponseDto>(
      json,
    );
  }
}

mixin OrganizationPlatformStatsResponseDtoMappable {
  String toJson() {
    return OrganizationPlatformStatsResponseDtoMapper.ensureInitialized()
        .encodeJson<OrganizationPlatformStatsResponseDto>(
          this as OrganizationPlatformStatsResponseDto,
        );
  }

  Map<String, dynamic> toMap() {
    return OrganizationPlatformStatsResponseDtoMapper.ensureInitialized()
        .encodeMap<OrganizationPlatformStatsResponseDto>(
          this as OrganizationPlatformStatsResponseDto,
        );
  }

  OrganizationPlatformStatsResponseDtoCopyWith<
    OrganizationPlatformStatsResponseDto,
    OrganizationPlatformStatsResponseDto,
    OrganizationPlatformStatsResponseDto
  >
  get copyWith =>
      _OrganizationPlatformStatsResponseDtoCopyWithImpl<
        OrganizationPlatformStatsResponseDto,
        OrganizationPlatformStatsResponseDto
      >(this as OrganizationPlatformStatsResponseDto, $identity, $identity);
  @override
  String toString() {
    return OrganizationPlatformStatsResponseDtoMapper.ensureInitialized()
        .stringifyValue(this as OrganizationPlatformStatsResponseDto);
  }

  @override
  bool operator ==(Object other) {
    return OrganizationPlatformStatsResponseDtoMapper.ensureInitialized()
        .equalsValue(this as OrganizationPlatformStatsResponseDto, other);
  }

  @override
  int get hashCode {
    return OrganizationPlatformStatsResponseDtoMapper.ensureInitialized()
        .hashValue(this as OrganizationPlatformStatsResponseDto);
  }
}

extension OrganizationPlatformStatsResponseDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationPlatformStatsResponseDto, $Out> {
  OrganizationPlatformStatsResponseDtoCopyWith<
    $R,
    OrganizationPlatformStatsResponseDto,
    $Out
  >
  get $asOrganizationPlatformStatsResponseDto => $base.as(
    (v, t, t2) =>
        _OrganizationPlatformStatsResponseDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationPlatformStatsResponseDtoCopyWith<
  $R,
  $In extends OrganizationPlatformStatsResponseDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  OrganizationPlatformSummaryDtoCopyWith<
    $R,
    OrganizationPlatformSummaryDto,
    OrganizationPlatformSummaryDto
  >
  get summary;
  ListCopyWith<
    $R,
    OrganizationPlatformStatsDto,
    OrganizationPlatformStatsDtoCopyWith<
      $R,
      OrganizationPlatformStatsDto,
      OrganizationPlatformStatsDto
    >
  >
  get organizations;
  $R call({
    OrganizationPlatformSummaryDto? summary,
    List<OrganizationPlatformStatsDto>? organizations,
  });
  OrganizationPlatformStatsResponseDtoCopyWith<$R2, $In, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrganizationPlatformStatsResponseDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationPlatformStatsResponseDto, $Out>
    implements
        OrganizationPlatformStatsResponseDtoCopyWith<
          $R,
          OrganizationPlatformStatsResponseDto,
          $Out
        > {
  _OrganizationPlatformStatsResponseDtoCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<OrganizationPlatformStatsResponseDto> $mapper =
      OrganizationPlatformStatsResponseDtoMapper.ensureInitialized();
  @override
  OrganizationPlatformSummaryDtoCopyWith<
    $R,
    OrganizationPlatformSummaryDto,
    OrganizationPlatformSummaryDto
  >
  get summary => $value.summary.copyWith.$chain((v) => call(summary: v));
  @override
  ListCopyWith<
    $R,
    OrganizationPlatformStatsDto,
    OrganizationPlatformStatsDtoCopyWith<
      $R,
      OrganizationPlatformStatsDto,
      OrganizationPlatformStatsDto
    >
  >
  get organizations => ListCopyWith(
    $value.organizations,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(organizations: v),
  );
  @override
  $R call({
    OrganizationPlatformSummaryDto? summary,
    List<OrganizationPlatformStatsDto>? organizations,
  }) => $apply(
    FieldCopyWithData({
      if (summary != null) #summary: summary,
      if (organizations != null) #organizations: organizations,
    }),
  );
  @override
  OrganizationPlatformStatsResponseDto $make(CopyWithData data) =>
      OrganizationPlatformStatsResponseDto(
        summary: data.get(#summary, or: $value.summary),
        organizations: data.get(#organizations, or: $value.organizations),
      );

  @override
  OrganizationPlatformStatsResponseDtoCopyWith<
    $R2,
    OrganizationPlatformStatsResponseDto,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationPlatformStatsResponseDtoCopyWithImpl<$R2, $Out2>(
        $value,
        $cast,
        t,
      );
}

