import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/customer_repository.dart';
import '../../domain/customer.dart';

part 'customers_controller.g.dart';

/// Controller for managing the list of customers.
@Riverpod(keepAlive: true)
class CustomersController extends _$CustomersController {
  CustomerRepository get _repository => ref.read(customerRepositoryProvider);

  String? get _branchFilter {
    final branchId = ref.read(currentBranchIdProvider);
    if (branchId == null) return null;
    return PBFilter().relation('branch', branchId).build();
  }

  @override
  Future<List<Customer>> build() async {
    final branchId = ref.watch(currentBranchIdProvider);
    final filter = branchId == null
        ? null
        : PBFilter().relation('branch', branchId).build();
    final result = await _repository.fetchAll(filter: filter);

    return result.fold(
      (failure) => throw failure,
      (customers) => customers,
    );
  }

  /// Refreshes the customer list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchAll(filter: _branchFilter);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (customers) => AsyncData(customers),
    );
  }

  /// Creates a new customer, stamped with the current branch.
  Future<Customer?> createCustomer(Customer customer) async {
    final branchId =
        (customer.branchId != null && customer.branchId!.isNotEmpty)
            ? customer.branchId
            : ref.read(currentBranchIdProvider);
    if (branchId == null || branchId.isEmpty) {
      return null;
    }

    final result = await _repository.create(
      customer.copyWith(branchId: branchId),
    );
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

  /// Moves a customer to another branch.
  Future<bool> transferBranch(Customer customer, String branchId) async {
    if (branchId.isEmpty || branchId == customer.branchId) return false;
    return updateCustomer(customer.copyWith(branchId: branchId));
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
