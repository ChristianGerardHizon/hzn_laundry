import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/customer_history.dart';

/// Cross-platform print using PDF. Web override calls window.print() instead.
Future<void> printPage() async {
  // Fallback when called without detail (e.g. legacy callers): empty doc.
  await Printing.layoutPdf(onLayout: (format) async => Uint8List(0));
}

/// Print a sale detail as a formatted PDF receipt.
Future<void> printOrderDetail(CustomerHistorySaleDetail detail) async {
  final doc = pw.Document();
  final sale = detail.sale;

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              sale.receiptNumber.isEmpty
                  ? 'Order ${sale.id}'
                  : '#${sale.receiptNumber}',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Customer: ${detail.customer.name}'),
            if (detail.customer.phone != null &&
                detail.customer.phone!.isNotEmpty)
              pw.Text('Phone: ${detail.customer.phone!}'),
            pw.SizedBox(height: 4),
            pw.Text('Order Status: ${sale.orderStatus.displayName}'),
            pw.Text('Payment Status: ${sale.paymentStatus.displayName}'),
            pw.Divider(),
            if (detail.services.isNotEmpty) ...[
              pw.Text(
                'Services',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              ...detail.services.map(
                (s) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '${s.serviceName} (${s.quantity} x ${s.unitPrice.toStringAsFixed(2)})',
                      ),
                    ),
                    pw.Text('P${s.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
            ],
            if (detail.items.isNotEmpty) ...[
              pw.Text(
                'Items',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              ...detail.items.map(
                (it) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '${it.productName} (${it.quantity} x ${it.unitPrice.toStringAsFixed(2)})',
                      ),
                    ),
                    pw.Text('P${it.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
            ],
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'P${sale.totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (sale.notes != null && sale.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(
                'Notes',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(sale.notes!),
            ],
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => doc.save());
}
