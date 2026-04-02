// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'sale.dart';

class SaleMapper extends ClassMapperBase<Sale> {
  SaleMapper._();

  static SaleMapper? _instance;
  static SaleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SaleMapper._());
      OrderStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Sale';

  static String _$id(Sale v) => v.id;
  static const Field<Sale, String> _f$id = Field('id', _$id);
  static String _$receiptNumber(Sale v) => v.receiptNumber;
  static const Field<Sale, String> _f$receiptNumber = Field(
    'receiptNumber',
    _$receiptNumber,
  );
  static String _$branchId(Sale v) => v.branchId;
  static const Field<Sale, String> _f$branchId = Field('branchId', _$branchId);
  static String _$cashierId(Sale v) => v.cashierId;
  static const Field<Sale, String> _f$cashierId = Field(
    'cashierId',
    _$cashierId,
  );
  static num _$totalAmount(Sale v) => v.totalAmount;
  static const Field<Sale, num> _f$totalAmount = Field(
    'totalAmount',
    _$totalAmount,
  );
  static String _$status(Sale v) => v.status;
  static const Field<Sale, String> _f$status = Field('status', _$status);
  static OrderStatus _$orderStatus(Sale v) => v.orderStatus;
  static const Field<Sale, OrderStatus> _f$orderStatus = Field(
    'orderStatus',
    _$orderStatus,
    opt: true,
    def: OrderStatus.pending,
  );
  static bool _$isPaid(Sale v) => v.isPaid;
  static const Field<Sale, bool> _f$isPaid = Field(
    'isPaid',
    _$isPaid,
    opt: true,
    def: false,
  );
  static int _$packs(Sale v) => v.packs;
  static const Field<Sale, int> _f$packs = Field(
    'packs',
    _$packs,
    opt: true,
    def: 0,
  );
  static DateTime? _$pickedUpAt(Sale v) => v.pickedUpAt;
  static const Field<Sale, DateTime> _f$pickedUpAt = Field(
    'pickedUpAt',
    _$pickedUpAt,
    opt: true,
  );
  static String? _$customerId(Sale v) => v.customerId;
  static const Field<Sale, String> _f$customerId = Field(
    'customerId',
    _$customerId,
    opt: true,
  );
  static String? _$customerName(Sale v) => v.customerName;
  static const Field<Sale, String> _f$customerName = Field(
    'customerName',
    _$customerName,
    opt: true,
  );
  static String? _$notes(Sale v) => v.notes;
  static const Field<Sale, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static DateTime? _$created(Sale v) => v.created;
  static const Field<Sale, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Sale v) => v.updated;
  static const Field<Sale, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Sale> fields = const {
    #id: _f$id,
    #receiptNumber: _f$receiptNumber,
    #branchId: _f$branchId,
    #cashierId: _f$cashierId,
    #totalAmount: _f$totalAmount,
    #status: _f$status,
    #orderStatus: _f$orderStatus,
    #isPaid: _f$isPaid,
    #packs: _f$packs,
    #pickedUpAt: _f$pickedUpAt,
    #customerId: _f$customerId,
    #customerName: _f$customerName,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Sale _instantiate(DecodingData data) {
    return Sale(
      id: data.dec(_f$id),
      receiptNumber: data.dec(_f$receiptNumber),
      branchId: data.dec(_f$branchId),
      cashierId: data.dec(_f$cashierId),
      totalAmount: data.dec(_f$totalAmount),
      status: data.dec(_f$status),
      orderStatus: data.dec(_f$orderStatus),
      isPaid: data.dec(_f$isPaid),
      packs: data.dec(_f$packs),
      pickedUpAt: data.dec(_f$pickedUpAt),
      customerId: data.dec(_f$customerId),
      customerName: data.dec(_f$customerName),
      notes: data.dec(_f$notes),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Sale fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Sale>(map);
  }

  static Sale fromJson(String json) {
    return ensureInitialized().decodeJson<Sale>(json);
  }
}

mixin SaleMappable {
  String toJson() {
    return SaleMapper.ensureInitialized().encodeJson<Sale>(this as Sale);
  }

  Map<String, dynamic> toMap() {
    return SaleMapper.ensureInitialized().encodeMap<Sale>(this as Sale);
  }

  SaleCopyWith<Sale, Sale, Sale> get copyWith =>
      _SaleCopyWithImpl<Sale, Sale>(this as Sale, $identity, $identity);
  @override
  String toString() {
    return SaleMapper.ensureInitialized().stringifyValue(this as Sale);
  }

  @override
  bool operator ==(Object other) {
    return SaleMapper.ensureInitialized().equalsValue(this as Sale, other);
  }

  @override
  int get hashCode {
    return SaleMapper.ensureInitialized().hashValue(this as Sale);
  }
}

extension SaleValueCopy<$R, $Out> on ObjectCopyWith<$R, Sale, $Out> {
  SaleCopyWith<$R, Sale, $Out> get $asSale =>
      $base.as((v, t, t2) => _SaleCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SaleCopyWith<$R, $In extends Sale, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? receiptNumber,
    String? branchId,
    String? cashierId,
    num? totalAmount,
    String? status,
    OrderStatus? orderStatus,
    bool? isPaid,
    int? packs,
    DateTime? pickedUpAt,
    String? customerId,
    String? customerName,
    String? notes,
    DateTime? created,
    DateTime? updated,
  });
  SaleCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SaleCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Sale, $Out>
    implements SaleCopyWith<$R, Sale, $Out> {
  _SaleCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Sale> $mapper = SaleMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? receiptNumber,
    String? branchId,
    String? cashierId,
    num? totalAmount,
    String? status,
    OrderStatus? orderStatus,
    bool? isPaid,
    int? packs,
    Object? pickedUpAt = $none,
    Object? customerId = $none,
    Object? customerName = $none,
    Object? notes = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (receiptNumber != null) #receiptNumber: receiptNumber,
      if (branchId != null) #branchId: branchId,
      if (cashierId != null) #cashierId: cashierId,
      if (totalAmount != null) #totalAmount: totalAmount,
      if (status != null) #status: status,
      if (orderStatus != null) #orderStatus: orderStatus,
      if (isPaid != null) #isPaid: isPaid,
      if (packs != null) #packs: packs,
      if (pickedUpAt != $none) #pickedUpAt: pickedUpAt,
      if (customerId != $none) #customerId: customerId,
      if (customerName != $none) #customerName: customerName,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Sale $make(CopyWithData data) => Sale(
    id: data.get(#id, or: $value.id),
    receiptNumber: data.get(#receiptNumber, or: $value.receiptNumber),
    branchId: data.get(#branchId, or: $value.branchId),
    cashierId: data.get(#cashierId, or: $value.cashierId),
    totalAmount: data.get(#totalAmount, or: $value.totalAmount),
    status: data.get(#status, or: $value.status),
    orderStatus: data.get(#orderStatus, or: $value.orderStatus),
    isPaid: data.get(#isPaid, or: $value.isPaid),
    packs: data.get(#packs, or: $value.packs),
    pickedUpAt: data.get(#pickedUpAt, or: $value.pickedUpAt),
    customerId: data.get(#customerId, or: $value.customerId),
    customerName: data.get(#customerName, or: $value.customerName),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  SaleCopyWith<$R2, Sale, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SaleCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

