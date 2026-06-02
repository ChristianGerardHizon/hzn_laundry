// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'customer_history.dart';

class CustomerHistoryCustomerMapper
    extends ClassMapperBase<CustomerHistoryCustomer> {
  CustomerHistoryCustomerMapper._();

  static CustomerHistoryCustomerMapper? _instance;
  static CustomerHistoryCustomerMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = CustomerHistoryCustomerMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerHistoryCustomer';

  static String _$id(CustomerHistoryCustomer v) => v.id;
  static const Field<CustomerHistoryCustomer, String> _f$id = Field('id', _$id);
  static String _$name(CustomerHistoryCustomer v) => v.name;
  static const Field<CustomerHistoryCustomer, String> _f$name = Field(
    'name',
    _$name,
  );
  static String? _$phone(CustomerHistoryCustomer v) => v.phone;
  static const Field<CustomerHistoryCustomer, String> _f$phone = Field(
    'phone',
    _$phone,
    opt: true,
  );

  @override
  final MappableFields<CustomerHistoryCustomer> fields = const {
    #id: _f$id,
    #name: _f$name,
    #phone: _f$phone,
  };

  static CustomerHistoryCustomer _instantiate(DecodingData data) {
    return CustomerHistoryCustomer(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      phone: data.dec(_f$phone),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomerHistoryCustomer fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerHistoryCustomer>(map);
  }

  static CustomerHistoryCustomer fromJson(String json) {
    return ensureInitialized().decodeJson<CustomerHistoryCustomer>(json);
  }
}

mixin CustomerHistoryCustomerMappable {
  String toJson() {
    return CustomerHistoryCustomerMapper.ensureInitialized()
        .encodeJson<CustomerHistoryCustomer>(this as CustomerHistoryCustomer);
  }

  Map<String, dynamic> toMap() {
    return CustomerHistoryCustomerMapper.ensureInitialized()
        .encodeMap<CustomerHistoryCustomer>(this as CustomerHistoryCustomer);
  }

  CustomerHistoryCustomerCopyWith<
    CustomerHistoryCustomer,
    CustomerHistoryCustomer,
    CustomerHistoryCustomer
  >
  get copyWith =>
      _CustomerHistoryCustomerCopyWithImpl<
        CustomerHistoryCustomer,
        CustomerHistoryCustomer
      >(this as CustomerHistoryCustomer, $identity, $identity);
  @override
  String toString() {
    return CustomerHistoryCustomerMapper.ensureInitialized().stringifyValue(
      this as CustomerHistoryCustomer,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerHistoryCustomerMapper.ensureInitialized().equalsValue(
      this as CustomerHistoryCustomer,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerHistoryCustomerMapper.ensureInitialized().hashValue(
      this as CustomerHistoryCustomer,
    );
  }
}

extension CustomerHistoryCustomerValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerHistoryCustomer, $Out> {
  CustomerHistoryCustomerCopyWith<$R, CustomerHistoryCustomer, $Out>
  get $asCustomerHistoryCustomer => $base.as(
    (v, t, t2) => _CustomerHistoryCustomerCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CustomerHistoryCustomerCopyWith<
  $R,
  $In extends CustomerHistoryCustomer,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? name, String? phone});
  CustomerHistoryCustomerCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CustomerHistoryCustomerCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerHistoryCustomer, $Out>
    implements
        CustomerHistoryCustomerCopyWith<$R, CustomerHistoryCustomer, $Out> {
  _CustomerHistoryCustomerCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerHistoryCustomer> $mapper =
      CustomerHistoryCustomerMapper.ensureInitialized();
  @override
  $R call({String? id, String? name, Object? phone = $none}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (phone != $none) #phone: phone,
    }),
  );
  @override
  CustomerHistoryCustomer $make(CopyWithData data) => CustomerHistoryCustomer(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    phone: data.get(#phone, or: $value.phone),
  );

  @override
  CustomerHistoryCustomerCopyWith<$R2, CustomerHistoryCustomer, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CustomerHistoryCustomerCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CustomerHistorySaleMapper extends ClassMapperBase<CustomerHistorySale> {
  CustomerHistorySaleMapper._();

  static CustomerHistorySaleMapper? _instance;
  static CustomerHistorySaleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomerHistorySaleMapper._());
      OrderStatusMapper.ensureInitialized();
      PaymentStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerHistorySale';

  static String _$id(CustomerHistorySale v) => v.id;
  static const Field<CustomerHistorySale, String> _f$id = Field('id', _$id);
  static String _$receiptNumber(CustomerHistorySale v) => v.receiptNumber;
  static const Field<CustomerHistorySale, String> _f$receiptNumber = Field(
    'receiptNumber',
    _$receiptNumber,
  );
  static num _$totalAmount(CustomerHistorySale v) => v.totalAmount;
  static const Field<CustomerHistorySale, num> _f$totalAmount = Field(
    'totalAmount',
    _$totalAmount,
  );
  static OrderStatus _$orderStatus(CustomerHistorySale v) => v.orderStatus;
  static const Field<CustomerHistorySale, OrderStatus> _f$orderStatus = Field(
    'orderStatus',
    _$orderStatus,
  );
  static PaymentStatus _$paymentStatus(CustomerHistorySale v) =>
      v.paymentStatus;
  static const Field<CustomerHistorySale, PaymentStatus> _f$paymentStatus =
      Field('paymentStatus', _$paymentStatus);
  static bool _$isPaid(CustomerHistorySale v) => v.isPaid;
  static const Field<CustomerHistorySale, bool> _f$isPaid = Field(
    'isPaid',
    _$isPaid,
  );
  static int _$packs(CustomerHistorySale v) => v.packs;
  static const Field<CustomerHistorySale, int> _f$packs = Field(
    'packs',
    _$packs,
    opt: true,
    def: 0,
  );
  static String? _$notes(CustomerHistorySale v) => v.notes;
  static const Field<CustomerHistorySale, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static DateTime? _$pickedUpAt(CustomerHistorySale v) => v.pickedUpAt;
  static const Field<CustomerHistorySale, DateTime> _f$pickedUpAt = Field(
    'pickedUpAt',
    _$pickedUpAt,
    opt: true,
  );
  static DateTime? _$postedDate(CustomerHistorySale v) => v.postedDate;
  static const Field<CustomerHistorySale, DateTime> _f$postedDate = Field(
    'postedDate',
    _$postedDate,
    opt: true,
  );
  static DateTime? _$created(CustomerHistorySale v) => v.created;
  static const Field<CustomerHistorySale, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );

  @override
  final MappableFields<CustomerHistorySale> fields = const {
    #id: _f$id,
    #receiptNumber: _f$receiptNumber,
    #totalAmount: _f$totalAmount,
    #orderStatus: _f$orderStatus,
    #paymentStatus: _f$paymentStatus,
    #isPaid: _f$isPaid,
    #packs: _f$packs,
    #notes: _f$notes,
    #pickedUpAt: _f$pickedUpAt,
    #postedDate: _f$postedDate,
    #created: _f$created,
  };

  static CustomerHistorySale _instantiate(DecodingData data) {
    return CustomerHistorySale(
      id: data.dec(_f$id),
      receiptNumber: data.dec(_f$receiptNumber),
      totalAmount: data.dec(_f$totalAmount),
      orderStatus: data.dec(_f$orderStatus),
      paymentStatus: data.dec(_f$paymentStatus),
      isPaid: data.dec(_f$isPaid),
      packs: data.dec(_f$packs),
      notes: data.dec(_f$notes),
      pickedUpAt: data.dec(_f$pickedUpAt),
      postedDate: data.dec(_f$postedDate),
      created: data.dec(_f$created),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomerHistorySale fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerHistorySale>(map);
  }

  static CustomerHistorySale fromJson(String json) {
    return ensureInitialized().decodeJson<CustomerHistorySale>(json);
  }
}

mixin CustomerHistorySaleMappable {
  String toJson() {
    return CustomerHistorySaleMapper.ensureInitialized()
        .encodeJson<CustomerHistorySale>(this as CustomerHistorySale);
  }

  Map<String, dynamic> toMap() {
    return CustomerHistorySaleMapper.ensureInitialized()
        .encodeMap<CustomerHistorySale>(this as CustomerHistorySale);
  }

  CustomerHistorySaleCopyWith<
    CustomerHistorySale,
    CustomerHistorySale,
    CustomerHistorySale
  >
  get copyWith =>
      _CustomerHistorySaleCopyWithImpl<
        CustomerHistorySale,
        CustomerHistorySale
      >(this as CustomerHistorySale, $identity, $identity);
  @override
  String toString() {
    return CustomerHistorySaleMapper.ensureInitialized().stringifyValue(
      this as CustomerHistorySale,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerHistorySaleMapper.ensureInitialized().equalsValue(
      this as CustomerHistorySale,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerHistorySaleMapper.ensureInitialized().hashValue(
      this as CustomerHistorySale,
    );
  }
}

extension CustomerHistorySaleValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerHistorySale, $Out> {
  CustomerHistorySaleCopyWith<$R, CustomerHistorySale, $Out>
  get $asCustomerHistorySale => $base.as(
    (v, t, t2) => _CustomerHistorySaleCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CustomerHistorySaleCopyWith<
  $R,
  $In extends CustomerHistorySale,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? receiptNumber,
    num? totalAmount,
    OrderStatus? orderStatus,
    PaymentStatus? paymentStatus,
    bool? isPaid,
    int? packs,
    String? notes,
    DateTime? pickedUpAt,
    DateTime? postedDate,
    DateTime? created,
  });
  CustomerHistorySaleCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CustomerHistorySaleCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerHistorySale, $Out>
    implements CustomerHistorySaleCopyWith<$R, CustomerHistorySale, $Out> {
  _CustomerHistorySaleCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerHistorySale> $mapper =
      CustomerHistorySaleMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? receiptNumber,
    num? totalAmount,
    OrderStatus? orderStatus,
    PaymentStatus? paymentStatus,
    bool? isPaid,
    int? packs,
    Object? notes = $none,
    Object? pickedUpAt = $none,
    Object? postedDate = $none,
    Object? created = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (receiptNumber != null) #receiptNumber: receiptNumber,
      if (totalAmount != null) #totalAmount: totalAmount,
      if (orderStatus != null) #orderStatus: orderStatus,
      if (paymentStatus != null) #paymentStatus: paymentStatus,
      if (isPaid != null) #isPaid: isPaid,
      if (packs != null) #packs: packs,
      if (notes != $none) #notes: notes,
      if (pickedUpAt != $none) #pickedUpAt: pickedUpAt,
      if (postedDate != $none) #postedDate: postedDate,
      if (created != $none) #created: created,
    }),
  );
  @override
  CustomerHistorySale $make(CopyWithData data) => CustomerHistorySale(
    id: data.get(#id, or: $value.id),
    receiptNumber: data.get(#receiptNumber, or: $value.receiptNumber),
    totalAmount: data.get(#totalAmount, or: $value.totalAmount),
    orderStatus: data.get(#orderStatus, or: $value.orderStatus),
    paymentStatus: data.get(#paymentStatus, or: $value.paymentStatus),
    isPaid: data.get(#isPaid, or: $value.isPaid),
    packs: data.get(#packs, or: $value.packs),
    notes: data.get(#notes, or: $value.notes),
    pickedUpAt: data.get(#pickedUpAt, or: $value.pickedUpAt),
    postedDate: data.get(#postedDate, or: $value.postedDate),
    created: data.get(#created, or: $value.created),
  );

  @override
  CustomerHistorySaleCopyWith<$R2, CustomerHistorySale, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CustomerHistorySaleCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CustomerHistoryItemMapper extends ClassMapperBase<CustomerHistoryItem> {
  CustomerHistoryItemMapper._();

  static CustomerHistoryItemMapper? _instance;
  static CustomerHistoryItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomerHistoryItemMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerHistoryItem';

  static String _$id(CustomerHistoryItem v) => v.id;
  static const Field<CustomerHistoryItem, String> _f$id = Field('id', _$id);
  static String _$productName(CustomerHistoryItem v) => v.productName;
  static const Field<CustomerHistoryItem, String> _f$productName = Field(
    'productName',
    _$productName,
  );
  static num _$quantity(CustomerHistoryItem v) => v.quantity;
  static const Field<CustomerHistoryItem, num> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static num _$unitPrice(CustomerHistoryItem v) => v.unitPrice;
  static const Field<CustomerHistoryItem, num> _f$unitPrice = Field(
    'unitPrice',
    _$unitPrice,
  );
  static num _$subtotal(CustomerHistoryItem v) => v.subtotal;
  static const Field<CustomerHistoryItem, num> _f$subtotal = Field(
    'subtotal',
    _$subtotal,
  );

  @override
  final MappableFields<CustomerHistoryItem> fields = const {
    #id: _f$id,
    #productName: _f$productName,
    #quantity: _f$quantity,
    #unitPrice: _f$unitPrice,
    #subtotal: _f$subtotal,
  };

  static CustomerHistoryItem _instantiate(DecodingData data) {
    return CustomerHistoryItem(
      id: data.dec(_f$id),
      productName: data.dec(_f$productName),
      quantity: data.dec(_f$quantity),
      unitPrice: data.dec(_f$unitPrice),
      subtotal: data.dec(_f$subtotal),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomerHistoryItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerHistoryItem>(map);
  }

  static CustomerHistoryItem fromJson(String json) {
    return ensureInitialized().decodeJson<CustomerHistoryItem>(json);
  }
}

mixin CustomerHistoryItemMappable {
  String toJson() {
    return CustomerHistoryItemMapper.ensureInitialized()
        .encodeJson<CustomerHistoryItem>(this as CustomerHistoryItem);
  }

  Map<String, dynamic> toMap() {
    return CustomerHistoryItemMapper.ensureInitialized()
        .encodeMap<CustomerHistoryItem>(this as CustomerHistoryItem);
  }

  CustomerHistoryItemCopyWith<
    CustomerHistoryItem,
    CustomerHistoryItem,
    CustomerHistoryItem
  >
  get copyWith =>
      _CustomerHistoryItemCopyWithImpl<
        CustomerHistoryItem,
        CustomerHistoryItem
      >(this as CustomerHistoryItem, $identity, $identity);
  @override
  String toString() {
    return CustomerHistoryItemMapper.ensureInitialized().stringifyValue(
      this as CustomerHistoryItem,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerHistoryItemMapper.ensureInitialized().equalsValue(
      this as CustomerHistoryItem,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerHistoryItemMapper.ensureInitialized().hashValue(
      this as CustomerHistoryItem,
    );
  }
}

extension CustomerHistoryItemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerHistoryItem, $Out> {
  CustomerHistoryItemCopyWith<$R, CustomerHistoryItem, $Out>
  get $asCustomerHistoryItem => $base.as(
    (v, t, t2) => _CustomerHistoryItemCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CustomerHistoryItemCopyWith<
  $R,
  $In extends CustomerHistoryItem,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? productName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
  });
  CustomerHistoryItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CustomerHistoryItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerHistoryItem, $Out>
    implements CustomerHistoryItemCopyWith<$R, CustomerHistoryItem, $Out> {
  _CustomerHistoryItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerHistoryItem> $mapper =
      CustomerHistoryItemMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? productName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (productName != null) #productName: productName,
      if (quantity != null) #quantity: quantity,
      if (unitPrice != null) #unitPrice: unitPrice,
      if (subtotal != null) #subtotal: subtotal,
    }),
  );
  @override
  CustomerHistoryItem $make(CopyWithData data) => CustomerHistoryItem(
    id: data.get(#id, or: $value.id),
    productName: data.get(#productName, or: $value.productName),
    quantity: data.get(#quantity, or: $value.quantity),
    unitPrice: data.get(#unitPrice, or: $value.unitPrice),
    subtotal: data.get(#subtotal, or: $value.subtotal),
  );

  @override
  CustomerHistoryItemCopyWith<$R2, CustomerHistoryItem, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CustomerHistoryItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CustomerHistoryServiceItemMapper
    extends ClassMapperBase<CustomerHistoryServiceItem> {
  CustomerHistoryServiceItemMapper._();

  static CustomerHistoryServiceItemMapper? _instance;
  static CustomerHistoryServiceItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = CustomerHistoryServiceItemMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerHistoryServiceItem';

  static String _$id(CustomerHistoryServiceItem v) => v.id;
  static const Field<CustomerHistoryServiceItem, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$serviceName(CustomerHistoryServiceItem v) => v.serviceName;
  static const Field<CustomerHistoryServiceItem, String> _f$serviceName = Field(
    'serviceName',
    _$serviceName,
  );
  static num _$quantity(CustomerHistoryServiceItem v) => v.quantity;
  static const Field<CustomerHistoryServiceItem, num> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static num _$unitPrice(CustomerHistoryServiceItem v) => v.unitPrice;
  static const Field<CustomerHistoryServiceItem, num> _f$unitPrice = Field(
    'unitPrice',
    _$unitPrice,
  );
  static num _$subtotal(CustomerHistoryServiceItem v) => v.subtotal;
  static const Field<CustomerHistoryServiceItem, num> _f$subtotal = Field(
    'subtotal',
    _$subtotal,
  );
  static String? _$status(CustomerHistoryServiceItem v) => v.status;
  static const Field<CustomerHistoryServiceItem, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
  );
  static String? _$machineName(CustomerHistoryServiceItem v) => v.machineName;
  static const Field<CustomerHistoryServiceItem, String> _f$machineName = Field(
    'machineName',
    _$machineName,
    opt: true,
  );
  static String? _$storageName(CustomerHistoryServiceItem v) => v.storageName;
  static const Field<CustomerHistoryServiceItem, String> _f$storageName = Field(
    'storageName',
    _$storageName,
    opt: true,
  );

  @override
  final MappableFields<CustomerHistoryServiceItem> fields = const {
    #id: _f$id,
    #serviceName: _f$serviceName,
    #quantity: _f$quantity,
    #unitPrice: _f$unitPrice,
    #subtotal: _f$subtotal,
    #status: _f$status,
    #machineName: _f$machineName,
    #storageName: _f$storageName,
  };

  static CustomerHistoryServiceItem _instantiate(DecodingData data) {
    return CustomerHistoryServiceItem(
      id: data.dec(_f$id),
      serviceName: data.dec(_f$serviceName),
      quantity: data.dec(_f$quantity),
      unitPrice: data.dec(_f$unitPrice),
      subtotal: data.dec(_f$subtotal),
      status: data.dec(_f$status),
      machineName: data.dec(_f$machineName),
      storageName: data.dec(_f$storageName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomerHistoryServiceItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerHistoryServiceItem>(map);
  }

  static CustomerHistoryServiceItem fromJson(String json) {
    return ensureInitialized().decodeJson<CustomerHistoryServiceItem>(json);
  }
}

mixin CustomerHistoryServiceItemMappable {
  String toJson() {
    return CustomerHistoryServiceItemMapper.ensureInitialized()
        .encodeJson<CustomerHistoryServiceItem>(
          this as CustomerHistoryServiceItem,
        );
  }

  Map<String, dynamic> toMap() {
    return CustomerHistoryServiceItemMapper.ensureInitialized()
        .encodeMap<CustomerHistoryServiceItem>(
          this as CustomerHistoryServiceItem,
        );
  }

  CustomerHistoryServiceItemCopyWith<
    CustomerHistoryServiceItem,
    CustomerHistoryServiceItem,
    CustomerHistoryServiceItem
  >
  get copyWith =>
      _CustomerHistoryServiceItemCopyWithImpl<
        CustomerHistoryServiceItem,
        CustomerHistoryServiceItem
      >(this as CustomerHistoryServiceItem, $identity, $identity);
  @override
  String toString() {
    return CustomerHistoryServiceItemMapper.ensureInitialized().stringifyValue(
      this as CustomerHistoryServiceItem,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerHistoryServiceItemMapper.ensureInitialized().equalsValue(
      this as CustomerHistoryServiceItem,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerHistoryServiceItemMapper.ensureInitialized().hashValue(
      this as CustomerHistoryServiceItem,
    );
  }
}

extension CustomerHistoryServiceItemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerHistoryServiceItem, $Out> {
  CustomerHistoryServiceItemCopyWith<$R, CustomerHistoryServiceItem, $Out>
  get $asCustomerHistoryServiceItem => $base.as(
    (v, t, t2) => _CustomerHistoryServiceItemCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CustomerHistoryServiceItemCopyWith<
  $R,
  $In extends CustomerHistoryServiceItem,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? serviceName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
    String? status,
    String? machineName,
    String? storageName,
  });
  CustomerHistoryServiceItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CustomerHistoryServiceItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerHistoryServiceItem, $Out>
    implements
        CustomerHistoryServiceItemCopyWith<
          $R,
          CustomerHistoryServiceItem,
          $Out
        > {
  _CustomerHistoryServiceItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerHistoryServiceItem> $mapper =
      CustomerHistoryServiceItemMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? serviceName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
    Object? status = $none,
    Object? machineName = $none,
    Object? storageName = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (serviceName != null) #serviceName: serviceName,
      if (quantity != null) #quantity: quantity,
      if (unitPrice != null) #unitPrice: unitPrice,
      if (subtotal != null) #subtotal: subtotal,
      if (status != $none) #status: status,
      if (machineName != $none) #machineName: machineName,
      if (storageName != $none) #storageName: storageName,
    }),
  );
  @override
  CustomerHistoryServiceItem $make(CopyWithData data) =>
      CustomerHistoryServiceItem(
        id: data.get(#id, or: $value.id),
        serviceName: data.get(#serviceName, or: $value.serviceName),
        quantity: data.get(#quantity, or: $value.quantity),
        unitPrice: data.get(#unitPrice, or: $value.unitPrice),
        subtotal: data.get(#subtotal, or: $value.subtotal),
        status: data.get(#status, or: $value.status),
        machineName: data.get(#machineName, or: $value.machineName),
        storageName: data.get(#storageName, or: $value.storageName),
      );

  @override
  CustomerHistoryServiceItemCopyWith<$R2, CustomerHistoryServiceItem, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CustomerHistoryServiceItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CustomerHistorySaleDetailMapper
    extends ClassMapperBase<CustomerHistorySaleDetail> {
  CustomerHistorySaleDetailMapper._();

  static CustomerHistorySaleDetailMapper? _instance;
  static CustomerHistorySaleDetailMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = CustomerHistorySaleDetailMapper._(),
      );
      CustomerHistoryCustomerMapper.ensureInitialized();
      CustomerHistorySaleMapper.ensureInitialized();
      CustomerHistoryItemMapper.ensureInitialized();
      CustomerHistoryServiceItemMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerHistorySaleDetail';

  static CustomerHistoryCustomer _$customer(CustomerHistorySaleDetail v) =>
      v.customer;
  static const Field<CustomerHistorySaleDetail, CustomerHistoryCustomer>
  _f$customer = Field('customer', _$customer);
  static CustomerHistorySale _$sale(CustomerHistorySaleDetail v) => v.sale;
  static const Field<CustomerHistorySaleDetail, CustomerHistorySale> _f$sale =
      Field('sale', _$sale);
  static List<CustomerHistoryItem> _$items(CustomerHistorySaleDetail v) =>
      v.items;
  static const Field<CustomerHistorySaleDetail, List<CustomerHistoryItem>>
  _f$items = Field('items', _$items);
  static List<CustomerHistoryServiceItem> _$services(
    CustomerHistorySaleDetail v,
  ) => v.services;
  static const Field<
    CustomerHistorySaleDetail,
    List<CustomerHistoryServiceItem>
  >
  _f$services = Field('services', _$services);

  @override
  final MappableFields<CustomerHistorySaleDetail> fields = const {
    #customer: _f$customer,
    #sale: _f$sale,
    #items: _f$items,
    #services: _f$services,
  };

  static CustomerHistorySaleDetail _instantiate(DecodingData data) {
    return CustomerHistorySaleDetail(
      customer: data.dec(_f$customer),
      sale: data.dec(_f$sale),
      items: data.dec(_f$items),
      services: data.dec(_f$services),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomerHistorySaleDetail fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerHistorySaleDetail>(map);
  }

  static CustomerHistorySaleDetail fromJson(String json) {
    return ensureInitialized().decodeJson<CustomerHistorySaleDetail>(json);
  }
}

mixin CustomerHistorySaleDetailMappable {
  String toJson() {
    return CustomerHistorySaleDetailMapper.ensureInitialized()
        .encodeJson<CustomerHistorySaleDetail>(
          this as CustomerHistorySaleDetail,
        );
  }

  Map<String, dynamic> toMap() {
    return CustomerHistorySaleDetailMapper.ensureInitialized()
        .encodeMap<CustomerHistorySaleDetail>(
          this as CustomerHistorySaleDetail,
        );
  }

  CustomerHistorySaleDetailCopyWith<
    CustomerHistorySaleDetail,
    CustomerHistorySaleDetail,
    CustomerHistorySaleDetail
  >
  get copyWith =>
      _CustomerHistorySaleDetailCopyWithImpl<
        CustomerHistorySaleDetail,
        CustomerHistorySaleDetail
      >(this as CustomerHistorySaleDetail, $identity, $identity);
  @override
  String toString() {
    return CustomerHistorySaleDetailMapper.ensureInitialized().stringifyValue(
      this as CustomerHistorySaleDetail,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerHistorySaleDetailMapper.ensureInitialized().equalsValue(
      this as CustomerHistorySaleDetail,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerHistorySaleDetailMapper.ensureInitialized().hashValue(
      this as CustomerHistorySaleDetail,
    );
  }
}

extension CustomerHistorySaleDetailValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerHistorySaleDetail, $Out> {
  CustomerHistorySaleDetailCopyWith<$R, CustomerHistorySaleDetail, $Out>
  get $asCustomerHistorySaleDetail => $base.as(
    (v, t, t2) => _CustomerHistorySaleDetailCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CustomerHistorySaleDetailCopyWith<
  $R,
  $In extends CustomerHistorySaleDetail,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  CustomerHistoryCustomerCopyWith<
    $R,
    CustomerHistoryCustomer,
    CustomerHistoryCustomer
  >
  get customer;
  CustomerHistorySaleCopyWith<$R, CustomerHistorySale, CustomerHistorySale>
  get sale;
  ListCopyWith<
    $R,
    CustomerHistoryItem,
    CustomerHistoryItemCopyWith<$R, CustomerHistoryItem, CustomerHistoryItem>
  >
  get items;
  ListCopyWith<
    $R,
    CustomerHistoryServiceItem,
    CustomerHistoryServiceItemCopyWith<
      $R,
      CustomerHistoryServiceItem,
      CustomerHistoryServiceItem
    >
  >
  get services;
  $R call({
    CustomerHistoryCustomer? customer,
    CustomerHistorySale? sale,
    List<CustomerHistoryItem>? items,
    List<CustomerHistoryServiceItem>? services,
  });
  CustomerHistorySaleDetailCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CustomerHistorySaleDetailCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerHistorySaleDetail, $Out>
    implements
        CustomerHistorySaleDetailCopyWith<$R, CustomerHistorySaleDetail, $Out> {
  _CustomerHistorySaleDetailCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerHistorySaleDetail> $mapper =
      CustomerHistorySaleDetailMapper.ensureInitialized();
  @override
  CustomerHistoryCustomerCopyWith<
    $R,
    CustomerHistoryCustomer,
    CustomerHistoryCustomer
  >
  get customer => $value.customer.copyWith.$chain((v) => call(customer: v));
  @override
  CustomerHistorySaleCopyWith<$R, CustomerHistorySale, CustomerHistorySale>
  get sale => $value.sale.copyWith.$chain((v) => call(sale: v));
  @override
  ListCopyWith<
    $R,
    CustomerHistoryItem,
    CustomerHistoryItemCopyWith<$R, CustomerHistoryItem, CustomerHistoryItem>
  >
  get items => ListCopyWith(
    $value.items,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(items: v),
  );
  @override
  ListCopyWith<
    $R,
    CustomerHistoryServiceItem,
    CustomerHistoryServiceItemCopyWith<
      $R,
      CustomerHistoryServiceItem,
      CustomerHistoryServiceItem
    >
  >
  get services => ListCopyWith(
    $value.services,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(services: v),
  );
  @override
  $R call({
    CustomerHistoryCustomer? customer,
    CustomerHistorySale? sale,
    List<CustomerHistoryItem>? items,
    List<CustomerHistoryServiceItem>? services,
  }) => $apply(
    FieldCopyWithData({
      if (customer != null) #customer: customer,
      if (sale != null) #sale: sale,
      if (items != null) #items: items,
      if (services != null) #services: services,
    }),
  );
  @override
  CustomerHistorySaleDetail $make(CopyWithData data) =>
      CustomerHistorySaleDetail(
        customer: data.get(#customer, or: $value.customer),
        sale: data.get(#sale, or: $value.sale),
        items: data.get(#items, or: $value.items),
        services: data.get(#services, or: $value.services),
      );

  @override
  CustomerHistorySaleDetailCopyWith<$R2, CustomerHistorySaleDetail, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CustomerHistorySaleDetailCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CustomerHistoryMapper extends ClassMapperBase<CustomerHistory> {
  CustomerHistoryMapper._();

  static CustomerHistoryMapper? _instance;
  static CustomerHistoryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomerHistoryMapper._());
      CustomerHistoryCustomerMapper.ensureInitialized();
      CustomerHistorySaleMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerHistory';

  static CustomerHistoryCustomer _$customer(CustomerHistory v) => v.customer;
  static const Field<CustomerHistory, CustomerHistoryCustomer> _f$customer =
      Field('customer', _$customer);
  static List<CustomerHistorySale> _$sales(CustomerHistory v) => v.sales;
  static const Field<CustomerHistory, List<CustomerHistorySale>> _f$sales =
      Field('sales', _$sales);

  @override
  final MappableFields<CustomerHistory> fields = const {
    #customer: _f$customer,
    #sales: _f$sales,
  };

  static CustomerHistory _instantiate(DecodingData data) {
    return CustomerHistory(
      customer: data.dec(_f$customer),
      sales: data.dec(_f$sales),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomerHistory fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerHistory>(map);
  }

  static CustomerHistory fromJson(String json) {
    return ensureInitialized().decodeJson<CustomerHistory>(json);
  }
}

mixin CustomerHistoryMappable {
  String toJson() {
    return CustomerHistoryMapper.ensureInitialized()
        .encodeJson<CustomerHistory>(this as CustomerHistory);
  }

  Map<String, dynamic> toMap() {
    return CustomerHistoryMapper.ensureInitialized().encodeMap<CustomerHistory>(
      this as CustomerHistory,
    );
  }

  CustomerHistoryCopyWith<CustomerHistory, CustomerHistory, CustomerHistory>
  get copyWith =>
      _CustomerHistoryCopyWithImpl<CustomerHistory, CustomerHistory>(
        this as CustomerHistory,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CustomerHistoryMapper.ensureInitialized().stringifyValue(
      this as CustomerHistory,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerHistoryMapper.ensureInitialized().equalsValue(
      this as CustomerHistory,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerHistoryMapper.ensureInitialized().hashValue(
      this as CustomerHistory,
    );
  }
}

extension CustomerHistoryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerHistory, $Out> {
  CustomerHistoryCopyWith<$R, CustomerHistory, $Out> get $asCustomerHistory =>
      $base.as((v, t, t2) => _CustomerHistoryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CustomerHistoryCopyWith<$R, $In extends CustomerHistory, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  CustomerHistoryCustomerCopyWith<
    $R,
    CustomerHistoryCustomer,
    CustomerHistoryCustomer
  >
  get customer;
  ListCopyWith<
    $R,
    CustomerHistorySale,
    CustomerHistorySaleCopyWith<$R, CustomerHistorySale, CustomerHistorySale>
  >
  get sales;
  $R call({
    CustomerHistoryCustomer? customer,
    List<CustomerHistorySale>? sales,
  });
  CustomerHistoryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CustomerHistoryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerHistory, $Out>
    implements CustomerHistoryCopyWith<$R, CustomerHistory, $Out> {
  _CustomerHistoryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerHistory> $mapper =
      CustomerHistoryMapper.ensureInitialized();
  @override
  CustomerHistoryCustomerCopyWith<
    $R,
    CustomerHistoryCustomer,
    CustomerHistoryCustomer
  >
  get customer => $value.customer.copyWith.$chain((v) => call(customer: v));
  @override
  ListCopyWith<
    $R,
    CustomerHistorySale,
    CustomerHistorySaleCopyWith<$R, CustomerHistorySale, CustomerHistorySale>
  >
  get sales => ListCopyWith(
    $value.sales,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(sales: v),
  );
  @override
  $R call({
    CustomerHistoryCustomer? customer,
    List<CustomerHistorySale>? sales,
  }) => $apply(
    FieldCopyWithData({
      if (customer != null) #customer: customer,
      if (sales != null) #sales: sales,
    }),
  );
  @override
  CustomerHistory $make(CopyWithData data) => CustomerHistory(
    customer: data.get(#customer, or: $value.customer),
    sales: data.get(#sales, or: $value.sales),
  );

  @override
  CustomerHistoryCopyWith<$R2, CustomerHistory, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CustomerHistoryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

