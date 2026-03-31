import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_dismissed_provider.g.dart';

/// Tracks whether the optional update dialog has been dismissed this session.
///
/// Prevents the dialog from showing again after the user taps "Later".
@Riverpod(keepAlive: true)
class UpdateDismissed extends _$UpdateDismissed {
  @override
  bool build() => false;

  /// Mark the dialog as dismissed for this session.
  void dismiss() {
    state = true;
  }
}
