import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/customer_repository.dart';
import '../../domain/customer.dart';

part 'customer_provider.g.dart';

/// Provider for a single customer by ID.
@riverpod
Future<Customer?> customer(Ref ref, String id) async {
  final repository = ref.read(customerRepositoryProvider);
  final result = await repository.fetchOne(id);

  return result.fold(
    (failure) => null,
    (customer) => customer,
  );
}
