// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'load_rule.dart';

class LoadRuleMapper extends ClassMapperBase<LoadRule> {
  LoadRuleMapper._();

  static LoadRuleMapper? _instance;
  static LoadRuleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LoadRuleMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LoadRule';

  static String _$id(LoadRule v) => v.id;
  static const Field<LoadRule, String> _f$id = Field('id', _$id);
  static String _$machineId(LoadRule v) => v.machineId;
  static const Field<LoadRule, String> _f$machineId = Field(
    'machineId',
    _$machineId,
  );
  static int _$loadCount(LoadRule v) => v.loadCount;
  static const Field<LoadRule, int> _f$loadCount = Field(
    'loadCount',
    _$loadCount,
  );
  static double? _$minWeight(LoadRule v) => v.minWeight;
  static const Field<LoadRule, double> _f$minWeight = Field(
    'minWeight',
    _$minWeight,
    opt: true,
  );
  static double? _$maxWeight(LoadRule v) => v.maxWeight;
  static const Field<LoadRule, double> _f$maxWeight = Field(
    'maxWeight',
    _$maxWeight,
    opt: true,
  );
  static bool _$isDeleted(LoadRule v) => v.isDeleted;
  static const Field<LoadRule, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(LoadRule v) => v.created;
  static const Field<LoadRule, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(LoadRule v) => v.updated;
  static const Field<LoadRule, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<LoadRule> fields = const {
    #id: _f$id,
    #machineId: _f$machineId,
    #loadCount: _f$loadCount,
    #minWeight: _f$minWeight,
    #maxWeight: _f$maxWeight,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static LoadRule _instantiate(DecodingData data) {
    return LoadRule(
      id: data.dec(_f$id),
      machineId: data.dec(_f$machineId),
      loadCount: data.dec(_f$loadCount),
      minWeight: data.dec(_f$minWeight),
      maxWeight: data.dec(_f$maxWeight),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LoadRule fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LoadRule>(map);
  }

  static LoadRule fromJson(String json) {
    return ensureInitialized().decodeJson<LoadRule>(json);
  }
}

mixin LoadRuleMappable {
  String toJson() {
    return LoadRuleMapper.ensureInitialized().encodeJson<LoadRule>(
      this as LoadRule,
    );
  }

  Map<String, dynamic> toMap() {
    return LoadRuleMapper.ensureInitialized().encodeMap<LoadRule>(
      this as LoadRule,
    );
  }

  LoadRuleCopyWith<LoadRule, LoadRule, LoadRule> get copyWith =>
      _LoadRuleCopyWithImpl<LoadRule, LoadRule>(
        this as LoadRule,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LoadRuleMapper.ensureInitialized().stringifyValue(this as LoadRule);
  }

  @override
  bool operator ==(Object other) {
    return LoadRuleMapper.ensureInitialized().equalsValue(
      this as LoadRule,
      other,
    );
  }

  @override
  int get hashCode {
    return LoadRuleMapper.ensureInitialized().hashValue(this as LoadRule);
  }
}

extension LoadRuleValueCopy<$R, $Out> on ObjectCopyWith<$R, LoadRule, $Out> {
  LoadRuleCopyWith<$R, LoadRule, $Out> get $asLoadRule =>
      $base.as((v, t, t2) => _LoadRuleCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LoadRuleCopyWith<$R, $In extends LoadRule, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? machineId,
    int? loadCount,
    double? minWeight,
    double? maxWeight,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  LoadRuleCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LoadRuleCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LoadRule, $Out>
    implements LoadRuleCopyWith<$R, LoadRule, $Out> {
  _LoadRuleCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LoadRule> $mapper =
      LoadRuleMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? machineId,
    int? loadCount,
    Object? minWeight = $none,
    Object? maxWeight = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (machineId != null) #machineId: machineId,
      if (loadCount != null) #loadCount: loadCount,
      if (minWeight != $none) #minWeight: minWeight,
      if (maxWeight != $none) #maxWeight: maxWeight,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  LoadRule $make(CopyWithData data) => LoadRule(
    id: data.get(#id, or: $value.id),
    machineId: data.get(#machineId, or: $value.machineId),
    loadCount: data.get(#loadCount, or: $value.loadCount),
    minWeight: data.get(#minWeight, or: $value.minWeight),
    maxWeight: data.get(#maxWeight, or: $value.maxWeight),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  LoadRuleCopyWith<$R2, LoadRule, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LoadRuleCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

