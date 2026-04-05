// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'activity_log.dart';

class ActivityLogMapper extends ClassMapperBase<ActivityLog> {
  ActivityLogMapper._();

  static ActivityLogMapper? _instance;
  static ActivityLogMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ActivityLogMapper._());
      ActivityActionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ActivityLog';

  static String _$id(ActivityLog v) => v.id;
  static const Field<ActivityLog, String> _f$id = Field('id', _$id);
  static String _$collection(ActivityLog v) => v.collection;
  static const Field<ActivityLog, String> _f$collection = Field(
    'collection',
    _$collection,
  );
  static String _$recordId(ActivityLog v) => v.recordId;
  static const Field<ActivityLog, String> _f$recordId = Field(
    'recordId',
    _$recordId,
  );
  static ActivityAction _$action(ActivityLog v) => v.action;
  static const Field<ActivityLog, ActivityAction> _f$action = Field(
    'action',
    _$action,
  );
  static String? _$description(ActivityLog v) => v.description;
  static const Field<ActivityLog, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static Map<String, dynamic>? _$changes(ActivityLog v) => v.changes;
  static const Field<ActivityLog, Map<String, dynamic>> _f$changes = Field(
    'changes',
    _$changes,
    opt: true,
  );
  static String? _$userId(ActivityLog v) => v.userId;
  static const Field<ActivityLog, String> _f$userId = Field(
    'userId',
    _$userId,
    opt: true,
  );
  static String? _$userName(ActivityLog v) => v.userName;
  static const Field<ActivityLog, String> _f$userName = Field(
    'userName',
    _$userName,
    opt: true,
  );
  static DateTime? _$created(ActivityLog v) => v.created;
  static const Field<ActivityLog, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(ActivityLog v) => v.updated;
  static const Field<ActivityLog, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ActivityLog> fields = const {
    #id: _f$id,
    #collection: _f$collection,
    #recordId: _f$recordId,
    #action: _f$action,
    #description: _f$description,
    #changes: _f$changes,
    #userId: _f$userId,
    #userName: _f$userName,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ActivityLog _instantiate(DecodingData data) {
    return ActivityLog(
      id: data.dec(_f$id),
      collection: data.dec(_f$collection),
      recordId: data.dec(_f$recordId),
      action: data.dec(_f$action),
      description: data.dec(_f$description),
      changes: data.dec(_f$changes),
      userId: data.dec(_f$userId),
      userName: data.dec(_f$userName),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ActivityLog fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ActivityLog>(map);
  }

  static ActivityLog fromJson(String json) {
    return ensureInitialized().decodeJson<ActivityLog>(json);
  }
}

mixin ActivityLogMappable {
  String toJson() {
    return ActivityLogMapper.ensureInitialized().encodeJson<ActivityLog>(
      this as ActivityLog,
    );
  }

  Map<String, dynamic> toMap() {
    return ActivityLogMapper.ensureInitialized().encodeMap<ActivityLog>(
      this as ActivityLog,
    );
  }

  ActivityLogCopyWith<ActivityLog, ActivityLog, ActivityLog> get copyWith =>
      _ActivityLogCopyWithImpl<ActivityLog, ActivityLog>(
        this as ActivityLog,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ActivityLogMapper.ensureInitialized().stringifyValue(
      this as ActivityLog,
    );
  }

  @override
  bool operator ==(Object other) {
    return ActivityLogMapper.ensureInitialized().equalsValue(
      this as ActivityLog,
      other,
    );
  }

  @override
  int get hashCode {
    return ActivityLogMapper.ensureInitialized().hashValue(this as ActivityLog);
  }
}

extension ActivityLogValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ActivityLog, $Out> {
  ActivityLogCopyWith<$R, ActivityLog, $Out> get $asActivityLog =>
      $base.as((v, t, t2) => _ActivityLogCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ActivityLogCopyWith<$R, $In extends ActivityLog, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get changes;
  $R call({
    String? id,
    String? collection,
    String? recordId,
    ActivityAction? action,
    String? description,
    Map<String, dynamic>? changes,
    String? userId,
    String? userName,
    DateTime? created,
    DateTime? updated,
  });
  ActivityLogCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ActivityLogCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ActivityLog, $Out>
    implements ActivityLogCopyWith<$R, ActivityLog, $Out> {
  _ActivityLogCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ActivityLog> $mapper =
      ActivityLogMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get changes => $value.changes != null
      ? MapCopyWith(
          $value.changes!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(changes: v),
        )
      : null;
  @override
  $R call({
    String? id,
    String? collection,
    String? recordId,
    ActivityAction? action,
    Object? description = $none,
    Object? changes = $none,
    Object? userId = $none,
    Object? userName = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collection != null) #collection: collection,
      if (recordId != null) #recordId: recordId,
      if (action != null) #action: action,
      if (description != $none) #description: description,
      if (changes != $none) #changes: changes,
      if (userId != $none) #userId: userId,
      if (userName != $none) #userName: userName,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ActivityLog $make(CopyWithData data) => ActivityLog(
    id: data.get(#id, or: $value.id),
    collection: data.get(#collection, or: $value.collection),
    recordId: data.get(#recordId, or: $value.recordId),
    action: data.get(#action, or: $value.action),
    description: data.get(#description, or: $value.description),
    changes: data.get(#changes, or: $value.changes),
    userId: data.get(#userId, or: $value.userId),
    userName: data.get(#userName, or: $value.userName),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ActivityLogCopyWith<$R2, ActivityLog, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ActivityLogCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

