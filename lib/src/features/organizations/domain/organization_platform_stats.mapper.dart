// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_platform_stats.dart';

class OrganizationPlatformSummaryMapper
    extends ClassMapperBase<OrganizationPlatformSummary> {
  OrganizationPlatformSummaryMapper._();

  static OrganizationPlatformSummaryMapper? _instance;
  static OrganizationPlatformSummaryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = OrganizationPlatformSummaryMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationPlatformSummary';

  static int _$organizationCount(OrganizationPlatformSummary v) =>
      v.organizationCount;
  static const Field<OrganizationPlatformSummary, int> _f$organizationCount =
      Field('organizationCount', _$organizationCount);
  static int _$orderCount(OrganizationPlatformSummary v) => v.orderCount;
  static const Field<OrganizationPlatformSummary, int> _f$orderCount = Field(
    'orderCount',
    _$orderCount,
  );
  static int _$customerCount(OrganizationPlatformSummary v) => v.customerCount;
  static const Field<OrganizationPlatformSummary, int> _f$customerCount = Field(
    'customerCount',
    _$customerCount,
  );
  static num _$revenue(OrganizationPlatformSummary v) => v.revenue;
  static const Field<OrganizationPlatformSummary, num> _f$revenue = Field(
    'revenue',
    _$revenue,
  );

  @override
  final MappableFields<OrganizationPlatformSummary> fields = const {
    #organizationCount: _f$organizationCount,
    #orderCount: _f$orderCount,
    #customerCount: _f$customerCount,
    #revenue: _f$revenue,
  };

  static OrganizationPlatformSummary _instantiate(DecodingData data) {
    return OrganizationPlatformSummary(
      organizationCount: data.dec(_f$organizationCount),
      orderCount: data.dec(_f$orderCount),
      customerCount: data.dec(_f$customerCount),
      revenue: data.dec(_f$revenue),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationPlatformSummary fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationPlatformSummary>(map);
  }

  static OrganizationPlatformSummary fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationPlatformSummary>(json);
  }
}

