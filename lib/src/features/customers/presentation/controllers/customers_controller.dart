import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/customer_repository.dart';
import '../../domain/customer.dart';

part 'customers_controller.g.dart';

/// Controller for managing the list of customers.
@Riverpod(keepAlive: true)
class CustomersController extends _$CustomersController {
  CustomerRepository get _repository => ref.read(customerRepositoryProvider);

  @override
  Future<List<Customer>> build() async {
    final result = await _repository.fetchAll();

    return result.fold(
      (failure) => throw failure,
      (customers) => customers,
    );
  }

  /// Refreshes the customer list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchAll();

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (customers) => AsyncData(customers),
    );
  }

  /// Creates a new customer.
  Future<Customer?> createCustomer(Customer customer) async {
    final result = await _repository.create(customer);
    return result.fold(
      (failure) => null,
      (created) {
        refresh();
        return created;
      },
    );
  }

  /// Updates an existing customer.
  Future<bool> updateCustomer(Customer customer) async {
    final result = await _repository.update(customer);
    return result.fold(
      (failure) => false,
      (updated) {
        refresh();
        return true;
      },
    );
  }

  /// Deletes a customer.
  Future<bool> deleteCustomer(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
