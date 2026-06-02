import 'dart:js_interop';

import '../../domain/customer_history.dart';

@JS('window.print')
external void _windowPrint();

/// Opens the browser's print dialog.
Future<void> printPage() async {
  _windowPrint();
}

/// On web, just trigger the browser print dialog — the page itself is the receipt.
Future<void> printOrderDetail(CustomerHistorySaleDetail detail) async {
  _windowPrint();
}
