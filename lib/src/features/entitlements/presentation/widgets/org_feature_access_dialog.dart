import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../data/repositories/entitlement_repository.dart';
import '../../domain/feature_entitlement.dart';
import '../../domain/feature_key.dart';
import '../controllers/organization_entitlements_provider.dart';

const _kBrandTeal = Color(0xFF45A9AB);
const _kSurface = Color(0xFF141414);
const _kMuted = Color(0xFF9CA3AF);

/// Opens the Super Admin feature access dialog for one organization.
Future<void> showOrgFeatureAccessDialog(
  BuildContext context, {
  required String organizationId,
  required String organizationName,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => OrgFeatureAccessDialog(
      organizationId: organizationId,
      organizationName: organizationName,
    ),
  );
}

/// Super Admin: force a feature on/off for one organization regardless of its
/// subscription package, or clear the override to follow the plan.
class OrgFeatureAccessDialog extends HookConsumerWidget {
  const OrgFeatureAccessDialog({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });

  final String organizationId;
  final String organizationName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final savingKey = useState<FeatureKey?>(null);
    final entitlements =
        ref.watch(organizationEntitlementsProvider(organizationId)).value;

    Future<void> apply(
      BuildContext scopedContext,
      FeatureKey feature,
      bool? enabled,
    ) async {
      if (savingKey.value != null) return;
      final note = enabled == null
          ? ''
          : (formKey.currentState?.fields['note']?.value as String? ?? '')
              .trim();
      savingKey.value = feature;
      final result = await ref
          .read(entitlementRepositoryProvider)
          .setOverride(organizationId, feature, enabled: enabled, note: note);
      if (!context.mounted) return;
      savingKey.value = null;
      result.fold(
        (failure) => showErrorSnackBar(
          scopedContext,
          message: 'Failed to update feature: ${failure.messageString}',
          useRootMessenger: false,
        ),
        (_) {
          ref.invalidate(organizationEntitlementsProvider(organizationId));
          if (ref.read(currentOrganizationIdProvider) == organizationId) {
            ref.invalidate(currentOrganizationEntitlementsProvider);
          }
        },
      );
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          backgroundColor: _kSurface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feature access',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                organizationName,
                style: const TextStyle(
                  color: _kMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: entitlements == null
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(color: _kBrandTeal),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Force a feature on or off regardless of the '
                          'subscription package. Org admins will see it '
                          'labeled as set by a Super Admin.',
                          style: const TextStyle(color: _kMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        FormBuilder(
                          key: formKey,
                          child: FormBuilderTextField(
                            name: 'note',
                            decoration: const InputDecoration(
                              labelText: 'Note (saved with the next override)',
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final item in entitlements.ordered)
                          _FeatureOverrideRow(
                            item: item,
                            isSaving: savingKey.value == item.feature,
                            isBusy: savingKey.value != null,
                            onChanged: (enabled) =>
                                apply(context, item.feature, enabled),
                          ),
                      ],
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureOverrideRow extends StatelessWidget {
  const _FeatureOverrideRow({
    required this.item,
    required this.isSaving,
    required this.isBusy,
    required this.onChanged,
  });

  final FeatureEntitlement item;
  final bool isSaving;
  final bool isBusy;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    // SegmentedButton selection: 'plan' | 'on' | 'off'.
    final selected = switch (item.overrideEnabled) {
      true => 'on',
      false => 'off',
      null => 'plan',
    };
    final planText =
        item.planIncluded ? 'plan: included' : 'plan: not included';
    final resolved = item.enabled ? 'on' : 'off';
    final extra =
        item.blockedBy != null ? ' · needs ${item.blockedBy!.label}' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.feature.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$planText · now $resolved$extra'
                  '${item.hasOverride && item.note.isNotEmpty ? ' · ${item.note}' : ''}',
                  style: const TextStyle(color: _kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isSaving)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            SegmentedButton<String>(
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
              segments: const [
                ButtonSegment(value: 'plan', label: Text('Plan')),
                ButtonSegment(value: 'on', label: Text('On')),
                ButtonSegment(value: 'off', label: Text('Off')),
              ],
              selected: {selected},
              onSelectionChanged: isBusy
                  ? null
                  : (s) {
                      final v = s.first;
                      if (v == selected) return;
                      onChanged(switch (v) {
                        'on' => true,
                        'off' => false,
                        _ => null,
                      });
                    },
            ),
        ],
      ),
    );
  }
}
