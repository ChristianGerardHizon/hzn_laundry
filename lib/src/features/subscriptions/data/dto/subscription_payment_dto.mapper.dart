// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'subscription_payment_dto.dart';

class SubscriptionPaymentDtoMapper
    extends ClassMapperBase<SubscriptionPaymentDto> {
  SubscriptionPaymentDtoMapper._();

  static SubscriptionPaymentDtoMapper? _instance;
  static SubscriptionPaymentDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SubscriptionPaymentDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SubscriptionPaymentDto';

  static String _$id(SubscriptionPaymentDto v) => v.id;
  static const Field<SubscriptionPaymentDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(SubscriptionPaymentDto v) => v.collectionId;
  static const Field<SubscriptionPaymentDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
    opt: true,
    def: '',
  );
  static String _$collectionName(SubscriptionPaymentDto v) => v.collectionName;
  static const Field<SubscriptionPaymentDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
    opt: true,
    def: '',
  );
  static String _$organization(SubscriptionPaymentDto v) => v.organization;
  static const Field<SubscriptionPaymentDto, String> _f$organization = Field(
    'organization',
    _$organization,
  );
  static String _$subscription(SubscriptionPaymentDto v) => v.subscription;
  static const Field<SubscriptionPaymentDto, String> _f$subscription = Field(
    'subscription',
    _$subscription,
  );
  static num _$amount(SubscriptionPaymentDto v) => v.amount;
  static const Field<SubscriptionPaymentDto, num> _f$amount = Field(
    'amount',
    _$amount,
    opt: true,
    def: 0,
  );
  static String _$status(SubscriptionPaymentDto v) => v.status;
  static const Field<SubscriptionPaymentDto, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: 'pending',
  );
  static String? _$proofImage(SubscriptionPaymentDto v) => v.proofImage;
  static const Field<SubscriptionPaymentDto, String> _f$proofImage = Field(
    'proofImage',
    _$proofImage,
    opt: true,
  );
  static String? _$proofImageUrl(SubscriptionPaymentDto v) => v.proofImageUrl;
  static const Field<SubscriptionPaymentDto, String> _f$proofImageUrl = Field(
    'proofImageUrl',
    _$proofImageUrl,
    opt: true,
  );
  static String? _$note(SubscriptionPaymentDto v) => v.note;
  static const Field<SubscriptionPaymentDto, String> _f$note = Field(
    'note',
    _$note,
    opt: true,
  );
  static String? _$adminNote(SubscriptionPaymentDto v) => v.adminNote;
  static const Field<SubscriptionPaymentDto, String> _f$adminNote = Field(
    'adminNote',
    _$adminNote,
    opt: true,
  );
  static String _$submittedBy(SubscriptionPaymentDto v) => v.submittedBy;
  static const Field<SubscriptionPaymentDto, String> _f$submittedBy = Field(
    'submittedBy',
    _$submittedBy,
  );
  static String? _$reviewedBy(SubscriptionPaymentDto v) => v.reviewedBy;
  static const Field<SubscriptionPaymentDto, String> _f$reviewedBy = Field(
    'reviewedBy',
    _$reviewedBy,
    opt: true,
  );
  static String? _$reviewedAt(SubscriptionPaymentDto v) => v.reviewedAt;
  static const Field<SubscriptionPaymentDto, String> _f$reviewedAt = Field(
    'reviewedAt',
    _$reviewedAt,
    opt: true,
  );
  static String? _$created(SubscriptionPaymentDto v) => v.created;
  static const Field<SubscriptionPaymentDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$organizationName(SubscriptionPaymentDto v) =>
      v.organizationName;
  static const Field<SubscriptionPaymentDto, String> _f$organizationName =
      Field('organizationName', _$organizationName, opt: true);

  @override
  final MappableFields<SubscriptionPaymentDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #organization: _f$organization,
    #subscription: _f$subscription,
    #amount: _f$amount,
    #status: _f$status,
    #proofImage: _f$proofImage,
    #proofImageUrl: _f$proofImageUrl,
    #note: _f$note,
    #adminNote: _f$adminNote,
    #submittedBy: _f$submittedBy,
    #reviewedBy: _f$reviewedBy,
    #reviewedAt: _f$reviewedAt,
    #created: _f$created,
    #organizationName: _f$organizationName,
  };

  static SubscriptionPaymentDto _instantiate(DecodingData data) {
    return SubscriptionPaymentDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      organization: data.dec(_f$organization),
      subscription: data.dec(_f$subscription),
      amount: data.dec(_f$amount),
      status: data.dec(_f$status),
      proofImage: data.dec(_f$proofImage),
      proofImageUrl: data.dec(_f$proofImageUrl),
      note: data.dec(_f$note),
      adminNote: data.dec(_f$adminNote),
      submittedBy: data.dec(_f$submittedBy),
      reviewedBy: data.dec(_f$reviewedBy),
      reviewedAt: data.dec(_f$reviewedAt),
      created: data.dec(_f$created),
      organizationName: data.dec(_f$organizationName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SubscriptionPaymentDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SubscriptionPaymentDto>(map);
  }

  static SubscriptionPaymentDto fromJson(String json) {
    return ensureInitialized().decodeJson<SubscriptionPaymentDto>(json);
  }
}

