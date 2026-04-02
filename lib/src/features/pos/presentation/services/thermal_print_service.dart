import 'dart:io';
import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/permission_service.dart';
import '../../../settings/domain/printer_config.dart';
import '../../../settings/domain/printer_paper_width.dart';
import '../../domain/sale.dart';
import '../../domain/sale_item.dart';

part 'thermal_print_service.g.dart';

/// Result of a print operation.
sealed class PrintResult {
  const PrintResult();
}

/// Print operation succeeded.
class PrintSuccess extends PrintResult {
  const PrintSuccess();
}

/// Print operation failed.
class PrintFailure extends PrintResult {
  const PrintFailure(this.message);
  final String message;
}

/// Which copy of the order receipt to print.
enum OrderReceiptCopy {
  /// Full receipt for the customer with business info and totals.
  customer,

  /// Compact tag for the store — large customer name for machine identification.
  store,
}

/// Service for thermal printing operations.
@riverpod
class ThermalPrintService extends _$ThermalPrintService {
  /// Cached network socket to avoid repeated connect/disconnect events.
  Socket? _socket;
  String? _socketAddress;
  int? _socketPort;

  /// Whether the printer should auto-cut after printing.
  bool _autoCut = true;

  /// Whether auto-cut is currently enabled.
  bool get autoCut => _autoCut;

  /// Enables or disables auto-cut after printing.
  void setAutoCut(bool enabled) => _autoCut = enabled;

  @override
  FutureOr<void> build() {
    // Clean up the persistent socket when the provider is disposed.
    ref.onDispose(() {
      _socket?.destroy();
      _socket = null;
    });
  }

  /// Prints a sale receipt to the specified printer.
  ///
  /// The [printer] config must be passed from the caller to avoid
  /// async ref access issues.
  Future<PrintResult> printReceipt({
    required PrinterConfig printer,
    required Sale sale,
    required List<SaleItem> items,
    String? businessName,
    String? branchAddress,
    String? contactNumber,
    String? cashierName,
  }) async {
    if (!printer.hasAddress) {
      return const PrintFailure('Printer address not configured');
    }

    // Generate receipt bytes
    final bytes = await _generateReceiptBytes(
      sale: sale,
      items: items,
      paperWidth: printer.paperWidth,
      businessName: businessName ?? '',
      branchAddress: branchAddress ?? '',
      contactNumber: contactNumber ?? '',
      cashierName: cashierName,
    );

    // Print based on connection type
    return _printBytes(printer, bytes);
  }

  /// Prints an order receipt (without a full Sale object).
  ///
  /// [copyType] controls the label printed: customer copy (default) or store copy.
  /// The store copy has a large customer name header for machine identification.
  Future<PrintResult> printOrderReceipt({
    required PrinterConfig printer,
    required String customerName,
    required String serviceName,
    required double quantity,
    required String unitLabel,
    required double totalAmount,
    OrderReceiptCopy copyType = OrderReceiptCopy.customer,
    String? businessName,
    String? branchAddress,
    String? contactNumber,
    String? cashierName,
    String? specialInstructions,
    List<SaleItem> addOnItems = const [],
  }) async {
    if (!printer.hasAddress) {
      return const PrintFailure('Printer address not configured');
    }

    final bytes = await _generateOrderReceiptBytes(
      customerName: customerName,
      serviceName: serviceName,
      quantity: quantity,
      unitLabel: unitLabel,
      totalAmount: totalAmount,
      paperWidth: printer.paperWidth,
      businessName: businessName ?? '',
      branchAddress: branchAddress,
      contactNumber: contactNumber,
      cashierName: cashierName,
      specialInstructions: specialInstructions,
      copyType: copyType,
      addOnItems: addOnItems,
    );

    return _printBytes(printer, bytes);
  }

  /// Prints a test page to verify printer connection.
  Future<PrintResult> printTestPage(PrinterConfig config) async {
    if (!config.hasAddress) {
      return const PrintFailure('Printer address not configured');
    }

    final bytes = await _generateTestPageBytes(config.paperWidth);
    return _printBytes(config, bytes);
  }

