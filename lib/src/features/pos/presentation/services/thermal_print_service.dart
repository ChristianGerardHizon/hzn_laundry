import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/printing/claim_sheet_disclaimer.dart';
import '../../../../core/utils/permission_service.dart';
import '../../../settings/domain/printer_config.dart';
import '../../../settings/domain/printer_paper_width.dart';
import '../../domain/sale.dart';
import '../../domain/sale_item.dart';

part 'thermal_print_service.g.dart';

/// Whether ESC/POS thermal printing (Bluetooth or network socket) works on
/// this platform. Browsers cannot open classic Bluetooth or raw TCP sockets.
bool get isThermalPrintingSupported => !kIsWeb;

/// User-facing message when thermal printing is requested on an unsupported
/// platform (currently web).
const String kThermalPrintingUnsupportedMessage =
    'Thermal printing is not supported in the browser. '
    'Use the desktop or mobile app.';

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
  /// Full customer claim sheet (optionally followed by service stubs).
  customer,

  /// Two compact service stubs only (no customer copy).
  store,
}

/// Service for thermal printing operations.
@riverpod
class ThermalPrintService extends _$ThermalPrintService {
  /// Cached network socket to avoid repeated connect/disconnect events.
  Socket? _socket;
  String? _socketAddress;
  int? _socketPort;

  /// Tracks the currently-running Bluetooth/network print operation.
  ///
  /// `Future.timeout()` in `_printBytes` does not cancel the underlying
  /// operation — it only stops awaiting it. A timed-out attempt keeps
  /// running in the background against shared connection state (the
  /// cached [_socket], the Bluetooth connection). If a retry were allowed
  /// to start immediately, both would race on that state. This future
  /// resolves only when the real operation finishes, so the next print
  /// call can wait for it first instead of racing.
  Future<void>? _inFlightPrint;

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

