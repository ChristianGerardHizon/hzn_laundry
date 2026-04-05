// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'activity_log_dto.dart';

class ActivityLogDtoMapper extends ClassMapperBase<ActivityLogDto> {
  ActivityLogDtoMapper._();

  static ActivityLogDtoMapper? _instance;
  static ActivityLogDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ActivityLogDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ActivityLogDto';

  static String _$id(ActivityLogDto v) => v.id;
  static const Field<ActivityLogDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(ActivityLogDto v) => v.collectionId;
  static const Field<ActivityLogDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(ActivityLogDto v) => v.collectionName;
  static const Field<ActivityLogDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$collection(ActivityLogDto v) => v.collection;
  static const Field<ActivityLogDto, String> _f$collection = Field(
    'collection',
    _$collection,
  );
  static String _$recordId(ActivityLogDto v) => v.recordId;
  static const Field<ActivityLogDto, String> _f$recordId = Field(
    'recordId',
    _$recordId,
  );
  static String _$action(ActivityLogDto v) => v.action;
  static const Field<ActivityLogDto, String> _f$action = Field(
    'action',
    _$action,
  );
  static String? _$description(ActivityLogDto v) => v.description;
  static const Field<ActivityLogDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static dynamic _$changes(ActivityLogDto v) => v.changes;
  static const Field<ActivityLogDto, dynamic> _f$changes = Field(
    'changes',
    _$changes,
    opt: true,
  );
  static String _$user(ActivityLogDto v) => v.user;
  static const Field<ActivityLogDto, String> _f$user = Field('user', _$user);
  static String? _$userName(ActivityLogDto v) => v.userName;
  static const Field<ActivityLogDto, String> _f$userName = Field(
    'userName',
    _$userName,
    opt: true,
  );
  static String? _$created(ActivityLogDto v) => v.created;
  static const Field<ActivityLogDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(ActivityLogDto v) => v.updated;
  static const Field<ActivityLogDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ActivityLogDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #collection: _f$collection,
    #recordId: _f$recordId,
    #action: _f$action,
    #description: _f$description,
    #changes: _f$changes,
    #user: _f$user,
    #userName: _f$userName,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ActivityLogDto _instantiate(DecodingData data) {
    return ActivityLogDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      collection: data.dec(_f$collection),
      recordId: data.dec(_f$recordId),
      action: data.dec(_f$action),
      description: data.dec(_f$description),
      changes: data.dec(_f$changes),
      user: data.dec(_f$user),
      userName: data.dec(_f$userName),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ActivityLogDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ActivityLogDto>(map);
  }

  static ActivityLogDto fromJson(String json) {
    return ensureInitialized().decodeJson<ActivityLogDto>(json);
  }
}

mixin ActivityLogDtoMappable {
  String toJson() {
    return ActivityLogDtoMapper.ensureInitialized().encodeJson<ActivityLogDto>(
      this as ActivityLogDto,
    );
  }

  Map<String, dynamic> toMap() {
    return ActivityLogDtoMapper.ensureInitialized().encodeMap<ActivityLogDto>(
      this as ActivityLogDto,
    );
  }

  ActivityLogDtoCopyWith<ActivityLogDto, ActivityLogDto, ActivityLogDto>
  get copyWith => _ActivityLogDtoCopyWithImpl<ActivityLogDto, ActivityLogDto>(
    this as ActivityLogDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ActivityLogDtoMapper.ensureInitialized().stringifyValue(
      this as ActivityLogDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ActivityLogDtoMapper.ensureInitialized().equalsValue(
      this as ActivityLogDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ActivityLogDtoMapper.ensureInitialized().hashValue(
      this as ActivityLogDto,
    );
  }
}

extension ActivityLogDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ActivityLogDto, $Out> {
  ActivityLogDtoCopyWith<$R, ActivityLogDto, $Out> get $asActivityLogDto =>
      $base.as((v, t, t2) => _ActivityLogDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ActivityLogDtoCopyWith<$R, $In extends ActivityLogDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? collection,
    String? recordId,
    String? action,
    String? description,
    dynamic changes,
    String? user,
    String? userName,
    String? created,
    String? updated,
  });
  ActivityLogDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ActivityLogDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ActivityLogDto, $Out>
    implements ActivityLogDtoCopyWith<$R, ActivityLogDto, $Out> {
  _ActivityLogDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ActivityLogDto> $mapper =
      ActivityLogDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? collection,
    String? recordId,
    String? action,
    Object? description = $none,
    Object? changes = $none,
    String? user,
    Object? userName = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (collection != null) #collection: collection,
      if (recordId != null) #recordId: recordId,
      if (action != null) #action: action,
      if (description != $none) #description: description,
      if (changes != $none) #changes: changes,
      if (user != null) #user: user,
      if (userName != $none) #userName: userName,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ActivityLogDto $make(CopyWithData data) => ActivityLogDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    collection: data.get(#collection, or: $value.collection),
    recordId: data.get(#recordId, or: $value.recordId),
    action: data.get(#action, or: $value.action),
    description: data.get(#description, or: $value.description),
    changes: data.get(#changes, or: $value.changes),
    user: data.get(#user, or: $value.user),
    userName: data.get(#userName, or: $value.userName),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ActivityLogDtoCopyWith<$R2, ActivityLogDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ActivityLogDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