mixin OrganizationPlatformSummaryMappable {
  String toJson() {
    return OrganizationPlatformSummaryMapper.ensureInitialized()
        .encodeJson<OrganizationPlatformSummary>(
          this as OrganizationPlatformSummary,
        );
  }

  Map<String, dynamic> toMap() {
    return OrganizationPlatformSummaryMapper.ensureInitialized()
        .encodeMap<OrganizationPlatformSummary>(
          this as OrganizationPlatformSummary,
        );
  }

  OrganizationPlatformSummaryCopyWith<
    OrganizationPlatformSummary,
    OrganizationPlatformSummary,
    OrganizationPlatformSummary
  >
  get copyWith =>
      _OrganizationPlatformSummaryCopyWithImpl<
        OrganizationPlatformSummary,
        OrganizationPlatformSummary
      >(this as OrganizationPlatformSummary, $identity, $identity);
  @override
  String toString() {
    return OrganizationPlatformSummaryMapper.ensureInitialized().stringifyValue(
      this as OrganizationPlatformSummary,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationPlatformSummaryMapper.ensureInitialized().equalsValue(
      this as OrganizationPlatformSummary,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationPlatformSummaryMapper.ensureInitialized().hashValue(
      this as OrganizationPlatformSummary,
    );
  }
}

extension OrganizationPlatformSummaryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationPlatformSummary, $Out> {
  OrganizationPlatformSummaryCopyWith<$R, OrganizationPlatformSummary, $Out>
  get $asOrganizationPlatformSummary => $base.as(
    (v, t, t2) => _OrganizationPlatformSummaryCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationPlatformSummaryCopyWith<
  $R,
  $In extends OrganizationPlatformSummary,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? organizationCount,
    int? orderCount,
    int? customerCount,
    num? revenue,
  });
  OrganizationPlatformSummaryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationPlatformSummaryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationPlatformSummary, $Out>
    implements
        OrganizationPlatformSummaryCopyWith<
          $R,
          OrganizationPlatformSummary,
          $Out
        > {
  _OrganizationPlatformSummaryCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<OrganizationPlatformSummary> $mapper =
      OrganizationPlatformSummaryMapper.ensureInitialized();
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
  OrganizationPlatformSummary $make(CopyWithData data) =>
      OrganizationPlatformSummary(
        organizationCount: data.get(
          #organizationCount,
          or: $value.organizationCount,
        ),
        orderCount: data.get(#orderCount, or: $value.orderCount),
        customerCount: data.get(#customerCount, or: $value.customerCount),
        revenue: data.get(#revenue, or: $value.revenue),
      );

  @override
  OrganizationPlatformSummaryCopyWith<$R2, OrganizationPlatformSummary, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationPlatformSummaryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OrganizationPlatformStatsMapper
    extends ClassMapperBase<OrganizationPlatformStats> {
  OrganizationPlatformStatsMapper._();

  static OrganizationPlatformStatsMapper? _instance;
  static OrganizationPlatformStatsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = OrganizationPlatformStatsMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationPlatformStats';

  static String _$id(OrganizationPlatformStats v) => v.id;
  static const Field<OrganizationPlatformStats, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$name(OrganizationPlatformStats v) => v.name;
  static const Field<OrganizationPlatformStats, String> _f$name = Field(
    'name',
    _$name,
  );
  static String _$slug(OrganizationPlatformStats v) => v.slug;
  static const Field<OrganizationPlatformStats, String> _f$slug = Field(
    'slug',
    _$slug,
  );
  static DateTime? _$onboardingCompletedAt(OrganizationPlatformStats v) =>
      v.onboardingCompletedAt;
  static const Field<OrganizationPlatformStats, DateTime>
  _f$onboardingCompletedAt = Field(
    'onboardingCompletedAt',
    _$onboardingCompletedAt,
    opt: true,
  );
  static int _$branchCount(OrganizationPlatformStats v) => v.branchCount;
  static const Field<OrganizationPlatformStats, int> _f$branchCount = Field(
    'branchCount',
    _$branchCount,
  );
  static int _$memberCount(OrganizationPlatformStats v) => v.memberCount;
  static const Field<OrganizationPlatformStats, int> _f$memberCount = Field(
    'memberCount',
    _$memberCount,
  );
  static int _$orderCount(OrganizationPlatformStats v) => v.orderCount;
  static const Field<OrganizationPlatformStats, int> _f$orderCount = Field(
    'orderCount',
    _$orderCount,
  );
  static int _$customerCount(OrganizationPlatformStats v) => v.customerCount;
  static const Field<OrganizationPlatformStats, int> _f$customerCount = Field(
    'customerCount',
    _$customerCount,
  );
  static num _$revenue(OrganizationPlatformStats v) => v.revenue;
  static const Field<OrganizationPlatformStats, num> _f$revenue = Field(
    'revenue',
    _$revenue,
  );

  @override
  final MappableFields<OrganizationPlatformStats> fields = const {
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

  static OrganizationPlatformStats _instantiate(DecodingData data) {
    return OrganizationPlatformStats(
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

  static OrganizationPlatformStats fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationPlatformStats>(map);
  }

  static OrganizationPlatformStats fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationPlatformStats>(json);
  }
}

mixin OrganizationPlatformStatsMappable {
  String toJson() {
    return OrganizationPlatformStatsMapper.ensureInitialized()
        .encodeJson<OrganizationPlatformStats>(
          this as OrganizationPlatformStats,
        );
  }

  Map<String, dynamic> toMap() {
    return OrganizationPlatformStatsMapper.ensureInitialized()
        .encodeMap<OrganizationPlatformStats>(
          this as OrganizationPlatformStats,
        );
  }

  OrganizationPlatformStatsCopyWith<
    OrganizationPlatformStats,
    OrganizationPlatformStats,
    OrganizationPlatformStats
  >
  get copyWith =>
      _OrganizationPlatformStatsCopyWithImpl<
        OrganizationPlatformStats,
        OrganizationPlatformStats
      >(this as OrganizationPlatformStats, $identity, $identity);
  @override
  String toString() {
    return OrganizationPlatformStatsMapper.ensureInitialized().stringifyValue(
      this as OrganizationPlatformStats,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationPlatformStatsMapper.ensureInitialized().equalsValue(
      this as OrganizationPlatformStats,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationPlatformStatsMapper.ensureInitialized().hashValue(
      this as OrganizationPlatformStats,
    );
  }
}

extension OrganizationPlatformStatsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationPlatformStats, $Out> {
  OrganizationPlatformStatsCopyWith<$R, OrganizationPlatformStats, $Out>
  get $asOrganizationPlatformStats => $base.as(
    (v, t, t2) => _OrganizationPlatformStatsCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationPlatformStatsCopyWith<
  $R,
  $In extends OrganizationPlatformStats,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? slug,
    DateTime? onboardingCompletedAt,
    int? branchCount,
    int? memberCount,
    int? orderCount,
    int? customerCount,
    num? revenue,
  });
  OrganizationPlatformStatsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationPlatformStatsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationPlatformStats, $Out>
    implements
        OrganizationPlatformStatsCopyWith<$R, OrganizationPlatformStats, $Out> {
  _OrganizationPlatformStatsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrganizationPlatformStats> $mapper =
      OrganizationPlatformStatsMapper.ensureInitialized();
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
  OrganizationPlatformStats $make(CopyWithData data) =>
      OrganizationPlatformStats(
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
  OrganizationPlatformStatsCopyWith<$R2, OrganizationPlatformStats, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationPlatformStatsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OrganizationPlatformStatsResponseMapper
    extends ClassMapperBase<OrganizationPlatformStatsResponse> {
  OrganizationPlatformStatsResponseMapper._();

  static OrganizationPlatformStatsResponseMapper? _instance;
  static OrganizationPlatformStatsResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = OrganizationPlatformStatsResponseMapper._(),
      );
      OrganizationPlatformSummaryMapper.ensureInitialized();
      OrganizationPlatformStatsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationPlatformStatsResponse';

  static OrganizationPlatformSummary _$summary(
    OrganizationPlatformStatsResponse v,
  ) => v.summary;
  static const Field<
    OrganizationPlatformStatsResponse,
    OrganizationPlatformSummary
  >
  _f$summary = Field('summary', _$summary);
  static List<OrganizationPlatformStats> _$organizations(
    OrganizationPlatformStatsResponse v,
  ) => v.organizations;
  static const Field<
    OrganizationPlatformStatsResponse,
    List<OrganizationPlatformStats>
  >
  _f$organizations = Field('organizations', _$organizations);

  @override
  final MappableFields<OrganizationPlatformStatsResponse> fields = const {
    #summary: _f$summary,
    #organizations: _f$organizations,
  };

  static OrganizationPlatformStatsResponse _instantiate(DecodingData data) {
    return OrganizationPlatformStatsResponse(
      summary: data.dec(_f$summary),
      organizations: data.dec(_f$organizations),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationPlatformStatsResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationPlatformStatsResponse>(
      map,
    );
  }

  static OrganizationPlatformStatsResponse fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationPlatformStatsResponse>(
      json,
    );
  }
}

mixin OrganizationPlatformStatsResponseMappable {
  String toJson() {
    return OrganizationPlatformStatsResponseMapper.ensureInitialized()
        .encodeJson<OrganizationPlatformStatsResponse>(
          this as OrganizationPlatformStatsResponse,
        );
  }

  Map<String, dynamic> toMap() {
    return OrganizationPlatformStatsResponseMapper.ensureInitialized()
        .encodeMap<OrganizationPlatformStatsResponse>(
          this as OrganizationPlatformStatsResponse,
        );
  }

  OrganizationPlatformStatsResponseCopyWith<
    OrganizationPlatformStatsResponse,
    OrganizationPlatformStatsResponse,
    OrganizationPlatformStatsResponse
  >
  get copyWith =>
      _OrganizationPlatformStatsResponseCopyWithImpl<
        OrganizationPlatformStatsResponse,
        OrganizationPlatformStatsResponse
      >(this as OrganizationPlatformStatsResponse, $identity, $identity);
  @override
  String toString() {
    return OrganizationPlatformStatsResponseMapper.ensureInitialized()
        .stringifyValue(this as OrganizationPlatformStatsResponse);
  }

  @override
  bool operator ==(Object other) {
    return OrganizationPlatformStatsResponseMapper.ensureInitialized()
        .equalsValue(this as OrganizationPlatformStatsResponse, other);
  }

  @override
  int get hashCode {
    return OrganizationPlatformStatsResponseMapper.ensureInitialized()
        .hashValue(this as OrganizationPlatformStatsResponse);
  }
}

extension OrganizationPlatformStatsResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationPlatformStatsResponse, $Out> {
  OrganizationPlatformStatsResponseCopyWith<
    $R,
    OrganizationPlatformStatsResponse,
    $Out
  >
  get $asOrganizationPlatformStatsResponse => $base.as(
    (v, t, t2) =>
        _OrganizationPlatformStatsResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrganizationPlatformStatsResponseCopyWith<
  $R,
  $In extends OrganizationPlatformStatsResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  OrganizationPlatformSummaryCopyWith<
    $R,
    OrganizationPlatformSummary,
    OrganizationPlatformSummary
  >
  get summary;
  ListCopyWith<
    $R,
    OrganizationPlatformStats,
    OrganizationPlatformStatsCopyWith<
      $R,
      OrganizationPlatformStats,
      OrganizationPlatformStats
    >
  >
  get organizations;
  $R call({
    OrganizationPlatformSummary? summary,
    List<OrganizationPlatformStats>? organizations,
  });
  OrganizationPlatformStatsResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationPlatformStatsResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationPlatformStatsResponse, $Out>
    implements
        OrganizationPlatformStatsResponseCopyWith<
          $R,
          OrganizationPlatformStatsResponse,
          $Out
        > {
  _OrganizationPlatformStatsResponseCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<OrganizationPlatformStatsResponse> $mapper =
      OrganizationPlatformStatsResponseMapper.ensureInitialized();
  @override
  OrganizationPlatformSummaryCopyWith<
    $R,
    OrganizationPlatformSummary,
    OrganizationPlatformSummary
  >
  get summary => $value.summary.copyWith.$chain((v) => call(summary: v));
  @override
  ListCopyWith<
    $R,
    OrganizationPlatformStats,
    OrganizationPlatformStatsCopyWith<
      $R,
      OrganizationPlatformStats,
      OrganizationPlatformStats
    >
  >
  get organizations => ListCopyWith(
    $value.organizations,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(organizations: v),
  );
  @override
  $R call({
    OrganizationPlatformSummary? summary,
    List<OrganizationPlatformStats>? organizations,
  }) => $apply(
    FieldCopyWithData({
      if (summary != null) #summary: summary,
      if (organizations != null) #organizations: organizations,
    }),
  );
  @override
  OrganizationPlatformStatsResponse $make(CopyWithData data) =>
      OrganizationPlatformStatsResponse(
        summary: data.get(#summary, or: $value.summary),
        organizations: data.get(#organizations, or: $value.organizations),
      );

  @override
  OrganizationPlatformStatsResponseCopyWith<
    $R2,
    OrganizationPlatformStatsResponse,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrganizationPlatformStatsResponseCopyWithImpl<$R2, $Out2>(
        $value,
        $cast,
        t,
      );
}

