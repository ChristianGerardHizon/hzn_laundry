import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../pdf/pdf_task_runner.dart';
import '../../features/pos/domain/sale_item.dart';
import 'claim_sheet_disclaimer.dart';

/// Data required to render an order claim sheet PDF preview.
class OrderClaimSheetPdfData {
  const OrderClaimSheetPdfData({
    required this.customerName,
    required this.serviceName,
    required this.quantity,
    required this.unitLabel,
    required this.totalAmount,
    required this.createdDate,
    this.storeCopy = false,
    this.businessName,
    this.branchAddress,
    this.contactNumber,
    this.cashierName,
    this.specialInstructions,
    this.claimSheetNumber,
    this.addOnItems = const [],
  });

  final String customerName;
  final String serviceName;
  final double quantity;
  final String unitLabel;
  final double totalAmount;
  final DateTime createdDate;
  final bool storeCopy;
  final String? businessName;
  final String? branchAddress;
  final String? contactNumber;
  final String? cashierName;
  final String? specialInstructions;
  final String? claimSheetNumber;
  final List<SaleItem> addOnItems;
}

/// Builds order claim sheet PDF bytes matching the thermal layout.
Future<Uint8List> buildOrderClaimSheetPdfBytes(
  OrderClaimSheetPdfData data,
) async {
  final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
  // Use 'P' instead of '₱' for PDF compatibility (Helvetica doesn't support ₱)
  final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);

  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => data.storeCopy
          ? _buildStoreCopyContent(data, dateFormat, currencyFormat)
          : _buildCustomerCopyContent(data, dateFormat, currencyFormat),
    ),
  );
  return pdf.save();
}

/// Generates and opens a claim sheet PDF preview via the system print dialog.
Future<void> previewOrderClaimSheetPdf({
  required BuildContext context,
  required OrderClaimSheetPdfData data,
}) async {
  final result = await runPdfTask<OrderClaimSheetPdfData>(
    context: context,
    message: 'Generating claim sheet preview...',
    preload: () async => data,
    generate: buildOrderClaimSheetPdfBytes,
  );
  if (result is! PdfTaskSuccess) return;

  await Printing.layoutPdf(
    onLayout: (_) async => result.bytes,
  );
}

