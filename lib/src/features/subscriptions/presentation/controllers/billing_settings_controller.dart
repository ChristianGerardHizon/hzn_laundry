import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/subscription_repository.dart';
import '../../domain/platform_billing_settings.dart';

part 'billing_settings_controller.g.dart';

/// Platform-wide billing settings (QRPH, grace days, reminders).
@riverpod
class BillingSettingsController extends _$BillingSettingsController {
  SubscriptionRepository get _repository =>
      ref.read(subscriptionRepositoryProvider);

  @override
  Future<PlatformBillingSettings> build() async {
    final result = await _repository.getBillingSettings();
    return result.fold(
      (failure) => throw failure,
      (settings) => settings,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.getBillingSettings();
      return result.fold(
        (failure) => throw failure,
        (settings) => settings,
      );
    });
  }

  Future<bool> updateSettings({
    String? payeeName,
    String? instructions,
    int? defaultGraceDays,
    List<int>? reminderDaysBeforeDue,
    http.MultipartFile? qrphImage,
  }) async {
    final result = await _repository.updateBillingSettings(
      payeeName: payeeName,
      instructions: instructions,
      defaultGraceDays: defaultGraceDays,
      reminderDaysBeforeDue: reminderDaysBeforeDue,
      qrphImage: qrphImage,
    );
    return result.fold(
      (failure) => false,
      (updated) {
        state = AsyncData(updated);
        return true;
      },
    );
  }
}
