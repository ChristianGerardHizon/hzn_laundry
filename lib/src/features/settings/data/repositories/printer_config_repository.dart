import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../domain/printer_config.dart';
import '../dto/printer_config_dto.dart';

part 'printer_config_repository.g.dart';

const _localPrintersKey = 'local_printers';
const _localPrintersMigratedKey = 'local_printers_migrated';
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
  return PrinterConfigRepositoryImpl(
    ref.watch(secureStorageProvider),
    ref.watch(pocketbaseProvider),
  );
}

/// Implementation of [PrinterConfigRepository] using on-device storage.
class PrinterConfigRepositoryImpl implements PrinterConfigRepository {
  PrinterConfigRepositoryImpl(this._storage, this._pb);

  final FlutterSecureStorage _storage;
  final PocketBase _pb;
  final Random _random = Random();
  Future<void>? _migration;

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.printerConfigs);

  @override
  FutureEither<List<PrinterConfig>> fetchAll() async {
    return TaskEither.tryCatch(
      () async {
        await _migrateFromServerIfNeeded();
        return _readPrinters();
      },
      Failure.handle,
    ).run();
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

        await _migrateFromServerIfNeeded();
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

  Future<void> _migrateFromServerIfNeeded() async {
    final migrated = await _storage.read(key: _localPrintersMigratedKey);
    if (migrated == 'true') return;

    final inFlight = _migration;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = _runMigration();
    _migration = future;
    try {
      await future;
    } finally {
      if (identical(_migration, future)) _migration = null;
    }
  }

  Future<void> _runMigration() async {
    try {
      final records = await _collection.getFullList(
        filter: PBFilters.active.build(),
        sort: 'name',
      );

      final dtos = records
          .map(PrinterConfigDto.fromRecord)
          .where((dto) => !dto.isDeleted)
          .toList();
      final printers = dtos.map((dto) => dto.toEntity()).toList();
      await _writePrinters(printers);

      final existingSelected = await _storage.read(key: selectedPrinterIdKey);
      final legacySelected =
          await _storage.read(key: legacyLocalDefaultPrinterKey);
      final printerIds = printers.map((p) => p.id).toSet();

      String? selectedId = existingSelected;
      if (selectedId == null ||
          selectedId.isEmpty ||
          !printerIds.contains(selectedId)) {
        if (legacySelected != null && printerIds.contains(legacySelected)) {
          selectedId = legacySelected;
        } else {
          final serverDefault = dtos.cast<PrinterConfigDto?>().firstWhere(
                (dto) => dto!.isDefault && dto.isEnabled,
                orElse: () => null,
              );
          selectedId = serverDefault?.id ??
              printers
                  .cast<PrinterConfig?>()
                  .firstWhere(
                    (p) => p!.isEnabled,
                    orElse: () => null,
                  )
                  ?.id;
        }
      }

      if (selectedId != null && selectedId.isNotEmpty) {
        await _storage.write(key: selectedPrinterIdKey, value: selectedId);
      }

      await _storage.write(key: _localPrintersMigratedKey, value: 'true');
    } catch (_) {
      // Leave un-migrated so a later launch can retry when the server is reachable.
    }
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
