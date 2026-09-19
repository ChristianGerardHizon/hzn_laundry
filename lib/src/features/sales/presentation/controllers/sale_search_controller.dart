import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_search_controller.g.dart';

/// Available search fields for sales.
const saleSearchableFields = [
  'receiptNumber',
  'customerName',
  'paymentRef',
  'notes',
];

/// Payment status / method filters for the sales list.
class SalePaymentFilters {
  const SalePaymentFilters({
    this.paid = false,
    this.unpaid = false,
    this.cash = false,
    this.gcashBank = false,
  });

  final bool paid;
  final bool unpaid;
  final bool cash;
  final bool gcashBank;

  bool get hasActiveFilters => paid || unpaid || cash || gcashBank;

  int get activeCount =>
      (paid ? 1 : 0) +
      (unpaid ? 1 : 0) +
      (cash ? 1 : 0) +
      (gcashBank ? 1 : 0);

  SalePaymentFilters copyWith({
    bool? paid,
    bool? unpaid,
    bool? cash,
    bool? gcashBank,
  }) {
    return SalePaymentFilters(
      paid: paid ?? this.paid,
      unpaid: unpaid ?? this.unpaid,
      cash: cash ?? this.cash,
      gcashBank: gcashBank ?? this.gcashBank,
    );
  }

  /// PocketBase filter fragment, or null when nothing is selected.
  String? toPbFilter() {
    final parts = <String>[];

    // Only narrow when exactly one payment-status option is selected.
    if (paid && !unpaid) {
      parts.add('isPaid = true');
    } else if (unpaid && !paid) {
      parts.add('isPaid = false');
    }

    final methodParts = <String>[];
    if (cash) {
      methodParts.add("payments_via_sale.paymentMethod = 'cash'");
    }
    if (gcashBank) {
      methodParts.add(
        "(payments_via_sale.paymentMethod = 'gcash' || "
        "payments_via_sale.paymentMethod = 'bankTransfer')",
      );
    }
    if (methodParts.isNotEmpty) {
      parts.add(
        '(payments_via_sale.isVoided = false && (${methodParts.join(' || ')}))',
      );
    }

    if (parts.isEmpty) return null;
    return parts.join(' && ');
  }
}

/// Provider for sale search query state.
@riverpod
class SaleSearchQuery extends _$SaleSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Provider for managing which fields are included in sale search.
@riverpod
class SaleSearchFields extends _$SaleSearchFields {
  @override
  Set<String> build() => {'receiptNumber', 'customerName'};

  void toggleField(String field) {
    if (state.contains(field)) {
      // Prevent removing if it's the last field
      if (state.length <= 1) return;
      state = {...state}..remove(field);
    } else {
      state = {...state, field};
    }
  }

  void reset() {
    state = {'receiptNumber', 'customerName'};
  }

  void setFields(Set<String> fields) {
    // Ensure at least one field is selected
    if (fields.isEmpty) {
      state = {'receiptNumber', 'customerName'};
    } else {
      state = fields;
    }
  }
}

/// Provider for paid / unpaid / payment-method list filters.
@riverpod
class SalePaymentFiltersController extends _$SalePaymentFiltersController {
  @override
  SalePaymentFilters build() => const SalePaymentFilters();

  void togglePaid() => state = state.copyWith(paid: !state.paid);

  void toggleUnpaid() => state = state.copyWith(unpaid: !state.unpaid);

  void toggleCash() => state = state.copyWith(cash: !state.cash);

  void toggleGcashBank() =>
      state = state.copyWith(gcashBank: !state.gcashBank);

  void reset() => state = const SalePaymentFilters();
}
