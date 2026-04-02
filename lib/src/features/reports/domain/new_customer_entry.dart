import '../../customers/domain/customer.dart';

/// A new customer with their total order count.
class NewCustomerEntry {
  const NewCustomerEntry({
    required this.customer,
    required this.orderCount,
    required this.totalSpent,
  });

  final Customer customer;
  final int orderCount;
  final num totalSpent;
}
