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
    this.customerPhone,
    this.specialInstructions,
    this.claimSheetNumber,
    this.readyForPickupAt,
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
  final String? customerPhone;
  final String? specialInstructions;
  final String? claimSheetNumber;
  final DateTime? readyForPickupAt;
  final List<SaleItem> addOnItems;
}

/// Builds a filesystem-safe PDF document name from claim sheet data.
///
/// Example: `Juan_Dela_Cruz_S-260919-0001_customer.pdf`
String claimSheetPdfFileName(OrderClaimSheetPdfData data) {
  final customer = _sanitizeFilePart(data.customerName);
  final order = _sanitizeFilePart(
    (data.claimSheetNumber != null && data.claimSheetNumber!.isNotEmpty)
        ? data.claimSheetNumber!
        : 'order',
  );
  final copy = data.storeCopy ? 'store' : 'customer';
  return '${customer}_${order}_$copy.pdf';
}

String _sanitizeFilePart(String value) {
  final cleaned = value
      .trim()
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '')
      .replaceAll(RegExp(r'\s+'), '_');
  return cleaned.isEmpty ? 'unknown' : cleaned;
}

/// Largest PDF font size that keeps [text] readable on one line (~A4 body).
double _largestFittingPdfCustomerNameSize(String text) {
  final len = text.isEmpty ? 1 : text.length;
  if (len <= 8) return 36;
  if (len <= 12) return 28;
  if (len <= 18) return 22;
  if (len <= 24) return 18;
  return 14;
}

/// Builds order claim sheet PDF bytes matching the thermal layout.
Future<Uint8List> buildOrderClaimSheetPdfBytes(
  OrderClaimSheetPdfData data,
) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      build: (context) => data.storeCopy
          ? _buildStoreCopyContent(data)
          : _buildCustomerCopyContent(data),
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
    name: claimSheetPdfFileName(data),
  );
}

