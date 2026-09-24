import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../domain/printer_config.dart';

part 'printer_config_repository.g.dart';

const _localPrintersKey = 'local_printers';
const selectedPrinterIdKey = 'selected_printer_id';
const legacyLocalDefaultPrinterKey = 'local_default_printer_id';

/// Repository interface for printer configuration operations.
abstract class PrinterConfigRepository {
  /// Fetches all printer configurations stored on this device.
  FutureEither<List<PrinterConfig>> fetchAll();

  /// Fetches a single printer configuration by ID.
  FutureEither<PrinterConfig> fetchOne(String id);

  /// Creates a new printer configuration.
  FutureEither<PrinterConfig> create(PrinterConfig config);

  /// Updates an existing printer configuration.
  FutureEither<PrinterConfig> update(PrinterConfig config);

  /// Deletes a printer configuration by ID.
  FutureEither<void> delete(String id);
}

/// Provides the PrinterConfigRepository instance.
@Riverpod(keepAlive: true)
PrinterConfigRepository printerConfigRepository(Ref ref) {
  return PrinterConfigRepositoryImpl(ref.watch(secureStorageProvider));
}

/// Implementation of [PrinterConfigRepository] using on-device storage.
class PrinterConfigRepositoryImpl implements PrinterConfigRepository {
  PrinterConfigRepositoryImpl(this._storage);

  final FlutterSecureStorage _storage;
  final Random _random = Random();

  @override
  FutureEither<List<PrinterConfig>> fetchAll() async {
    return TaskEither.tryCatch(_readPrinters, Failure.handle).run();
  }

  @override
  FutureEither<PrinterConfig> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Printer config ID cannot be empty',
            null,
            'invalid_printer_config_id',
          );
        }

        final printers = await _readPrinters();
        return printers.firstWhere(
          (p) => p.id == id,
          orElse: () => throw const DataFailure(
            'Printer not found',
            null,
            'printer_not_found',
          ),
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<PrinterConfig> create(PrinterConfig config) async {
    return TaskEither.tryCatch(
      () async {
        final now = DateTime.now();
        final created = config.copyWith(
          id: config.id.isNotEmpty ? config.id : _newId(),
          created: config.created ?? now,
          updated: now,
        );

        final printers = await _readPrinters();
        printers.insert(0, created);
        await _writePrinters(printers);
        return created;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<PrinterConfig> update(PrinterConfig config) async {
    return TaskEither.tryCatch(
      () async {
        if (config.id.isEmpty) {
          throw const DataFailure(
            'Printer config ID cannot be empty',
            null,
            'invalid_printer_config_id',
          );
        }

        final printers = await _readPrinters();
        final index = printers.indexWhere((p) => p.id == config.id);
        if (index < 0) {
          throw const DataFailure(
            'Printer not found',
            null,
            'printer_not_found',
          );
        }

        final updated = config.copyWith(updated: DateTime.now());
        printers[index] = updated;
        await _writePrinters(printers);
        return updated;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Printer config ID cannot be empty',
            null,
            'invalid_printer_config_id',
          );
        }

        final printers = await _readPrinters();
        printers.removeWhere((p) => p.id == id);
        await _writePrinters(printers);
      },
      Failure.handle,
    ).run();
  }

  Future<List<PrinterConfig>> _readPrinters() async {
    PrinterConfigMapper.ensureInitialized();
    final raw = await _storage.read(key: _localPrintersKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((e) => PrinterConfigMapper.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _writePrinters(List<PrinterConfig> printers) async {
    PrinterConfigMapper.ensureInitialized();
    final encoded = jsonEncode(
      printers.map((p) => jsonDecode(p.toJson())).toList(),
    );
    await _storage.write(key: _localPrintersKey, value: encoded);
  }

  String _newId() {
    final t = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final r = _random.nextInt(0x7fffffff).toRadixString(36);
    return 'p_${t}_$r';
  }
}
