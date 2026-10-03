import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/customer_address_repository.dart';
import '../../domain/customer_address.dart';

part 'customer_addresses_controller.g.dart';

/// Saved delivery addresses of one customer (default first).
@riverpod
class CustomerAddressesController extends _$CustomerAddressesController {
  CustomerAddressRepository get _repository =>
      ref.read(customerAddressRepositoryProvider);

  @override
  Future<List<CustomerAddress>> build(String customerId) async {
    if (customerId.isEmpty) return const [];
    final result = await _repository.fetchForCustomer(customerId);
    return result.fold((failure) => throw failure, (list) => list);
  }

  /// Creates (empty id) or updates [address]. Returns the failure message, or
  /// null on success. The first address becomes the default on the server.
  Future<String?> save(CustomerAddress address) async {
    final result = address.id.isEmpty
        ? await _repository.create(address)
        : await _repository.update(address);
    return result.fold(
      (failure) => failure.messageString,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }

  Future<String?> setDefault(CustomerAddress address) =>
      save(address.copyWith(isDefault: true));

  Future<String?> remove(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => failure.messageString,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }
}
