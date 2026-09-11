// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'sale_service_item.dart';

class SaleServiceItemMapper extends ClassMapperBase<SaleServiceItem> {
  SaleServiceItemMapper._();

  static SaleServiceItemMapper? _instance;
  static SaleServiceItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SaleServiceItemMapper._());
      ServiceMapper.ensureInitialized();
      MachineMapper.ensureInitialized();
      StorageLocationMapper.ensureInitialized();
      ServiceItemStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SaleServiceItem';

  static String _$id(SaleServiceItem v) => v.id;
  static const Field<SaleServiceItem, String> _f$id = Field('id', _$id);
  static String _$saleId(SaleServiceItem v) => v.saleId;
  static const Field<SaleServiceItem, String> _f$saleId = Field(
    'saleId',
    _$saleId,
  );
  static String _$serviceId(SaleServiceItem v) => v.serviceId;
  static const Field<SaleServiceItem, String> _f$serviceId = Field(
    'serviceId',
    _$serviceId,
  );
  static String _$serviceName(SaleServiceItem v) => v.serviceName;
  static const Field<SaleServiceItem, String> _f$serviceName = Field(
    'serviceName',
    _$serviceName,
  );
  static num _$quantity(SaleServiceItem v) => v.quantity;
  static const Field<SaleServiceItem, num> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static num _$unitPrice(SaleServiceItem v) => v.unitPrice;
  static const Field<SaleServiceItem, num> _f$unitPrice = Field(
    'unitPrice',
    _$unitPrice,
  );
  static num _$subtotal(SaleServiceItem v) => v.subtotal;
  static const Field<SaleServiceItem, num> _f$subtotal = Field(
    'subtotal',
    _$subtotal,
  );
  static Service? _$service(SaleServiceItem v) => v.service;
  static const Field<SaleServiceItem, Service> _f$service = Field(
    'service',
    _$service,
    opt: true,
  );
  static List<String> _$machineIds(SaleServiceItem v) => v.machineIds;
  static const Field<SaleServiceItem, List<String>> _f$machineIds = Field(
    'machineIds',
    _$machineIds,
    opt: true,
    def: const [],
  );
  static String? _$machineId(SaleServiceItem v) => v.machineId;
  static const Field<SaleServiceItem, String> _f$machineId = Field(
    'machineId',
    _$machineId,
    opt: true,
  );
  static String? _$machineName(SaleServiceItem v) => v.machineName;
  static const Field<SaleServiceItem, String> _f$machineName = Field(
    'machineName',
    _$machineName,
    opt: true,
  );
  static Machine? _$machine(SaleServiceItem v) => v.machine;
  static const Field<SaleServiceItem, Machine> _f$machine = Field(
    'machine',
    _$machine,
    opt: true,
  );
  static Map<String, int> _$machineLoadCounts(SaleServiceItem v) =>
      v.machineLoadCounts;
  static const Field<SaleServiceItem, Map<String, int>> _f$machineLoadCounts =
      Field('machineLoadCounts', _$machineLoadCounts, opt: true, def: const {});
  static Map<String, double> _$machineWeights(SaleServiceItem v) =>
      v.machineWeights;
  static const Field<SaleServiceItem, Map<String, double>> _f$machineWeights =
      Field('machineWeights', _$machineWeights, opt: true, def: const {});
  static List<String> _$storageIds(SaleServiceItem v) => v.storageIds;
  static const Field<SaleServiceItem, List<String>> _f$storageIds = Field(
    'storageIds',
    _$storageIds,
    opt: true,
    def: const [],
  );
  static String? _$storageName(SaleServiceItem v) => v.storageName;
  static const Field<SaleServiceItem, String> _f$storageName = Field(
    'storageName',
    _$storageName,
    opt: true,
  );
  static List<StorageLocation> _$storageLocations(SaleServiceItem v) =>
      v.storageLocations;
  static const Field<SaleServiceItem, List<StorageLocation>>
  _f$storageLocations = Field(
    'storageLocations',
    _$storageLocations,
    opt: true,
    def: const [],
  );
  static ServiceItemStatus? _$status(SaleServiceItem v) => v.status;
  static const Field<SaleServiceItem, ServiceItemStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
  );
  static DateTime? _$created(SaleServiceItem v) => v.created;
  static const Field<SaleServiceItem, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(SaleServiceItem v) => v.updated;
  static const Field<SaleServiceItem, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<SaleServiceItem> fields = const {
    #id: _f$id,
    #saleId: _f$saleId,
    #serviceId: _f$serviceId,
    #serviceName: _f$serviceName,
    #quantity: _f$quantity,
    #unitPrice: _f$unitPrice,
    #subtotal: _f$subtotal,
    #service: _f$service,
    #machineIds: _f$machineIds,
    #machineId: _f$machineId,
    #machineName: _f$machineName,
    #machine: _f$machine,
    #machineLoadCounts: _f$machineLoadCounts,
    #machineWeights: _f$machineWeights,
    #storageIds: _f$storageIds,
    #storageName: _f$storageName,
    #storageLocations: _f$storageLocations,
    #status: _f$status,
    #created: _f$created,
    #updated: _f$updated,
  };

  static SaleServiceItem _instantiate(DecodingData data) {
    return SaleServiceItem(
      id: data.dec(_f$id),
      saleId: data.dec(_f$saleId),
      serviceId: data.dec(_f$serviceId),
      serviceName: data.dec(_f$serviceName),
      quantity: data.dec(_f$quantity),
      unitPrice: data.dec(_f$unitPrice),
      subtotal: data.dec(_f$subtotal),
      service: data.dec(_f$service),
      machineIds: data.dec(_f$machineIds),
      machineId: data.dec(_f$machineId),
      machineName: data.dec(_f$machineName),
      machine: data.dec(_f$machine),
      machineLoadCounts: data.dec(_f$machineLoadCounts),
      machineWeights: data.dec(_f$machineWeights),
      storageIds: data.dec(_f$storageIds),
      storageName: data.dec(_f$storageName),
      storageLocations: data.dec(_f$storageLocations),
      status: data.dec(_f$status),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SaleServiceItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SaleServiceItem>(map);
  }

  static SaleServiceItem fromJson(String json) {
    return ensureInitialized().decodeJson<SaleServiceItem>(json);
  }
}