pw.Widget _buildCustomerCopyContent(
  OrderClaimSheetPdfData data,
  DateFormat dateFormat,
  NumberFormat currencyFormat,
) {
  final addOnsTotal =
      data.addOnItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
  final serviceSubtotal = data.totalAmount - addOnsTotal;
  final notes =
      (data.specialInstructions != null && data.specialInstructions!.isNotEmpty)
          ? data.specialInstructions!
          : 'No special instructions';

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      ..._businessHeader(data),
      pw.Center(
        child: pw.Text(
          claimSheetTitle,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 8),
      if (data.claimSheetNumber != null && data.claimSheetNumber!.isNotEmpty)
        pw.Text('$claimSheetNumberLabel ${data.claimSheetNumber}'),
      pw.Text('Date: ${dateFormat.format(data.createdDate)}'),
      if (data.cashierName != null && data.cashierName!.isNotEmpty)
        pw.Text('Cashier: ${data.cashierName}'),
      pw.SizedBox(height: 10),
      pw.Divider(),
      pw.SizedBox(height: 10),
      pw.Text('Customer: ${data.customerName}'),
      pw.SizedBox(height: 10),
      pw.Divider(),
      pw.SizedBox(height: 10),
      pw.Row(
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Text(
              'SERVICE',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              'QTY',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              'AMOUNT',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 6),
      pw.Divider(),
      pw.SizedBox(height: 6),
      pw.Row(
        children: [
          pw.Expanded(flex: 5, child: pw.Text(data.serviceName)),
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '${data.quantity.toStringAsFixed(1)} ${data.unitLabel}',
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              currencyFormat.format(serviceSubtotal),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
      if (data.addOnItems.isNotEmpty) ...[
        pw.SizedBox(height: 10),
        pw.Divider(),
        pw.SizedBox(height: 6),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 5,
              child: pw.Text(
                'ADD-ONS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(
              width: 80,
              child: pw.Text(
                'QTY',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(
              width: 80,
              child: pw.Text(
                'AMOUNT',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(),
        pw.SizedBox(height: 6),
        ...data.addOnItems.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              children: [
                pw.Expanded(flex: 5, child: pw.Text(item.productName)),
                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    'x${item.quantity.toInt()}',
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    currencyFormat.format(item.subtotal),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      pw.SizedBox(height: 10),
      pw.Divider(),
      pw.SizedBox(height: 10),
      pw.Center(
        child: pw.Text(
          'TOTAL',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Center(
        child: pw.Text(
          currencyFormat.format(data.totalAmount),
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Divider(),
      pw.SizedBox(height: 10),
      pw.Text('Notes: $notes'),
      pw.SizedBox(height: 16),
      pw.Center(
        child: pw.Text(
          'Thank you!',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 16),
      ..._disclaimerLines(),
    ],
  );
}

pw.Widget _buildStoreCopyContent(
  OrderClaimSheetPdfData data,
  DateFormat dateFormat,
  NumberFormat currencyFormat,
) {
  final addOnsTotal =
      data.addOnItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
  final serviceSubtotal = data.totalAmount - addOnsTotal;
  final notes =
      (data.specialInstructions != null && data.specialInstructions!.isNotEmpty)
          ? data.specialInstructions!
          : 'No special instructions';

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Divider(),
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          claimSheetStoreCopyTitle,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      if (data.claimSheetNumber != null &&
          data.claimSheetNumber!.isNotEmpty) ...[
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            '$claimSheetNumberLabel ${data.claimSheetNumber}',
            style: const pw.TextStyle(fontSize: 12),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
      pw.SizedBox(height: 8),
      pw.Divider(),
      pw.SizedBox(height: 16),
      pw.Center(
        child: pw.Text(
          data.customerName.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 16),
      pw.Center(
        child: pw.Text(
          data.serviceName.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          '${data.quantity.toStringAsFixed(1)} ${data.unitLabel}',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.Text(data.serviceName)),
          pw.Text(currencyFormat.format(serviceSubtotal)),
        ],
      ),
      ...data.addOnItems.map(
        (item) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text('${item.productName} x${item.quantity.toInt()}'),
              ),
              pw.Text(currencyFormat.format(item.subtotal)),
            ],
          ),
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Divider(),
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          'TOTAL',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Center(
        child: pw.Text(
          currencyFormat.format(data.totalAmount),
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(),
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          dateFormat.format(data.createdDate),
          style: const pw.TextStyle(fontSize: 12),
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(),
      pw.SizedBox(height: 8),
      pw.Text(
        'NOTES:',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 4),
      pw.Text(notes),
      pw.SizedBox(height: 16),
      ..._disclaimerLines(),
    ],
  );
}

List<pw.Widget> _businessHeader(OrderClaimSheetPdfData data) {
  if (data.businessName == null || data.businessName!.isEmpty) {
    return [];
  }

  return [
    pw.Center(
      child: pw.Text(
        data.businessName!,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
    if (data.branchAddress != null && data.branchAddress!.isNotEmpty)
      pw.Center(
        child: pw.Text(
          data.branchAddress!,
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
      ),
    if (data.contactNumber != null && data.contactNumber!.isNotEmpty)
      pw.Center(
        child: pw.Text(
          'Tel: ${data.contactNumber}',
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
      ),
    pw.SizedBox(height: 12),
  ];
}

List<pw.Widget> _disclaimerLines() {
  return [
    pw.Divider(),
    pw.SizedBox(height: 8),
    ...claimSheetDisclaimerLines.map(
      (line) => pw.Center(
        child: pw.Text(
          line,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    ),
  ];
}