  /// Discovers available Bluetooth printers.
  ///
  /// Requests Bluetooth permissions if not yet granted.
  /// Throws [PermissionDeniedException] if permissions are permanently denied.
  Future<List<BluetoothInfo>> discoverBluetoothPrinters() async {
    // Ensure Bluetooth permissions are granted before scanning
    await PermissionService.ensureBluetoothPermissions();

    try {
      final isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isEnabled) {
        return [];
      }

      final devices = await PrintBluetoothThermal.pairedBluetooths;
      return devices;
    } catch (e) {
      debugPrint('Error discovering Bluetooth printers: $e');
      return [];
    }
  }

  /// Checks if Bluetooth is available and enabled.
  ///
  /// Requests Bluetooth permissions if not yet granted.
  /// Throws [PermissionDeniedException] if permissions are permanently denied.
  Future<bool> isBluetoothEnabled() async {
    try {
      await PermissionService.ensureBluetoothPermissions();
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      if (e is PermissionDeniedException) rethrow;
      return false;
    }
  }

  /// Prints bytes to the configured printer.
  Future<PrintResult> _printBytes(PrinterConfig config, List<int> bytes) async {
    try {
      if (config.isBluetooth) {
        return _printViaBluetooth(config.address!, bytes);
      } else {
        return _printViaNetwork(config.address!, config.port, bytes);
      }
    } catch (e) {
      return PrintFailure('Print error: $e');
    }
  }

  /// Prints via Bluetooth connection.
  ///
  /// On macOS the `print_bluetooth_thermal` plugin has platform-channel
  /// quirks (duplicate responses, writeBytes type errors). We work around
  /// them by sending data in small chunks and catching channel errors
  /// gracefully.
  Future<PrintResult> _printViaBluetooth(
      String macAddress, List<int> bytes) async {
    try {
      // Ensure Bluetooth permissions are granted before printing
      try {
        await PermissionService.ensureBluetoothPermissions();
      } on PermissionDeniedException catch (e) {
        return PrintFailure(e.message);
      }

      // Check if Bluetooth is enabled
      final isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isEnabled) {
        return const PrintFailure('Bluetooth is not enabled');
      }

      // Connect to the printer
      final connected =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      if (!connected) {
        return const PrintFailure('Failed to connect to Bluetooth printer');
      }

      // Allow the Bluetooth connection to stabilise before sending data.
      await Future.delayed(const Duration(milliseconds: 300));

      // Verify the connection is actually ready.
      final isReady = await PrintBluetoothThermal.connectionStatus;
      if (!isReady) {
        return const PrintFailure(
            'Bluetooth connection lost before printing');
      }

      // Send data in chunks to avoid buffer overflow on macOS.
      // The plugin's writeBytes can fail with "Invalid arguments type"
      // when sending large payloads on macOS.
      // Use List<int>.from() to avoid Uint8List sublist view issues with
      // platform channel serialisation.
      const chunkSize = 200;
      bool lastResult = true;

      for (var offset = 0; offset < bytes.length; offset += chunkSize) {
        final end =
            (offset + chunkSize > bytes.length) ? bytes.length : offset + chunkSize;
        final chunk = List<int>.from(bytes.sublist(offset, end));

        try {
          lastResult = await PrintBluetoothThermal.writeBytes(chunk);
        } catch (e) {
          // On macOS the plugin may throw due to duplicate platform channel
          // responses. The data is often still sent successfully, so we
          // log and continue rather than failing.
          debugPrint('Bluetooth write chunk warning: $e');
        }

        // Small delay between chunks to let the printer process
        if (end < bytes.length) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      // Allow final chunk to flush before disconnecting.
      await Future.delayed(const Duration(milliseconds: 200));

      // Disconnect
      try {
        await PrintBluetoothThermal.disconnect;
      } catch (_) {
        // Ignore disconnect errors on macOS
      }

      if (lastResult) {
        return const PrintSuccess();
      } else {
        return const PrintFailure('Failed to send data to printer');
      }
    } catch (e) {
      return PrintFailure('Bluetooth print error: $e');
    }
  }

  /// Prints via network connection using a persistent TCP socket.
  ///
  /// Keeps the socket open between prints to avoid the WiFi print server
  /// module (HF-A11, USR-WiFi232, etc.) printing `+EVENT=SOCKA_ON` /
  /// `+EVENT=SOCKA_OFF` debug lines on every connect/disconnect cycle.
  ///
  /// If the cached socket is stale or the address changed, a new connection
  /// is established automatically.
  Future<PrintResult> _printViaNetwork(
      String ipAddress, int port, List<int> bytes) async {
    try {
      // Reuse existing socket if it matches the target address.
      if (_socket == null ||
          _socketAddress != ipAddress ||
          _socketPort != port) {
        _socket?.destroy();
        _socket = await Socket.connect(
          ipAddress,
          port,
          timeout: const Duration(seconds: 5),
        );
        _socketAddress = ipAddress;
        _socketPort = port;
      }

      try {
        _socket!.add(Uint8List.fromList(bytes));
        await _socket!.flush();
      } catch (_) {
        // Socket was stale — reconnect once and retry.
        _socket?.destroy();
        _socket = await Socket.connect(
          ipAddress,
          port,
          timeout: const Duration(seconds: 5),
        );
        _socketAddress = ipAddress;
        _socketPort = port;

        _socket!.add(Uint8List.fromList(bytes));
        await _socket!.flush();
      }

      // Wait for the printer to finish processing.
      await Future.delayed(const Duration(milliseconds: 500));

      return const PrintSuccess();
    } catch (e) {
      // Connection fully failed — clean up.
      _socket?.destroy();
      _socket = null;
      _socketAddress = null;
      _socketPort = null;
      return PrintFailure('Network print error: $e');
    }
  }

  /// Generates receipt bytes for the given sale.
  Future<List<int>> _generateReceiptBytes({
    required Sale sale,
    required List<SaleItem> items,
    required PrinterPaperWidth paperWidth,
    required String businessName,
    String? branchAddress,
    String? contactNumber,
    String? cashierName,
  }) async {
    // Use 'default' profile for better compatibility
    final profile = await CapabilityProfile.load(name: 'default');
    final generator = Generator(
      paperWidth == PrinterPaperWidth.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];

    // Header - Business Name
    bytes += generator.text(
      businessName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    // Address
    if (branchAddress != null && branchAddress.isNotEmpty) {
      bytes += generator.text(
        branchAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // Contact Number
    if (contactNumber != null && contactNumber.isNotEmpty) {
      bytes += generator.text(
        'Tel: $contactNumber',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.hr(ch: '=');

    // Receipt info
    bytes += generator.text('Receipt: ${sale.receiptNumber}');

    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final dateStr = sale.created != null
        ? dateFormat.format(sale.created!)
        : dateFormat.format(DateTime.now());
    bytes += generator.text('Date: $dateStr');

    // Cashier name
    if (cashierName != null && cashierName.isNotEmpty) {
      bytes += generator.text('Cashier: $cashierName');
    }

    bytes += generator.hr();

    // Column headers
    bytes += generator.row([
      PosColumn(
        text: 'ITEM',
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: 'QTY',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.center),
      ),
      PosColumn(
        text: 'AMOUNT',
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    // Items - Use 'P' instead of '₱' for thermal printer ASCII compatibility
    final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);
    for (final item in items) {
      // Truncate long product names
      String productName = item.productName;
      if (productName.length > 16) {
        productName = '${productName.substring(0, 14)}..';
      }

      bytes += generator.row([
        PosColumn(text: productName, width: 6),
        PosColumn(
          text: '${item.quantity.toInt()}',
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: currencyFormat.format(item.subtotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Total
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(text: '', width: 2),
      PosColumn(
        text: currencyFormat.format(sale.totalAmount),
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    // Payment info
    bytes += generator.text('Status: ${sale.isPaid ? 'PAID' : 'UNPAID'}');

    if (sale.customerName != null && sale.customerName!.isNotEmpty) {
      bytes += generator.text('Customer: ${sale.customerName}');
    }

    if (sale.notes != null && sale.notes!.isNotEmpty) {
      bytes += generator.hr();
      bytes += generator.text('Notes: ${sale.notes}');
    }

    bytes += generator.hr();

    // Footer
    bytes += generator.text(
      'Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.hr(ch: '=');

    // Feed and optionally cut
    bytes += generator.feed(_autoCut ? 2 : 4);
    if (_autoCut) bytes += generator.cut();

    return bytes;
  }

  /// Generates order receipt bytes (service-based order).
  ///
  /// [copyType] controls the layout:
  /// - [OrderReceiptCopy.customer]: Full receipt with business header, totals, thank-you.
  /// - [OrderReceiptCopy.store]: Compact machine tag with large customer name for
  ///   easy identification on the laundry machine.
  Future<List<int>> _generateOrderReceiptBytes({
    required String customerName,
    required String serviceName,
    required double quantity,
    required String unitLabel,
    required double totalAmount,
    required PrinterPaperWidth paperWidth,
    required String businessName,
    required OrderReceiptCopy copyType,
    String? branchAddress,
    String? contactNumber,
    String? cashierName,
    String? specialInstructions,
    List<SaleItem> addOnItems = const [],
  }) async {
    final profile = await CapabilityProfile.load(name: 'default');
    final generator = Generator(
      paperWidth == PrinterPaperWidth.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    final currencyFormat =
        NumberFormat.currency(symbol: 'P', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    List<int> bytes = [];

    if (copyType == OrderReceiptCopy.store) {
      // ── Store copy — compact machine tag ─────────────────────────────
      bytes += generator.hr(ch: '=');
      bytes += generator.text(
        'STORE COPY',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      bytes += generator.hr(ch: '=');

      // Large customer name for easy identification on the machine
      bytes += generator.text(
        customerName.toUpperCase(),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size4,
          width: PosTextSize.size4,
        ),
      );

      bytes += generator.emptyLines(1);

      // Service name — large and bold for visibility from a distance
      bytes += generator.text(
        serviceName.toUpperCase(),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      // Quantity — large for easy reading
      bytes += generator.text(
        '${quantity.toStringAsFixed(1)} $unitLabel',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      // ── Price breakdown ──────────────────────────────────────────────
      bytes += generator.hr();

      final storeAddOnsTotal =
          addOnItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
      final storeServiceSubtotal = totalAmount - storeAddOnsTotal;

      // Service price
      String storeServiceName = serviceName;
      if (storeServiceName.length > 16) {
        storeServiceName = '${storeServiceName.substring(0, 14)}..';
      }
      bytes += generator.row([
        PosColumn(text: storeServiceName, width: 8),
        PosColumn(
          text: currencyFormat.format(storeServiceSubtotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      // Add-on items
      if (addOnItems.isNotEmpty) {
        for (final item in addOnItems) {
          bytes += generator.row([
            PosColumn(
              text: '${item.productName} x${item.quantity.toInt()}',
              width: 8,
            ),
            PosColumn(
              text: currencyFormat.format(item.subtotal),
              width: 4,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]);
        }
      }

      bytes += generator.hr();

      // Total — large and bold for easy reading
      bytes += generator.text(
        'TOTAL',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      bytes += generator.text(
        currencyFormat.format(totalAmount),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      bytes += generator.hr();

      // Date & time
      bytes += generator.text(
        dateFormat.format(DateTime.now()),
        styles: const PosStyles(align: PosAlign.center),
      );

      // Special instructions (important for machine operators)
      bytes += generator.hr();
      bytes += generator.text(
        'NOTES:',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.text(
        (specialInstructions != null && specialInstructions.isNotEmpty)
            ? specialInstructions
            : 'No special instructions',
      );

      bytes += generator.hr(ch: '=');
      bytes += generator.feed(_autoCut ? 2 : 4);
      if (_autoCut) bytes += generator.cut();
    } else {
      // ── Customer copy — full receipt ──────────────────────────────────

      // Header - Business Name
      bytes += generator.text(
        businessName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      if (branchAddress != null && branchAddress.isNotEmpty) {
        bytes += generator.text(
          branchAddress,
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      if (contactNumber != null && contactNumber.isNotEmpty) {
        bytes += generator.text(
          'Tel: $contactNumber',
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      bytes += generator.hr(ch: '=');

      // Order info
      bytes += generator.text(
        'ORDER RECEIPT',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.text(
          'Date: ${dateFormat.format(DateTime.now())}');

      if (cashierName != null && cashierName.isNotEmpty) {
        bytes += generator.text('Cashier: $cashierName');
      }

      bytes += generator.hr();

      // Customer
      bytes += generator.text('Customer: $customerName');

      bytes += generator.hr();

      // Service details
      bytes += generator.row([
        PosColumn(
          text: 'SERVICE',
          width: 5,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: 'QTY',
          width: 3,
          styles: const PosStyles(bold: true, align: PosAlign.center),
        ),
        PosColumn(
          text: 'AMOUNT',
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);

      bytes += generator.hr();

      // Service subtotal excludes add-on prices
      final addOnsTotal =
          addOnItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
      final serviceSubtotal = totalAmount - addOnsTotal;

      String name = serviceName;
      if (name.length > 13) {
        name = '${name.substring(0, 11)}..';
      }

      bytes += generator.row([
        PosColumn(text: name, width: 5),
        PosColumn(
          text: '${quantity.toStringAsFixed(1)} $unitLabel',
          width: 3,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: currencyFormat.format(serviceSubtotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      // Add-on items
      if (addOnItems.isNotEmpty) {
        bytes += generator.hr();
        bytes += generator.row([
          PosColumn(
            text: 'ADD-ONS',
            width: 5,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: 'QTY',
            width: 3,
            styles: const PosStyles(bold: true, align: PosAlign.center),
          ),
          PosColumn(
            text: 'AMOUNT',
            width: 4,
            styles: const PosStyles(bold: true, align: PosAlign.right),
          ),
        ]);
        bytes += generator.hr();

        for (final item in addOnItems) {
          String addOnName = item.productName;
          if (addOnName.length > 13) {
            addOnName = '${addOnName.substring(0, 11)}..';
          }
          bytes += generator.row([
            PosColumn(text: addOnName, width: 5),
            PosColumn(
              text: 'x${item.quantity.toInt()}',
              width: 3,
              styles: const PosStyles(align: PosAlign.center),
            ),
            PosColumn(
              text: currencyFormat.format(item.subtotal),
              width: 4,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]);
        }
      }

      bytes += generator.hr();

      // Total — large and bold
      bytes += generator.text(
        'TOTAL',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      bytes += generator.text(
        currencyFormat.format(totalAmount),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      bytes += generator.hr();

      bytes += generator.text(
        (specialInstructions != null && specialInstructions.isNotEmpty)
            ? 'Notes: $specialInstructions'
            : 'Notes: No special instructions',
      );
      bytes += generator.hr();

      // Footer
      bytes += generator.text(
        'Thank you!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );

      bytes += generator.hr(ch: '=');
      bytes += generator.feed(_autoCut ? 2 : 4);
      if (_autoCut) bytes += generator.cut();
    }

    return bytes;
  }

  /// Generates test page bytes.
  Future<List<int>> _generateTestPageBytes(PrinterPaperWidth paperWidth) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      paperWidth == PrinterPaperWidth.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];

    bytes += generator.hr(ch: '=');
    bytes += generator.text(
      'PRINTER TEST',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.hr(ch: '=');

    bytes += generator.text('If you can read this,');
    bytes += generator.text('the printer is working correctly.');
    bytes += generator.emptyLines(1);

    bytes += generator.text(
      'Paper Width: ${paperWidth.displayName}',
      styles: const PosStyles(align: PosAlign.center),
    );

    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    bytes += generator.text(
      'Printed: ${dateFormat.format(DateTime.now())}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr(ch: '=');
    bytes += generator.feed(_autoCut ? 2 : 4);
    if (_autoCut) bytes += generator.cut();

    return bytes;
  }

}
