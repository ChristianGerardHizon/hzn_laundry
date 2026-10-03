import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/customer_address.dart';
import '../dto/customer_address_dto.dart';

part 'customer_address_repository.g.dart';

/// Saved delivery addresses per customer. The server keeps exactly one default
/// per customer (first address becomes default; setting a default clears the
/// others).
abstract class CustomerAddressRepository {
  FutureEither<List<CustomerAddress>> fetchForCustomer(String customerId);
  FutureEither<CustomerAddress> create(CustomerAddress address);
  FutureEither<CustomerAddress> update(CustomerAddress address);

  /// Soft delete. The server promotes another address if this was the default.
  FutureEither<void> delete(String id);
}

@Riverpod(keepAlive: true)
CustomerAddressRepository customerAddressRepository(Ref ref) =>
    CustomerAddressRepositoryImpl(ref.watch(pocketbaseProvider));

class CustomerAddressRepositoryImpl implements CustomerAddressRepository {
  CustomerAddressRepositoryImpl(this._pb);

  final PocketBase _pb;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.customerAddresses);

  @override
  FutureEither<List<CustomerAddress>> fetchForCustomer(String customerId) {
    return TaskEither.tryCatch(
      () async {
        final records = await _collection.getFullList(
          filter:
              PBFilter().relation('customer', customerId).notDeleted().build(),
          sort: '-isDefault,created',
        );
        return records.map(CustomerAddressDto.fromRecord).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<CustomerAddress> create(CustomerAddress address) {
    return TaskEither.tryCatch(
      () async => CustomerAddressDto.fromRecord(
        await _collection.create(body: CustomerAddressDto.toBody(address)),
      ),
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<CustomerAddress> update(CustomerAddress address) {
    return TaskEither.tryCatch(
      () async => CustomerAddressDto.fromRecord(
        await _collection.update(
          address.id,
          body: CustomerAddressDto.toBody(address),
        ),
      ),
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) {
    return TaskEither.tryCatch(
      () async {
        await _collection.update(id, body: {'isDeleted': true});
      },
      Failure.handle,
    ).run();
  }
}
