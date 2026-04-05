import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_search_controller.g.dart';

/// Available search fields for sales.
const saleSearchableFields = [
  'receiptNumber',
  'customerName',
  'paymentRef',
  'notes',
];

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