mixin SaleServiceItemMappable {
  String toJson() {
    return SaleServiceItemMapper.ensureInitialized()
        .encodeJson<SaleServiceItem>(this as SaleServiceItem);
  }

  Map<String, dynamic> toMap() {
    return SaleServiceItemMapper.ensureInitialized().encodeMap<SaleServiceItem>(
      this as SaleServiceItem,
    );
  }

  SaleServiceItemCopyWith<SaleServiceItem, SaleServiceItem, SaleServiceItem>
  get copyWith =>
      _SaleServiceItemCopyWithImpl<SaleServiceItem, SaleServiceItem>(
        this as SaleServiceItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SaleServiceItemMapper.ensureInitialized().stringifyValue(
      this as SaleServiceItem,
    );
  }

  @override
  bool operator ==(Object other) {
    return SaleServiceItemMapper.ensureInitialized().equalsValue(
      this as SaleServiceItem,
      other,
    );
  }

  @override
  int get hashCode {
    return SaleServiceItemMapper.ensureInitialized().hashValue(
      this as SaleServiceItem,
    );
  }
}

extension SaleServiceItemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SaleServiceItem, $Out> {
  SaleServiceItemCopyWith<$R, SaleServiceItem, $Out> get $asSaleServiceItem =>
      $base.as((v, t, t2) => _SaleServiceItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SaleServiceItemCopyWith<$R, $In extends SaleServiceItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ServiceCopyWith<$R, Service, Service>? get service;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get machineIds;
  MachineCopyWith<$R, Machine, Machine>? get machine;
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>
  get machineLoadCounts;
  MapCopyWith<$R, String, double, ObjectCopyWith<$R, double, double>>
  get machineWeights;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get storageIds;
  ListCopyWith<
    $R,
    StorageLocation,
    StorageLocationCopyWith<$R, StorageLocation, StorageLocation>
  >
  get storageLocations;
  $R call({
    String? id,
    String? saleId,
    String? serviceId,
    String? serviceName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
    Service? service,
    List<String>? machineIds,
    String? machineId,
    String? machineName,
    Machine? machine,
    Map<String, int>? machineLoadCounts,
    Map<String, double>? machineWeights,
    List<String>? storageIds,
    String? storageName,
    List<StorageLocation>? storageLocations,
    ServiceItemStatus? status,
    DateTime? created,
    DateTime? updated,
  });
  SaleServiceItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SaleServiceItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SaleServiceItem, $Out>
    implements SaleServiceItemCopyWith<$R, SaleServiceItem, $Out> {
  _SaleServiceItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SaleServiceItem> $mapper =
      SaleServiceItemMapper.ensureInitialized();
  @override
  ServiceCopyWith<$R, Service, Service>? get service =>
      $value.service?.copyWith.$chain((v) => call(service: v));
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get machineIds =>
      ListCopyWith(
        $value.machineIds,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(machineIds: v),
      );
  @override
  MachineCopyWith<$R, Machine, Machine>? get machine =>
      $value.machine?.copyWith.$chain((v) => call(machine: v));
  @override
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>
  get machineLoadCounts => MapCopyWith(
    $value.machineLoadCounts,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(machineLoadCounts: v),
  );
  @override
  MapCopyWith<$R, String, double, ObjectCopyWith<$R, double, double>>
  get machineWeights => MapCopyWith(
    $value.machineWeights,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(machineWeights: v),
  );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get storageIds =>
      ListCopyWith(
        $value.storageIds,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(storageIds: v),
      );
  @override
  ListCopyWith<
    $R,
    StorageLocation,
    StorageLocationCopyWith<$R, StorageLocation, StorageLocation>
  >
  get storageLocations => ListCopyWith(
    $value.storageLocations,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(storageLocations: v),
  );
  @override
  $R call({
    String? id,
    String? saleId,
    String? serviceId,
    String? serviceName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
    Object? service = $none,
    List<String>? machineIds,
    Object? machineId = $none,
    Object? machineName = $none,
    Object? machine = $none,
    Map<String, int>? machineLoadCounts,
    Map<String, double>? machineWeights,
    List<String>? storageIds,
    Object? storageName = $none,
    List<StorageLocation>? storageLocations,
    Object? status = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (saleId != null) #saleId: saleId,
      if (serviceId != null) #serviceId: serviceId,
      if (serviceName != null) #serviceName: serviceName,
      if (quantity != null) #quantity: quantity,
      if (unitPrice != null) #unitPrice: unitPrice,
      if (subtotal != null) #subtotal: subtotal,
      if (service != $none) #service: service,
      if (machineIds != null) #machineIds: machineIds,
      if (machineId != $none) #machineId: machineId,
      if (machineName != $none) #machineName: machineName,
      if (machine != $none) #machine: machine,
      if (machineLoadCounts != null) #machineLoadCounts: machineLoadCounts,
      if (machineWeights != null) #machineWeights: machineWeights,
      if (storageIds != null) #storageIds: storageIds,
      if (storageName != $none) #storageName: storageName,
      if (storageLocations != null) #storageLocations: storageLocations,
      if (status != $none) #status: status,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  SaleServiceItem $make(CopyWithData data) => SaleServiceItem(
    id: data.get(#id, or: $value.id),
    saleId: data.get(#saleId, or: $value.saleId),
    serviceId: data.get(#serviceId, or: $value.serviceId),
    serviceName: data.get(#serviceName, or: $value.serviceName),
    quantity: data.get(#quantity, or: $value.quantity),
    unitPrice: data.get(#unitPrice, or: $value.unitPrice),
    subtotal: data.get(#subtotal, or: $value.subtotal),
    service: data.get(#service, or: $value.service),
    machineIds: data.get(#machineIds, or: $value.machineIds),
    machineId: data.get(#machineId, or: $value.machineId),
    machineName: data.get(#machineName, or: $value.machineName),
    machine: data.get(#machine, or: $value.machine),
    machineLoadCounts: data.get(
      #machineLoadCounts,
      or: $value.machineLoadCounts,
    ),
    machineWeights: data.get(#machineWeights, or: $value.machineWeights),
    storageIds: data.get(#storageIds, or: $value.storageIds),
    storageName: data.get(#storageName, or: $value.storageName),
    storageLocations: data.get(#storageLocations, or: $value.storageLocations),
    status: data.get(#status, or: $value.status),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  SaleServiceItemCopyWith<$R2, SaleServiceItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SaleServiceItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

