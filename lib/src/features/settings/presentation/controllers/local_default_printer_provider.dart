import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/storage/secure_storage_provider.dart';

part 'local_default_printer_provider.g.dart';

const _localDefaultPrinterKey = 'local_default_printer_id';

/// Provider to get/set the locally-configured default printer ID.
///
/// This allows each device to override the server-set default printer
/// with a local preference. If no local default is set, the server
/// default is used as fallback.
@Riverpod(keepAlive: true)
class LocalDefaultPrinterId extends _$LocalDefaultPrinterId {
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  Future<String?> build() async {
    return _storage.read(key: _localDefaultPrinterKey);
  }

  /// Sets the local default printer ID.
  Future<void> setLocalDefault(String printerId) async {
    await _storage.write(key: _localDefaultPrinterKey, value: printerId);
    state = AsyncData(printerId);
  }

  /// Clears the local default printer, falling back to server default.
  Future<void> clearLocalDefault() async {
    await _storage.delete(key: _localDefaultPrinterKey);
    state = const AsyncData(null);
  }
}