mixin SubscriptionPaymentDtoMappable {
  String toJson() {
    return SubscriptionPaymentDtoMapper.ensureInitialized()
        .encodeJson<SubscriptionPaymentDto>(this as SubscriptionPaymentDto);
  }

  Map<String, dynamic> toMap() {
    return SubscriptionPaymentDtoMapper.ensureInitialized()
        .encodeMap<SubscriptionPaymentDto>(this as SubscriptionPaymentDto);
  }

  SubscriptionPaymentDtoCopyWith<
    SubscriptionPaymentDto,
    SubscriptionPaymentDto,
    SubscriptionPaymentDto
  >
  get copyWith =>
      _SubscriptionPaymentDtoCopyWithImpl<
        SubscriptionPaymentDto,
        SubscriptionPaymentDto
      >(this as SubscriptionPaymentDto, $identity, $identity);
  @override
  String toString() {
    return SubscriptionPaymentDtoMapper.ensureInitialized().stringifyValue(
      this as SubscriptionPaymentDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return SubscriptionPaymentDtoMapper.ensureInitialized().equalsValue(
      this as SubscriptionPaymentDto,
      other,
    );
  }

  @override
  int get hashCode {
    return SubscriptionPaymentDtoMapper.ensureInitialized().hashValue(
      this as SubscriptionPaymentDto,
    );
  }
}

extension SubscriptionPaymentDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SubscriptionPaymentDto, $Out> {
  SubscriptionPaymentDtoCopyWith<$R, SubscriptionPaymentDto, $Out>
  get $asSubscriptionPaymentDto => $base.as(
    (v, t, t2) => _SubscriptionPaymentDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SubscriptionPaymentDtoCopyWith<
  $R,
  $In extends SubscriptionPaymentDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? organization,
    String? subscription,
    num? amount,
    String? status,
    String? proofImage,
    String? proofImageUrl,
    String? note,
    String? adminNote,
    String? submittedBy,
    String? reviewedBy,
    String? reviewedAt,
    String? created,
    String? organizationName,
  });
  SubscriptionPaymentDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SubscriptionPaymentDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SubscriptionPaymentDto, $Out>
    implements
        SubscriptionPaymentDtoCopyWith<$R, SubscriptionPaymentDto, $Out> {
  _SubscriptionPaymentDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SubscriptionPaymentDto> $mapper =
      SubscriptionPaymentDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? organization,
    String? subscription,
    num? amount,
    String? status,
    Object? proofImage = $none,
    Object? proofImageUrl = $none,
    Object? note = $none,
    Object? adminNote = $none,
    String? submittedBy,
    Object? reviewedBy = $none,
    Object? reviewedAt = $none,
    Object? created = $none,
    Object? organizationName = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (organization != null) #organization: organization,
      if (subscription != null) #subscription: subscription,
      if (amount != null) #amount: amount,
      if (status != null) #status: status,
      if (proofImage != $none) #proofImage: proofImage,
      if (proofImageUrl != $none) #proofImageUrl: proofImageUrl,
      if (note != $none) #note: note,
      if (adminNote != $none) #adminNote: adminNote,
      if (submittedBy != null) #submittedBy: submittedBy,
      if (reviewedBy != $none) #reviewedBy: reviewedBy,
      if (reviewedAt != $none) #reviewedAt: reviewedAt,
      if (created != $none) #created: created,
      if (organizationName != $none) #organizationName: organizationName,
    }),
  );
  @override
  SubscriptionPaymentDto $make(CopyWithData data) => SubscriptionPaymentDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    organization: data.get(#organization, or: $value.organization),
    subscription: data.get(#subscription, or: $value.subscription),
    amount: data.get(#amount, or: $value.amount),
    status: data.get(#status, or: $value.status),
    proofImage: data.get(#proofImage, or: $value.proofImage),
    proofImageUrl: data.get(#proofImageUrl, or: $value.proofImageUrl),
    note: data.get(#note, or: $value.note),
    adminNote: data.get(#adminNote, or: $value.adminNote),
    submittedBy: data.get(#submittedBy, or: $value.submittedBy),
    reviewedBy: data.get(#reviewedBy, or: $value.reviewedBy),
    reviewedAt: data.get(#reviewedAt, or: $value.reviewedAt),
    created: data.get(#created, or: $value.created),
    organizationName: data.get(#organizationName, or: $value.organizationName),
  );

  @override
  SubscriptionPaymentDtoCopyWith<$R2, SubscriptionPaymentDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SubscriptionPaymentDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