pw.Widget _buildCustomerCopyContent(OrderClaimSheetPdfData data) {
  final amountFormat = NumberFormat('#,##0.00');
  final dateStr = DateFormat('M/d/yyyy').format(data.createdDate);
  final timeStr = DateFormat('h:mm a').format(data.createdDate);

  final addOnsTotal =
      data.addOnItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
  final serviceSubtotal = data.totalAmount - addOnsTotal;
  final unitPrice =
      data.quantity > 0 ? serviceSubtotal / data.quantity : serviceSubtotal;
  final qtyText = data.quantity == data.quantity.roundToDouble()
      ? '${data.quantity.toInt()}'
      : data.quantity.toStringAsFixed(1);
  final itemCount = data.quantity.round() +
      data.addOnItems.fold<int>(0, (sum, item) => sum + item.quantity.toInt());

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      ..._businessHeader(data, largeName: true),
      pw.Center(
        child: pw.Text(
          claimSheetTitle,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ),
      if (data.claimSheetNumber != null &&
          data.claimSheetNumber!.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            '$claimSheetNumberLabel ${data.claimSheetNumber}',
            style: const pw.TextStyle(fontSize: 11),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
      pw.SizedBox(height: 8),
      pw.Divider(),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 11)),
          pw.Text('Time: $timeStr', style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
      if (data.cashierName != null && data.cashierName!.isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Text(
            'Cashier: ${data.cashierName}',
            style: const pw.TextStyle(fontSize: 11),
          ),
        ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Customer: ${data.customerName}',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
      if (data.customerPhone != null && data.customerPhone!.isNotEmpty)
        pw.Text(
          'Phone: ${data.customerPhone}',
          style: const pw.TextStyle(fontSize: 11),
        ),
      pw.SizedBox(height: 10),
      pw.Divider(),
      pw.SizedBox(height: 6),
      _itemTableHeader(),
      pw.Divider(),
      _itemRow(
        description: data.serviceName,
        qty: qtyText,
        price: amountFormat.format(unitPrice),
        total: amountFormat.format(serviceSubtotal),
      ),
      ...data.addOnItems.map(
        (item) => _itemRow(
          description: item.productName,
          qty: '${item.quantity.toInt()}',
          price: amountFormat.format(item.unitPrice),
          total: amountFormat.format(item.subtotal),
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Divider(),
      pw.SizedBox(height: 6),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              '$itemCount Item(s)',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
          pw.Text(
            'TOTAL',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(width: 12),
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              amountFormat.format(data.totalAmount),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
      if (data.specialInstructions != null &&
          data.specialInstructions!.isNotEmpty) ...[
        pw.SizedBox(height: 10),
        pw.Text(
          'Notes: ${data.specialInstructions}',
          style: const pw.TextStyle(fontSize: 11),
        ),
      ],
      if (data.readyForPickupAt != null) ...[
        pw.SizedBox(height: 12),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'Ready For Pickup',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Center(
          child: pw.Text(
            DateFormat('M/d/yyyy h:mm a').format(data.readyForPickupAt!),
            style: const pw.TextStyle(fontSize: 11),
          ),
        ),
      ],
      pw.SizedBox(height: 12),
      pw.Divider(borderStyle: pw.BorderStyle.dashed),
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          'Please bring this receipt when picking up.',
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
      ),
      if (data.claimSheetNumber != null &&
          data.claimSheetNumber!.isNotEmpty) ...[
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.code128(),
            data: data.claimSheetNumber!,
            width: 180,
            height: 48,
            drawText: true,
          ),
        ),
      ],
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          'Items held free for 7 days.',
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.Center(
        child: pw.Text(
          'Holding fee applies afterwards.',
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          'Thank you for your business!',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 12),
      ..._disclaimerLines(),
    ],
  );
}

pw.Widget _buildStoreCopyContent(OrderClaimSheetPdfData data) {
  final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);
  final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
  final addOnsTotal =
      data.addOnItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
  final serviceSubtotal = data.totalAmount - addOnsTotal;
  final notes =
      (data.specialInstructions != null && data.specialInstructions!.isNotEmpty)
          ? data.specialInstructions!
          : 'No special instructions';
  final upperName = data.customerName.toUpperCase();
  final nameSize = _largestFittingPdfCustomerNameSize(upperName);
  final qtyText = data.quantity == data.quantity.roundToDouble()
      ? '${data.quantity.toInt()}'
      : data.quantity.toStringAsFixed(1);

  // Compact machine tag — no barcode, no tear/cut zone, BIR disclaimer only.
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Divider(),
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          claimSheetStoreCopyTitle,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ),
      if (data.claimSheetNumber != null &&
          data.claimSheetNumber!.isNotEmpty) ...[
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(
            '$claimSheetNumberLabel ${data.claimSheetNumber}',
            style: const pw.TextStyle(fontSize: 11),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
      pw.SizedBox(height: 8),
      pw.Divider(),
      pw.SizedBox(height: 16),
      pw.Center(
        child: pw.Text(
          upperName,
          style: pw.TextStyle(
            fontSize: nameSize,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 14),
      pw.Center(
        child: pw.Text(
          data.serviceName.toUpperCase(),
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Center(
        child: pw.Text(
          '$qtyText ${data.unitLabel}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              data.serviceName,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
          pw.Text(
            currencyFormat.format(serviceSubtotal),
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
      ...data.addOnItems.map(
        (item) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  '${item.productName} x${item.quantity.toInt()}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
              pw.Text(
                currencyFormat.format(item.subtotal),
                style: const pw.TextStyle(fontSize: 11),
              ),
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
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Center(
        child: pw.Text(
          currencyFormat.format(data.totalAmount),
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(),
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          dateFormat.format(data.createdDate),
          style: const pw.TextStyle(fontSize: 11),
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(),
      pw.SizedBox(height: 8),
      pw.Text(
        'NOTES:',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      ),
      pw.SizedBox(height: 4),
      pw.Text(notes, style: const pw.TextStyle(fontSize: 11)),
      pw.SizedBox(height: 16),
      ..._disclaimerLines(),
    ],
  );
}

pw.Widget _itemTableHeader() {
  return pw.Row(
    children: [
      pw.Expanded(
        flex: 5,
        child: pw.Text(
          'Description',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),
      ),
      pw.SizedBox(
        width: 40,
        child: pw.Text(
          'QTY',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(
        width: 64,
        child: pw.Text(
          'Price',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          textAlign: pw.TextAlign.right,
        ),
      ),
      pw.SizedBox(
        width: 72,
        child: pw.Text(
          'Total',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          textAlign: pw.TextAlign.right,
        ),
      ),
    ],
  );
}

pw.Widget _itemRow({
  required String description,
  required String qty,
  required String price,
  required String total,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 4),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Text(description, style: const pw.TextStyle(fontSize: 11)),
        ),
        pw.SizedBox(
          width: 40,
          child: pw.Text(
            qty,
            style: const pw.TextStyle(fontSize: 11),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(
          width: 64,
          child: pw.Text(
            price,
            style: const pw.TextStyle(fontSize: 11),
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.SizedBox(
          width: 72,
          child: pw.Text(
            total,
            style: const pw.TextStyle(fontSize: 11),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

List<pw.Widget> _businessHeader(
  OrderClaimSheetPdfData data, {
  required bool largeName,
}) {
  if (data.businessName == null || data.businessName!.isEmpty) {
    return [];
  }

  return [
    pw.Center(
      child: pw.Text(
        data.businessName!,
        style: pw.TextStyle(
          fontSize: largeName ? 18 : 14,
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
          data.contactNumber!,
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
      ),
    pw.SizedBox(height: 8),
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
