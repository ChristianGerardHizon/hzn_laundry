import 'package:flutter/material.dart';
import 'package:hzn_laundry/src/core/routing/org_scoped_navigation.dart';

import '../../../../core/routing/routes/customers.routes.dart';
import '../../../../core/routing/routes/employees.routes.dart';
import '../../../../core/routing/routes/products.routes.dart';
import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/routing/routes/services.routes.dart';
import '../../domain/activity_action.dart';
import '../../domain/activity_log.dart';

/// Display helpers for activity log list and detail screens.
abstract final class ActivityLogDisplay {
  ActivityLogDisplay._();

  static const navigableCollections = {
    'sales',
    'products',
    'services',
    'customers',
    'employees',
  };

  static const _fieldLabels = {
    'orderStatus': 'Order status',
    'status': 'Sale status',
    'totalAmount': 'Total',
    'isPaid': 'Paid',
    'unitPrice': 'Unit price',
    'subtotal': 'Subtotal',
    'price': 'Price',
    'quantity': 'Quantity',
    'name': 'Name',
    'customerName': 'Customer',
    'machineName': 'Machine',
    'storageName': 'Storage',
    'notes': 'Notes',
    'rate': 'Rate',
    'description': 'Description',
    'phone': 'Phone',
    'email': 'Email',
    'address': 'Address',
  };

  static const _orderStatusLabels = {
    'pending': 'Pending',
    'processing': 'Processing',
    'ready': 'Ready',
    'pickedUp': 'Picked Up',
  };

  static const _saleStatusLabels = {
    'pending': 'Pending',
    'completed': 'Completed',
    'refunded': 'Refunded',
    'voided': 'Voided',
  };

  static const _hiddenFields = {
    'pickedUpAt',
    'postedDate',
    'collectionId',
    'collectionName',
  };

  /// Whether [log] can open a related entity detail page.
  static bool canOpenRecord(ActivityLog log) {
    if (log.action == ActivityAction.delete) return false;
    return navigableCollections.contains(log.collection);
  }

  /// Human label for the Open-entity CTA (e.g. "Open sale").
  static String openRecordLabel(ActivityLog log) {
    switch (log.collection) {
      case 'sales':
        return 'Open sale';
      case 'products':
        return 'Open product';
      case 'services':
        return 'Open service';
      case 'customers':
        return 'Open customer';
      case 'employees':
        return 'Open employee';
      default:
        return 'Open record';
    }
  }

  /// Navigate to the related entity detail page when supported.
  static void openRecord(BuildContext context, ActivityLog log) {
    if (!canOpenRecord(log)) return;

    final id = log.recordId;
    switch (log.collection) {
      case 'sales':
        SaleDetailRoute(id: id).goScoped(context);
      case 'products':
        ProductDetailRoute(id: id).goScoped(context);
      case 'services':
        ServiceDetailRoute(id: id).goScoped(context);
      case 'customers':
        CustomerDetailRoute(id: id).goScoped(context);
      case 'employees':
        EmployeeDetailRoute(id: id).goScoped(context);
      default:
        break;
    }
  }

  /// Short list/detail summary. Prefers server [ActivityLog.description].
  static String buildShortSummary(ActivityLog log) {
    final description = log.description?.trim();
    if (description != null && description.isNotEmpty) {
      return description;
    }

    final action = log.action.displayName;
    final collection = log.collectionDisplayName.toLowerCase();
    final lines = buildChangeLines(log);
    if (lines.isNotEmpty) {
      return '$action $collection — ${lines.first}';
    }
    return '$action $collection';
  }

  /// Full field-by-field change lines for the detail page.
  static List<String> buildChangeLines(ActivityLog log) {
    final changes = log.changes;
    if (changes == null || changes.isEmpty) return const [];

    final lines = <String>[];
    for (final entry in changes.entries) {
      final field = entry.key;
      if (_hiddenFields.contains(field)) continue;
      final change = entry.value;
      if (change is! Map) continue;

      final label = _fieldLabels[field] ?? _camelToLabel(field);
      final oldVal = _formatFieldValue(field, change['old']);
      final newVal = _formatFieldValue(field, change['new']);
      lines.add('$label: $oldVal → $newVal');
    }
    return lines;
  }

  static String _formatFieldValue(String field, dynamic value) {
    if (value == null || value == '') return '(empty)';
    if (field == 'orderStatus') {
      return _orderStatusLabels[value] ?? '$value';
    }
    if (field == 'status') {
      return _saleStatusLabels[value] ?? '$value';
    }
    if (field == 'isPaid') return value == true ? 'Paid' : 'Unpaid';
    if (field == 'totalAmount' ||
        field == 'unitPrice' ||
        field == 'subtotal' ||
        field == 'price' ||
        field == 'rate') {
      final n = num.tryParse('$value');
      if (n != null) return '₱${n.toStringAsFixed(2)}';
    }
    return '$value';
  }

  static String _camelToLabel(String s) {
    final spaced = s.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (m) => ' ${m.group(1)!.toLowerCase()}',
    );
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
