import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/printer_config.dart';
import '../dto/printer_config_dto.dart';

part 'printer_config_repository.g.dart';

/// Repository interface for printer configuration operations.
abstract class PrinterConfigRepository {
  /// Fetches all printer configurations.
  FutureEither<List<PrinterConfig>> fetchAll({String? filter});

  /// Fetches a single printer configuration by ID.
  FutureEither<PrinterConfig> fetchOne(String id);

  /// Fetches the default printer configuration, if any.
  FutureEither<PrinterConfig?> fetchDefault();

  /// Creates a new printer configuration.
  FutureEither<PrinterConfig> create(PrinterConfig config);

  /// Updates an existing printer configuration.
  FutureEither<PrinterConfig> update(PrinterConfig config);

  /// Soft deletes a printer configuration by ID.
  FutureEither<void> delete(String id);

  /// Sets a printer as the default (unsets any existing default).
  FutureEither<void> setAsDefault(String id);
}

/// Provides the PrinterConfigRepository instance.
@Riverpod(keepAlive: true)
PrinterConfigRepository printerConfigRepository(Ref ref) {
  return PrinterConfigRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [PrinterConfigRepository] using PocketBase.
class PrinterConfigRepositoryImpl implements PrinterConfigRepository {
  final PocketBase _pb;

  PrinterConfigRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.printerConfigs);

  PrinterConfig _toEntity(RecordModel record) {
    final dto = PrinterConfigDto.fromRecord(record);
    return dto.toEntity();
  }

  @override
  FutureEither<List<PrinterConfig>> fetchAll({String? filter}) async {
    return TaskEither.tryCatch(
      () async {
        final baseFilter = PBFilters.active.build();
        final combinedFilter =
            filter != null ? '$baseFilter && $filter' : baseFilter;

        final records = await _collection.getFullList(
          filter: combinedFilter,
          sort: '-isDefault,name',
        );

        return records.map(_toEntity).toList();
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

        final record = await _collection.getOne(id);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<PrinterConfig?> fetchDefault() async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilters.active
            .and(PBFilter().isTrue('isDefault'))
            .and(PBFilter().isTrue('isEnabled'))
            .build();

        final records = await _collection.getFullList(filter: filter);

        if (records.isEmpty) return null;
        return _toEntity(records.first);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<PrinterConfig> create(PrinterConfig config) async {
    return TaskEither.tryCatch(
      () async {
        // If setting as default, unset any existing defaults first
        if (config.isDefault) {
          await _unsetAllDefaults();
        }

        final body = <String, dynamic>{
          'name': config.name,
          'connectionType': config.connectionType.name,
          'address': config.address,
          'port': config.port,
          'paperWidth': config.paperWidth.name,
          'isDefault': config.isDefault,
          'isEnabled': config.isEnabled,
          'branch': config.branchId,
          'isDeleted': false,
        };

        final record = await _collection.create(body: body);
        return _toEntity(record);
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

        // If setting as default, unset any existing defaults first
        if (config.isDefault) {
          await _unsetAllDefaults();
        }

        final body = <String, dynamic>{
          'name': config.name,
          'connectionType': config.connectionType.name,
          'address': config.address,
          'port': config.port,
          'paperWidth': config.paperWidth.name,
          'isDefault': config.isDefault,
          'isEnabled': config.isEnabled,
          'branch': config.branchId,
        };

        final record = await _collection.update(config.id, body: body);
        return _toEntity(record);
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

        // Soft delete
        await _collection.update(id, body: {'isDeleted': true});
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> setAsDefault(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Printer config ID cannot be empty',
            null,
            'invalid_printer_config_id',
          );
        }

        // Unset all defaults first
        await _unsetAllDefaults();

        // Set the specified printer as default
        await _collection.update(id, body: {'isDefault': true});
      },
      Failure.handle,
    ).run();
  }

  /// Unsets isDefault on all printer configurations.
  Future<void> _unsetAllDefaults() async {
    final filter = PBFilter().isTrue('isDefault').build();
    final defaults = await _collection.getFullList(filter: filter);

    for (final record in defaults) {
      await _collection.update(record.id, body: {'isDefault': false});
    }
  }
}
