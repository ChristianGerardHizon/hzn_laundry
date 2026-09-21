// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'subscription_payment.dart';

class SubscriptionPaymentMapper extends ClassMapperBase<SubscriptionPayment> {
  SubscriptionPaymentMapper._();

  static SubscriptionPaymentMapper? _instance;
  static SubscriptionPaymentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SubscriptionPaymentMapper._());
      SubscriptionPaymentStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SubscriptionPayment';

  static String _$id(SubscriptionPayment v) => v.id;
  static const Field<SubscriptionPayment, String> _f$id = Field('id', _$id);
  static String _$organizationId(SubscriptionPayment v) => v.organizationId;
  static const Field<SubscriptionPayment, String> _f$organizationId = Field(
    'organizationId',
    _$organizationId,
  );
  static String _$subscriptionId(SubscriptionPayment v) => v.subscriptionId;
  static const Field<SubscriptionPayment, String> _f$subscriptionId = Field(
    'subscriptionId',
    _$subscriptionId,
  );
  static num _$amount(SubscriptionPayment v) => v.amount;
  static const Field<SubscriptionPayment, num> _f$amount = Field(
    'amount',
    _$amount,
  );
  static SubscriptionPaymentStatus _$status(SubscriptionPayment v) => v.status;
  static const Field<SubscriptionPayment, SubscriptionPaymentStatus> _f$status =
      Field('status', _$status);
  static String? _$proofImageUrl(SubscriptionPayment v) => v.proofImageUrl;
  static const Field<SubscriptionPayment, String> _f$proofImageUrl = Field(
    'proofImageUrl',
    _$proofImageUrl,
    opt: true,
  );
  static String? _$note(SubscriptionPayment v) => v.note;
  static const Field<SubscriptionPayment, String> _f$note = Field(
    'note',
    _$note,
    opt: true,
  );
  static String? _$adminNote(SubscriptionPayment v) => v.adminNote;
  static const Field<SubscriptionPayment, String> _f$adminNote = Field(
    'adminNote',
    _$adminNote,
    opt: true,
  );
  static String _$submittedById(SubscriptionPayment v) => v.submittedById;
  static const Field<SubscriptionPayment, String> _f$submittedById = Field(
    'submittedById',
    _$submittedById,
  );
  static String? _$reviewedById(SubscriptionPayment v) => v.reviewedById;
  static const Field<SubscriptionPayment, String> _f$reviewedById = Field(
    'reviewedById',
    _$reviewedById,
    opt: true,
  );
  static DateTime? _$reviewedAt(SubscriptionPayment v) => v.reviewedAt;
  static const Field<SubscriptionPayment, DateTime> _f$reviewedAt = Field(
    'reviewedAt',
    _$reviewedAt,
    opt: true,
  );
  static DateTime? _$created(SubscriptionPayment v) => v.created;
  static const Field<SubscriptionPayment, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$organizationName(SubscriptionPayment v) =>
      v.organizationName;
  static const Field<SubscriptionPayment, String> _f$organizationName = Field(
    'organizationName',
    _$organizationName,
    opt: true,
  );

  @override
  final MappableFields<SubscriptionPayment> fields = const {
    #id: _f$id,
    #organizationId: _f$organizationId,
    #subscriptionId: _f$subscriptionId,
    #amount: _f$amount,
    #status: _f$status,
    #proofImageUrl: _f$proofImageUrl,
    #note: _f$note,
    #adminNote: _f$adminNote,
    #submittedById: _f$submittedById,
    #reviewedById: _f$reviewedById,
    #reviewedAt: _f$reviewedAt,
    #created: _f$created,
    #organizationName: _f$organizationName,
  };

  static SubscriptionPayment _instantiate(DecodingData data) {
    return SubscriptionPayment(
      id: data.dec(_f$id),
      organizationId: data.dec(_f$organizationId),
      subscriptionId: data.dec(_f$subscriptionId),
      amount: data.dec(_f$amount),
      status: data.dec(_f$status),
      proofImageUrl: data.dec(_f$proofImageUrl),
      note: data.dec(_f$note),
      adminNote: data.dec(_f$adminNote),
      submittedById: data.dec(_f$submittedById),
      reviewedById: data.dec(_f$reviewedById),
      reviewedAt: data.dec(_f$reviewedAt),
      created: data.dec(_f$created),
      organizationName: data.dec(_f$organizationName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SubscriptionPayment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SubscriptionPayment>(map);
  }

  static SubscriptionPayment fromJson(String json) {
    return ensureInitialized().decodeJson<SubscriptionPayment>(json);
  }
}

mixin SubscriptionPaymentMappable {
  String toJson() {
    return SubscriptionPaymentMapper.ensureInitialized()
        .encodeJson<SubscriptionPayment>(this as SubscriptionPayment);
  }

  Map<String, dynamic> toMap() {
    return SubscriptionPaymentMapper.ensureInitialized()
        .encodeMap<SubscriptionPayment>(this as SubscriptionPayment);
  }

  SubscriptionPaymentCopyWith<
    SubscriptionPayment,
    SubscriptionPayment,
    SubscriptionPayment
  >
  get copyWith =>
      _SubscriptionPaymentCopyWithImpl<
        SubscriptionPayment,
        SubscriptionPayment
      >(this as SubscriptionPayment, $identity, $identity);
  @override
  String toString() {
    return SubscriptionPaymentMapper.ensureInitialized().stringifyValue(
      this as SubscriptionPayment,
    );
  }

  @override
  bool operator ==(Object other) {
    return SubscriptionPaymentMapper.ensureInitialized().equalsValue(
      this as SubscriptionPayment,
      other,
    );
  }

  @override
  int get hashCode {
    return SubscriptionPaymentMapper.ensureInitialized().hashValue(
      this as SubscriptionPayment,
    );
  }
}

extension SubscriptionPaymentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SubscriptionPayment, $Out> {
  SubscriptionPaymentCopyWith<$R, SubscriptionPayment, $Out>
  get $asSubscriptionPayment => $base.as(
    (v, t, t2) => _SubscriptionPaymentCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SubscriptionPaymentCopyWith<
  $R,
  $In extends SubscriptionPayment,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? organizationId,
    String? subscriptionId,
    num? amount,
    SubscriptionPaymentStatus? status,
    String? proofImageUrl,
    String? note,
    String? adminNote,
    String? submittedById,
    String? reviewedById,
    DateTime? reviewedAt,
    DateTime? created,
    String? organizationName,
  });
  SubscriptionPaymentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SubscriptionPaymentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SubscriptionPayment, $Out>
    implements SubscriptionPaymentCopyWith<$R, SubscriptionPayment, $Out> {
  _SubscriptionPaymentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SubscriptionPayment> $mapper =
      SubscriptionPaymentMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? organizationId,
    String? subscriptionId,
    num? amount,
    SubscriptionPaymentStatus? status,
    Object? proofImageUrl = $none,
    Object? note = $none,
    Object? adminNote = $none,
    String? submittedById,
    Object? reviewedById = $none,
    Object? reviewedAt = $none,
    Object? created = $none,
    Object? organizationName = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (organizationId != null) #organizationId: organizationId,
      if (subscriptionId != null) #subscriptionId: subscriptionId,
      if (amount != null) #amount: amount,
      if (status != null) #status: status,
      if (proofImageUrl != $none) #proofImageUrl: proofImageUrl,
      if (note != $none) #note: note,
      if (adminNote != $none) #adminNote: adminNote,
      if (submittedById != null) #submittedById: submittedById,
      if (reviewedById != $none) #reviewedById: reviewedById,
      if (reviewedAt != $none) #reviewedAt: reviewedAt,
      if (created != $none) #created: created,
      if (organizationName != $none) #organizationName: organizationName,
    }),
  );
  @override
  SubscriptionPayment $make(CopyWithData data) => SubscriptionPayment(
    id: data.get(#id, or: $value.id),
    organizationId: data.get(#organizationId, or: $value.organizationId),
    subscriptionId: data.get(#subscriptionId, or: $value.subscriptionId),
    amount: data.get(#amount, or: $value.amount),
    status: data.get(#status, or: $value.status),
    proofImageUrl: data.get(#proofImageUrl, or: $value.proofImageUrl),
    note: data.get(#note, or: $value.note),
    adminNote: data.get(#adminNote, or: $value.adminNote),
    submittedById: data.get(#submittedById, or: $value.submittedById),
    reviewedById: data.get(#reviewedById, or: $value.reviewedById),
    reviewedAt: data.get(#reviewedAt, or: $value.reviewedAt),
    created: data.get(#created, or: $value.created),
    organizationName: data.get(#organizationName, or: $value.organizationName),
  );

  @override
  SubscriptionPaymentCopyWith<$R2, SubscriptionPayment, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SubscriptionPaymentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

