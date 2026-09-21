import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

part 'organization_selection_gate.g.dart';

/// Session flag: user has explicitly chosen (or created) an organization.
///
/// Cleared on logout so the next login with 1+ memberships shows the picker
/// again. Kept in memory only — not persisted.
@Riverpod(keepAlive: true)
class OrganizationSelectionConfirmed
    extends _$OrganizationSelectionConfirmed {
  @override
  bool build() {
    ref.listen(currentAuthProvider, (previous, next) {
      if (next == null) {
        state = false;
      }
    });
    return false;
  }

  void confirm() => state = true;
}
