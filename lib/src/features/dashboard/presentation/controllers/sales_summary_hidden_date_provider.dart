import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/storage/secure_storage_provider.dart';

part 'sales_summary_hidden_date_provider.g.dart';

const _salesSummaryHiddenDateKey = 'sales_summary_hidden_date';

final _dateFormat = DateFormat('yyyy-MM-dd');

/// Whether the sales summary should stay collapsed for [now]'s local date.
bool isSalesSummaryHiddenFor({
  required String? storedDate,
  required DateTime now,
}) {
  return storedDate == _dateFormat.format(now);
}

/// Device-local date the dashboard sales summary was collapsed.
///
/// When the stored value equals today's local date, the section stays hidden
/// until it is expanded again or the calendar day changes.
@Riverpod(keepAlive: true)
class SalesSummaryHiddenDate extends _$SalesSummaryHiddenDate {
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  Future<String?> build() async {
    return _storage.read(key: _salesSummaryHiddenDateKey);
  }

  /// Collapses the section for the rest of the local calendar day.
  Future<void> hideForToday() async {
    final today = _dateFormat.format(DateTime.now());
    state = AsyncData(today);
    await _storage.write(key: _salesSummaryHiddenDateKey, value: today);
  }

  /// Expands the section and clears the stored hide date.
  Future<void> show() async {
    state = const AsyncData(null);
    await _storage.delete(key: _salesSummaryHiddenDateKey);
  }
}