  /// Reports a printer error/warning to Sentry with printer context attached
  /// (stage, platform, connection type) so failures like "printer not
  /// found" can be diagnosed remotely instead of only appearing as a toast.
  ///
  /// Pass either [error] (an actual exception) or [message] (a known failure
  /// condition with no exception, e.g. "failed to connect").
  void _reportPrinterIssue(
    String stage, {
    Object? error,
    StackTrace? stackTrace,
    String? message,
    SentryLevel level = SentryLevel.error,
    PrinterConfig? printer,
  }) {
    void applyScope(Scope scope) {
      scope.level = level;
      scope.setTag('printer.stage', stage);
      scope.setTag('printer.platform', Platform.operatingSystem);
      if (printer != null) {
        scope.setTag('printer.connectionType', printer.connectionType.name);
        scope.setContexts('printer', {
          'id': printer.id,
          'name': printer.name,
          'connectionType': printer.connectionType.name,
          'paperWidth': printer.paperWidth.name,
          'port': printer.port,
          'hasAddress': printer.hasAddress,
        });
      }
    }

    if (error != null) {
      Sentry.captureException(error,
          stackTrace: stackTrace, withScope: applyScope);
    } else if (message != null) {
      Sentry.captureMessage(message, level: level, withScope: applyScope);
    }
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

  /// Prints an order claim sheet (without a full Sale object).
  ///
  /// [copyType] selects customer sheet vs stubs-only.
  /// When [includeStubs] is true with a customer copy, two service stubs are
  /// appended in the same job with ESC/POS cuts between sections.
  Future<PrintResult> printOrderReceipt({
    required PrinterConfig printer,
    required String customerName,
    required String serviceName,
    required double quantity,
    required String unitLabel,
    required double totalAmount,
    OrderReceiptCopy copyType = OrderReceiptCopy.customer,
    bool includeStubs = false,
    String? businessName,
    String? branchAddress,
    String? contactNumber,
    String? cashierName,
    String? customerPhone,
    String? specialInstructions,
    String? claimSheetNumber,
    DateTime? orderDate,
    DateTime? readyForPickupAt,
    List<SaleItem> addOnItems = const [],
  }) async {
    if (!printer.hasAddress) {
      return const PrintFailure('Printer address not configured');
    }

    final bytes = await _generateOrderReceiptBytes(
      customerName: customerName,
      serviceName: serviceName,
      quantity: quantity,
      totalAmount: totalAmount,
      paperWidth: printer.paperWidth,
      businessName: businessName ?? '',
      branchAddress: branchAddress,
      contactNumber: contactNumber,
      cashierName: cashierName,
      customerPhone: customerPhone,
      specialInstructions: specialInstructions,
      copyType: copyType,
      includeStubs: includeStubs,
      claimSheetNumber: claimSheetNumber,
      orderDate: orderDate,
      readyForPickupAt: readyForPickupAt,
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
  /// Throws [UnsupportedError] on web where Bluetooth is unavailable.
  Future<List<BluetoothInfo>> discoverBluetoothPrinters() async {
    if (!isThermalPrintingSupported) {
      throw UnsupportedError(kThermalPrintingUnsupportedMessage);
    }

    // Ensure Bluetooth permissions are granted before scanning
    await PermissionService.ensureBluetoothPermissions();

    try {
      final isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isEnabled) {
        return [];
      }

      final devices = await PrintBluetoothThermal.pairedBluetooths;
      return devices;
    } catch (e, stackTrace) {
      debugPrint('Error discovering Bluetooth printers: $e');
      _reportPrinterIssue(
        'bluetooth_discovery_error',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Checks if Bluetooth is available and enabled.
  ///
  /// Requests Bluetooth permissions if not yet granted.
  /// Throws [PermissionDeniedException] if permissions are permanently denied.
  Future<bool> isBluetoothEnabled() async {
    if (!isThermalPrintingSupported) return false;

    try {
      await PermissionService.ensureBluetoothPermissions();
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e, stackTrace) {
      if (e is PermissionDeniedException) rethrow;
      _reportPrinterIssue(
        'bluetooth_enabled_check_error',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Hard ceiling on a single print attempt.
  ///
  /// Neither the `print_bluetooth_thermal` plugin's Windows connect path
  /// (`win_ble`) nor `dart:io` Socket writes have a guaranteed timeout on
  /// every internal await, so a bad connection can otherwise hang the
  /// "Print" button forever with no error ever surfacing. This wraps the
  /// whole attempt so it always resolves, and reports to Sentry when it
  /// doesn't finish in time.
  static const _printTimeout = Duration(seconds: 40);

  /// Prints bytes to the configured printer.
  Future<PrintResult> _printBytes(PrinterConfig config, List<int> bytes) async {
    debugPrint(
      '[ThermalPrint] _printBytes: printer="${config.name}" '
      'type=${config.connectionType.name} address=${config.address} '
      'port=${config.port} hasAddress=${config.hasAddress}',
    );
    if (!isThermalPrintingSupported) {
      debugPrint('[ThermalPrint] _printBytes: unsupported platform');
      return const PrintFailure(kThermalPrintingUnsupportedMessage);
    }

    // If a prior attempt timed out but is still running in the background,
    // wait for it to actually finish before touching shared connection
    // state (the cached socket, the Bluetooth connection) again.
    if (_inFlightPrint != null) {
      debugPrint(
        '[ThermalPrint] _printBytes: waiting for prior in-flight print '
        'to finish before starting a new one',
      );
    }
    while (_inFlightPrint != null) {
      await _inFlightPrint;
    }

    final printFuture = config.isBluetooth
        ? _printViaBluetooth(config, bytes)
        : _printViaNetwork(config, bytes);

    // Track real completion of the operation separately from the
    // timeout-wrapped await below, so `_inFlightPrint` only clears once
    // the underlying Bluetooth/network work is actually done.
    final release = printFuture.then((_) {}, onError: (_, __) {});
    _inFlightPrint = release;
    unawaited(release.whenComplete(() {
      if (identical(_inFlightPrint, release)) {
        _inFlightPrint = null;
      }
    }));

    try {
      // No onTimeout handler — let this throw TimeoutException on expiry
      // so it flows through the catch below with a real stack trace
      // instead of silently resolving to a failure value.
      return await printFuture.timeout(_printTimeout);
    } on TimeoutException catch (e, stackTrace) {
      final isWindowsBluetoothHang = config.isBluetooth && Platform.isWindows;
      debugPrint(
        '[ThermalPrint] _printBytes: timed out after '
        '${_printTimeout.inSeconds}s connecting/printing to '
        '"${config.name}" (${config.connectionType.name}, '
        '${config.address}:${config.port})',
      );
      _reportPrinterIssue(
        'print_timeout',
        error: e,
        stackTrace: stackTrace,
        printer: config,
      );
      return PrintFailure(
        isWindowsBluetoothHang
            ? 'Print timed out. This printer may use classic Bluetooth, '
                'which Windows cannot connect to — try a network '
                '(WiFi/LAN) printer instead.'
            : 'Print operation timed out. Check the printer connection '
                'and try again.',
      );
    } catch (e, stackTrace) {
      _reportPrinterIssue(
        'print_bytes',
        error: e,
        stackTrace: stackTrace,
        printer: config,
      );
      return PrintFailure('Print error: $e');
    }
  }

  /// Finds a chunk boundary at or before [desiredEnd] that falls right
  /// after a line break (`\n`), so a Bluetooth write never splits a
  /// printer command/character run in half. Falls back to [desiredEnd]
  /// itself if no line break exists between [start] and [desiredEnd]
  /// (e.g. a single run, such as image data, longer than one chunk).
  int _safeChunkEnd(List<int> bytes, int start, int desiredEnd) {
    if (desiredEnd >= bytes.length) return bytes.length;
    for (var i = desiredEnd; i > start; i--) {
      if (bytes[i - 1] == 0x0A) return i;
    }
    return desiredEnd;
  }

  /// Prints via Bluetooth connection.
  ///
  /// On macOS the `print_bluetooth_thermal` plugin has platform-channel
  /// quirks (duplicate responses, writeBytes type errors). We work around
  /// them by sending data in small chunks and catching channel errors
  /// gracefully.
  ///
  /// On Windows the plugin scans for Bluetooth Low Energy (BLE) devices
  /// only (via `win_ble`), since Windows classic-Bluetooth (SPP/RFCOMM)
  /// APIs aren't exposed the same way. Most ESC/POS thermal printers use
  /// classic Bluetooth, not BLE, so they will not be discovered or will
  /// fail to connect here — that's the most common cause of "printer not
  /// found" on Windows. Network (WiFi/LAN) printing is the reliable path
  /// on Windows.
  Future<PrintResult> _printViaBluetooth(
      PrinterConfig config, List<int> bytes) async {
    // Android BluetoothAdapter.checkBluetoothAddress requires uppercase
    // hex (AA:BB:CC:DD:EE:FF). Saved configs may store lowercase.
    final macAddress = config.address!.toUpperCase();
    debugPrint(
      '[ThermalPrint] Bluetooth: starting print to $macAddress '
      '(${bytes.length} bytes, platform=${Platform.operatingSystem})',
    );
    try {
      // Ensure Bluetooth permissions are granted before printing
      try {
        await PermissionService.ensureBluetoothPermissions();
        debugPrint('[ThermalPrint] Bluetooth: permissions OK');
      } on PermissionDeniedException catch (e) {
        debugPrint(
            '[ThermalPrint] Bluetooth: permission denied — ${e.message}');
        _reportPrinterIssue(
          'bluetooth_permission_denied',
          message: e.message,
          level: SentryLevel.warning,
          printer: config,
        );
        return PrintFailure(e.message);
      }

      // Check if Bluetooth is enabled
      final isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      debugPrint('[ThermalPrint] Bluetooth: adapter enabled=$isEnabled');
      if (!isEnabled) {
        _reportPrinterIssue(
          'bluetooth_disabled',
          message: 'Bluetooth is not enabled',
          level: SentryLevel.warning,
          printer: config,
        );
        return const PrintFailure('Bluetooth is not enabled');
      }

      // Connect to the printer
      debugPrint('[ThermalPrint] Bluetooth: connecting to $macAddress...');
      final connectStart = DateTime.now();
      final connected =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      final connectMs = DateTime.now().difference(connectStart).inMilliseconds;
      debugPrint(
        '[ThermalPrint] Bluetooth: connect() returned $connected '
        'after ${connectMs}ms',
      );
      if (!connected) {
        _reportPrinterIssue(
          'bluetooth_connect_failed',
          message: Platform.isWindows
              ? 'Failed to connect to Bluetooth printer on Windows '
                  '(likely a classic Bluetooth/SPP printer, which the '
                  'Windows BLE-only scanner cannot see)'
              : 'Failed to connect to Bluetooth printer',
          printer: config,
        );
        return const PrintFailure('Failed to connect to Bluetooth printer');
      }

      // Allow the Bluetooth connection to stabilise before sending data.
      await Future.delayed(const Duration(milliseconds: 300));

      // Verify the connection is actually ready.
      final isReady = await PrintBluetoothThermal.connectionStatus;
      debugPrint('[ThermalPrint] Bluetooth: connectionStatus ready=$isReady');
      if (!isReady) {
        _reportPrinterIssue(
          'bluetooth_connection_lost',
          message: 'Bluetooth connection lost before printing',
          printer: config,
        );
        return const PrintFailure('Bluetooth connection lost before printing');
      }

      // Send data in chunks to avoid buffer overflow on macOS.
      // The plugin's writeBytes can fail with "Invalid arguments type"
      // when sending large payloads on macOS.
      // Use List<int>.from() to avoid Uint8List sublist view issues with
      // platform channel serialisation.
      const chunkSize = 200;
      const maxChunkAttempts = 3;

      for (var offset = 0; offset < bytes.length;) {
        final desiredEnd = (offset + chunkSize > bytes.length)
            ? bytes.length
            : offset + chunkSize;
        // Cut at the last line break in the window instead of an arbitrary
        // byte offset. Each printed line (divider, text, row) is a self-
        // contained run of position/style commands followed by characters
        // and a trailing '\n'. Slicing a fixed byte count can land inside
        // that run — e.g. mid-divider — so half the command reaches the
        // printer in one write and the rest arrives in the next as if it
        // were new data, leaving a corrupted gap in that line. Backing up
        // to the previous '\n' keeps every line's bytes in one write.
        final end = _safeChunkEnd(bytes, offset, desiredEnd);
        final chunk = List<int>.from(bytes.sublist(offset, end));

        // Unlike a dropped text line, a lost chunk inside a continuous
        // binary run (e.g. an image band) desyncs every byte after it —
        // the printer keeps decoding, just shifted, which shows up as
        // garbled/sheared output. So a definite "false" from writeBytes
        // is retried a few times, and the whole print is aborted if it
        // still fails, instead of marching on with missing bytes.
        var chunkSucceeded = false;
        for (var attempt = 1; attempt <= maxChunkAttempts; attempt++) {
          try {
            chunkSucceeded = await PrintBluetoothThermal.writeBytes(chunk);
          } catch (e) {
            // On macOS the plugin may throw due to duplicate platform
            // channel responses. The data is often still sent
            // successfully, so we treat this as a likely success rather
            // than retrying/aborting.
            debugPrint(
              '[ThermalPrint] Bluetooth: write chunk warning at offset '
              '$offset: $e',
            );
            chunkSucceeded = true;
          }

          if (chunkSucceeded) break;

          debugPrint(
            '[ThermalPrint] Bluetooth: writeBytes returned false at '
            'offset $offset (attempt $attempt/$maxChunkAttempts)'
            '${attempt < maxChunkAttempts ? ' — retrying' : ''}',
          );
          if (attempt < maxChunkAttempts) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }

        if (!chunkSucceeded) {
          debugPrint(
            '[ThermalPrint] Bluetooth: giving up after $maxChunkAttempts '
            'failed attempts at offset $offset/${bytes.length} — aborting '
            'print instead of sending a corrupted/garbled receipt',
          );
          _reportPrinterIssue(
            'bluetooth_chunk_write_failed',
            message: 'Bluetooth chunk write failed after '
                '$maxChunkAttempts attempts at byte offset '
                '$offset/${bytes.length}',
            printer: config,
          );
          try {
            await PrintBluetoothThermal.disconnect;
          } catch (_) {
            // Ignore disconnect errors while already aborting.
          }
          return const PrintFailure(
            'Lost connection to printer while sending data. '
            'Please try printing again.',
          );
        }

        // Small delay between chunks to let the printer process
        if (end < bytes.length) {
          await Future.delayed(const Duration(milliseconds: 50));
        }

        offset = end;
      }

      // Allow final chunk to flush before disconnecting.
      await Future.delayed(const Duration(milliseconds: 200));

      // Disconnect
      try {
        await PrintBluetoothThermal.disconnect;
        debugPrint('[ThermalPrint] Bluetooth: disconnected');
      } catch (e) {
        // Ignore disconnect errors on macOS
        debugPrint('[ThermalPrint] Bluetooth: disconnect warning: $e');
      }

      debugPrint('[ThermalPrint] Bluetooth: print succeeded');
      return const PrintSuccess();
    } catch (e, stackTrace) {
      debugPrint('[ThermalPrint] Bluetooth: unhandled error: $e\n$stackTrace');
      _reportPrinterIssue(
        'bluetooth_print_error',
        error: e,
        stackTrace: stackTrace,
        printer: config,
      );
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
      PrinterConfig config, List<int> bytes) async {
    final ipAddress = config.address!;
    final port = config.port;
    debugPrint(
      '[ThermalPrint] Network: starting print to $ipAddress:$port '
      '(${bytes.length} bytes)',
    );
    try {
      // Reuse existing socket if it matches the target address.
      if (_socket == null ||
          _socketAddress != ipAddress ||
          _socketPort != port) {
        debugPrint(
          '[ThermalPrint] Network: no reusable socket '
          '(cached=${_socketAddress ?? 'none'}:${_socketPort ?? '-'}) '
          '— connecting to $ipAddress:$port...',
        );
        _socket?.destroy();
        final connectStart = DateTime.now();
        _socket = await Socket.connect(
          ipAddress,
          port,
          timeout: const Duration(seconds: 5),
        );
        debugPrint(
          '[ThermalPrint] Network: connected in '
          '${DateTime.now().difference(connectStart).inMilliseconds}ms',
        );
        _socketAddress = ipAddress;
        _socketPort = port;
      } else {
        debugPrint('[ThermalPrint] Network: reusing cached socket');
      }

      try {
        _socket!.add(Uint8List.fromList(bytes));
        await _socket!.flush();
        debugPrint('[ThermalPrint] Network: wrote and flushed bytes');
      } catch (e) {
        // Socket was stale — reconnect once and retry.
        debugPrint(
          '[ThermalPrint] Network: write failed on cached socket ($e) '
          '— reconnecting and retrying...',
        );
        _socket?.destroy();
        final reconnectStart = DateTime.now();
        _socket = await Socket.connect(
          ipAddress,
          port,
          timeout: const Duration(seconds: 5),
        );
        debugPrint(
          '[ThermalPrint] Network: reconnected in '
          '${DateTime.now().difference(reconnectStart).inMilliseconds}ms',
        );
        _socketAddress = ipAddress;
        _socketPort = port;

        _socket!.add(Uint8List.fromList(bytes));
        await _socket!.flush();
        debugPrint('[ThermalPrint] Network: wrote and flushed bytes on retry');
      }

      // Wait for the printer to finish processing.
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('[ThermalPrint] Network: print succeeded');
      return const PrintSuccess();
    } catch (e, stackTrace) {
      // Connection fully failed — clean up.
      debugPrint(
        '[ThermalPrint] Network: connection failed to $ipAddress:$port — $e',
      );
      _socket?.destroy();
      _socket = null;
      _socketAddress = null;
      _socketPort = null;
      _reportPrinterIssue(
        'network_print_error',
        error: e,
        stackTrace: stackTrace,
        printer: config,
      );
      return PrintFailure('Network print error: $e');
    }
  }

  /// Draws a full-width divider line.
  ///
  /// Forces an unconditional style reset (`ESC @`) before the divider
  /// instead of relying on [Generator]'s diff-based style tracking.
  /// [Generator.hr] only emits a reset when its in-memory style disagrees
  /// with the target style — if a prior escape sequence was split or
  /// dropped in transit (e.g. a Bluetooth write chunked mid-command), the
  /// in-memory state can claim "already normal size" while the physical
  /// printer is still stuck in the double-height/width mode left over from
  /// large text. That leaves the divider printing at that oversized scale,
  /// wrapping one line of dashes into two or three.
  List<int> _appendDivider(
    Generator generator,
    List<int> bytes, {
    String ch = '-',
  }) {
    bytes += generator.reset();
    bytes += generator.hr(ch: ch);
    return bytes;
  }

  List<int> _appendBusinessHeader(
    Generator generator,
    List<int> bytes, {
    required String businessName,
    String? branchAddress,
    String? contactNumber,
    String dividerChar = '=',
    bool largeName = true,
  }) {
    bytes += generator.text(
      businessName,
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: largeName ? PosTextSize.size2 : PosTextSize.size1,
        width: largeName ? PosTextSize.size2 : PosTextSize.size1,
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
        contactNumber,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes = _appendDivider(generator, bytes, ch: dividerChar);
    return bytes;
  }

  List<int> _appendClaimSheetTitle(
    Generator generator,
    List<int> bytes, {
    bool storeCopy = false,
  }) {
    bytes += generator.text(
      storeCopy ? claimSheetStoreCopyTitle : claimSheetTitle,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );
    return bytes;
  }

  List<int> _appendClaimSheetDisclaimer(Generator generator, List<int> bytes) {
    for (final line in claimSheetDisclaimerLines) {
      bytes += generator.text(
        line,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
    }
    return bytes;
  }

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    if (maxLen <= 2) return text.substring(0, maxLen);
    return '${text.substring(0, maxLen - 2)}..';
  }

  List<int> _appendFeedAndCut(Generator generator, List<int> bytes) {
    bytes += generator.feed(_autoCut ? 2 : 4);
    if (_autoCut) bytes += generator.cut();
    return bytes;
  }

  List<int> _appendTicketBarcode(
    Generator generator,
    List<int> bytes,
    String? ticketNumber,
  ) {
    if (ticketNumber == null || ticketNumber.isEmpty) return bytes;
    try {
      // CODE128 type B: printable ASCII including hyphens in ticket numbers.
      final barcode = Barcode.code128('{B$ticketNumber'.split(''));
      bytes += generator.barcode(
        barcode,
        height: 60,
        width: 2,
        textPos: BarcodeText.below,
      );
    } catch (_) {
      // Skip barcode if the printer profile rejects the payload.
    }
    return bytes;
  }

  /// Compact service stub (printed twice with a cut after each).
  List<int> _appendServiceStub(
    Generator generator,
    List<int> bytes, {
    required String businessName,
    required String customerName,
    required String serviceName,
    String? branchAddress,
    String? customerPhone,
  }) {
    bytes += generator.text(
      businessName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );
    if (branchAddress != null && branchAddress.isNotEmpty) {
      bytes += generator.text(
        branchAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.emptyLines(1);
    bytes += generator.text('Customer: $customerName');
    if (customerPhone != null && customerPhone.isNotEmpty) {
      bytes += generator.text('Phone: $customerPhone');
    }

    bytes += generator.emptyLines(1);
    bytes += generator.text(
      'Type of Service: $serviceName',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    return _appendFeedAndCut(generator, bytes);
  }

  /// Customer claim sheet body matching the Soybean-style layout.
  List<int> _appendCustomerClaimSheet(
    Generator generator,
    List<int> bytes, {
    required String customerName,
    required String serviceName,
    required double quantity,
    required double totalAmount,
    required String businessName,
    String? branchAddress,
    String? contactNumber,
    String? cashierName,
    String? customerPhone,
    String? specialInstructions,
    String? claimSheetNumber,
    DateTime? orderDate,
    DateTime? readyForPickupAt,
    List<SaleItem> addOnItems = const [],
  }) {
    final amountFormat = NumberFormat('#,##0.00');
    final now = orderDate ?? DateTime.now();
    final dateStr = DateFormat('M/d/yyyy').format(now);
    final timeStr = DateFormat('h:mm a').format(now);

    bytes = _appendBusinessHeader(
      generator,
      bytes,
      businessName: businessName,
      branchAddress: branchAddress,
      contactNumber: contactNumber,
      dividerChar: '-',
      largeName: true,
    );

    // Date left / Time right
    bytes += generator.row([
      PosColumn(text: 'Date: $dateStr', width: 6),
      PosColumn(
        text: 'Time: $timeStr',
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (cashierName != null && cashierName.isNotEmpty) {
      bytes += generator.text('Cashier: $cashierName');
    }
    bytes += generator.text('Customer: $customerName');
    if (customerPhone != null && customerPhone.isNotEmpty) {
      bytes += generator.text('Phone: $customerPhone');
    }
    if (claimSheetNumber != null && claimSheetNumber.isNotEmpty) {
      bytes += generator.text('Ticket #: $claimSheetNumber');
    }

    bytes = _appendDivider(generator, bytes);

    // Description | QTY | Price | Total
    bytes += generator.row([
      PosColumn(
        text: 'Description',
        width: 5,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: 'QTY',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.center),
      ),
      PosColumn(
        text: 'Price',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
      PosColumn(
        text: 'Total',
        width: 3,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    bytes = _appendDivider(generator, bytes);

    final addOnsTotal =
        addOnItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
    final serviceSubtotal = totalAmount - addOnsTotal;
    final unitPrice = quantity > 0 ? serviceSubtotal / quantity : serviceSubtotal;

    bytes += generator.row([
      PosColumn(text: _truncate(serviceName, 14), width: 5),
      PosColumn(
        text: quantity == quantity.roundToDouble()
            ? '${quantity.toInt()}'
            : quantity.toStringAsFixed(1),
        width: 2,
        styles: const PosStyles(align: PosAlign.center),
      ),
      PosColumn(
        text: amountFormat.format(unitPrice),
        width: 2,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: amountFormat.format(serviceSubtotal),
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    for (final item in addOnItems) {
      bytes += generator.row([
        PosColumn(text: _truncate(item.productName, 14), width: 5),
        PosColumn(
          text: '${item.quantity.toInt()}',
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: amountFormat.format(item.unitPrice),
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: amountFormat.format(item.subtotal),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes = _appendDivider(generator, bytes, ch: '=');

    final itemCount = quantity.round() +
        addOnItems.fold<int>(0, (sum, item) => sum + item.quantity.toInt());

    bytes += generator.row([
      PosColumn(text: '$itemCount Item (s)', width: 5),
      PosColumn(text: '', width: 1),
      PosColumn(
        text: 'Total',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: amountFormat.format(totalAmount),
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (specialInstructions != null && specialInstructions.isNotEmpty) {
      bytes += generator.text('Notes: $specialInstructions');
    }

    bytes = _appendDivider(generator, bytes);
    bytes += generator.text(
      'Ready For Pickup:',
      styles: const PosStyles(align: PosAlign.center),
    );
    if (readyForPickupAt != null) {
      bytes += generator.text(
        DateFormat('M/d/yyyy h:mm a').format(readyForPickupAt),
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes = _appendDivider(generator, bytes);
    bytes += generator.text(
      'Please bring this receipt when picking up your items.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes = _appendTicketBarcode(generator, bytes, claimSheetNumber);
    bytes += generator.text(
      'Items will be held for free for 7 days.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Holding fee will apply afterwards.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Thank you for your business!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes = _appendDivider(generator, bytes);
    bytes = _appendClaimSheetDisclaimer(generator, bytes);

    return _appendFeedAndCut(generator, bytes);
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

    bytes = _appendBusinessHeader(
      generator,
      bytes,
      businessName: businessName,
      branchAddress: branchAddress,
      contactNumber: contactNumber,
    );

    bytes = _appendClaimSheetTitle(generator, bytes);

    // Claim sheet info
    bytes += generator.text(
      '$claimSheetNumberLabel ${sale.receiptNumber}',
    );

    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final dateStr = sale.postedDate != null
        ? dateFormat.format(sale.postedDate!)
        : dateFormat.format(DateTime.now());
    bytes += generator.text('Date: $dateStr');

    // Cashier name
    if (cashierName != null && cashierName.isNotEmpty) {
      bytes += generator.text('Cashier: $cashierName');
    }

    bytes = _appendDivider(generator, bytes);

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

    bytes = _appendDivider(generator, bytes);

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

    bytes = _appendDivider(generator, bytes);

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

    bytes = _appendDivider(generator, bytes);

    // Payment info
    bytes += generator.text('Status: ${sale.isPaid ? 'PAID' : 'UNPAID'}');

    if (sale.customerName != null && sale.customerName!.isNotEmpty) {
      bytes += generator.text('Customer: ${sale.customerName}');
    }

    if (sale.notes != null && sale.notes!.isNotEmpty) {
      bytes = _appendDivider(generator, bytes);
      bytes += generator.text('Notes: ${sale.notes}');
    }

    bytes = _appendDivider(generator, bytes);

    // Footer
    bytes += generator.text(
      'Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes = _appendDivider(generator, bytes);
    bytes = _appendClaimSheetDisclaimer(generator, bytes);
    bytes = _appendDivider(generator, bytes, ch: '=');

    return _appendFeedAndCut(generator, bytes);
  }

  /// Generates order claim sheet bytes.
  ///
  /// Customer copy: Soybean-style receipt with BIR disclaimer, then optional
  /// cuts + two service stubs when [includeStubs] is true.
  /// Store copy: two service stubs only.
  Future<List<int>> _generateOrderReceiptBytes({
    required String customerName,
    required String serviceName,
    required double quantity,
    required double totalAmount,
    required PrinterPaperWidth paperWidth,
    required String businessName,
    required OrderReceiptCopy copyType,
    bool includeStubs = false,
    String? branchAddress,
    String? contactNumber,
    String? cashierName,
    String? customerPhone,
    String? specialInstructions,
    String? claimSheetNumber,
    DateTime? orderDate,
    DateTime? readyForPickupAt,
    List<SaleItem> addOnItems = const [],
  }) async {
    final profile = await CapabilityProfile.load(name: 'default');
    final paperSize =
        paperWidth == PrinterPaperWidth.mm58 ? PaperSize.mm58 : PaperSize.mm80;
    final generator = Generator(paperSize, profile);

    List<int> bytes = [];

    final printCustomer = copyType == OrderReceiptCopy.customer;
    final printStubs =
        copyType == OrderReceiptCopy.store || includeStubs;

    if (printCustomer) {
      bytes = _appendCustomerClaimSheet(
        generator,
        bytes,
        customerName: customerName,
        serviceName: serviceName,
        quantity: quantity,
        totalAmount: totalAmount,
        businessName: businessName,
        branchAddress: branchAddress,
        contactNumber: contactNumber,
        cashierName: cashierName,
        customerPhone: customerPhone,
        specialInstructions: specialInstructions,
        claimSheetNumber: claimSheetNumber,
        orderDate: orderDate,
        readyForPickupAt: readyForPickupAt,
        addOnItems: addOnItems,
      );
    }

    if (printStubs) {
      for (var i = 0; i < 2; i++) {
        bytes = _appendServiceStub(
          generator,
          bytes,
          businessName: businessName,
          branchAddress: branchAddress,
          customerName: customerName,
          customerPhone: customerPhone,
          serviceName: serviceName,
        );
      }
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

    bytes = _appendDivider(generator, bytes, ch: '=');
    bytes += generator.text(
      'PRINTER TEST',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes = _appendDivider(generator, bytes, ch: '=');

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

    bytes = _appendDivider(generator, bytes, ch: '=');
    return _appendFeedAndCut(generator, bytes);
  }
}
