import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../data/repositories/incentive_tier_repository.dart';
import '../../../domain/branch.dart';
import '../../controllers/branches_controller.dart';
import '../../../../organizations/presentation/controllers/current_organization_controller.dart';

/// Dialog for creating or editing a branch.
class BranchFormDialog extends HookConsumerWidget {
  const BranchFormDialog({
    super.key,
    this.branch,
    this.organizationId,
  });

  final Branch? branch;
  final String? organizationId;

  bool get isEditing => branch != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': branch!.name,
              'address': branch!.address,
              'contactNumber': branch!.contactNumber,
              'operatingHours': branch!.operatingHours ?? '',
              'cutOffTime': branch!.cutOffTime ?? '',
              'incentiveAmount': branch!.incentiveAmount.toString(),
              'incentivePerServiceItems':
                  branch!.incentivePerServiceItems.toString(),
            }
          : null,
    );

    // UI state
    final isSaving = useState(false);

    // Incentive tiers state
    final tiers = useState<List<_TierEntry>>([]);
    final tiersLoaded = useState(false);

    // Load existing tiers when editing
    useEffect(() {
      if (isEditing && !tiersLoaded.value) {
        ref
            .read(incentiveTierRepositoryProvider)
            .fetchForBranch(branch!.id)
            .then((result) {
          result.fold(
            (_) {},
            (list) {
              if (list.isEmpty) {
                // Migrate from flat fields: create a default tier
                tiers.value = [
                  _TierEntry(
                    minAmount: 0,
                    maxAmount: branch!.incentivePerServiceItems,
                    incentiveAmount: branch!.incentiveAmount,
                  ),
                ];
              } else {
                tiers.value = list
                    .map((t) => _TierEntry(
                          id: t.id,
                          minAmount: t.minAmount,
                          maxAmount: t.maxAmount,
                          incentiveAmount: t.incentiveAmount,
                        ))
                    .toList();
              }
              tiersLoaded.value = true;
            },
          );
        });
      } else if (!isEditing && !tiersLoaded.value) {
        // Default tier for new branch
        tiers.value = [
          const _TierEntry(minAmount: 0, maxAmount: 200, incentiveAmount: 5),
        ];
        tiersLoaded.value = true;
      }
      return null;
    }, [isEditing]);

    Future<void> handleSave() async {
      final isValid = formKey.currentState!.saveAndValidate();

      if (!isValid) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, _fieldLabels);

        if (errorMessages.isNotEmpty) {
          showFormErrorDialog(context, errors: errorMessages);
        }
        return;
      }

      if (tiers.value.isEmpty) {
        showFormErrorDialog(
          context,
          errors: ['At least one incentive tier is required.'],
        );
        return;
      }

      final values = formKey.currentState!.value;

      isSaving.value = true;

      final branchData = Branch(
        id: branch?.id ?? '',
        organizationId: branch?.organizationId ??
            organizationId ??
            ref.read(currentOrganizationIdProvider),
        name: (values['name'] as String).trim(),
        address: (values['address'] as String).trim(),
        contactNumber: (values['contactNumber'] as String).trim(),
        operatingHours: _nullIfEmpty(values['operatingHours'] as String?),
        cutOffTime: _nullIfEmpty(values['cutOffTime'] as String?),
      );

      bool success;
      if (isEditing) {
        success = await ref
            .read(branchesControllerProvider.notifier)
            .updateBranch(branchData);
      } else {
        success = await ref
            .read(branchesControllerProvider.notifier)
            .createBranch(branchData);
      }

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save branch. Please try again.'],
          );
        }
        return;
      }

      // Save tiers
      final branchId = isEditing
          ? branch!.id
          : ref.read(branchesControllerProvider).value?.last.id ?? '';

      if (branchId.isNotEmpty) {
        final tierData = tiers.value
            .asMap()
            .entries
            .map((e) => IncentiveTierData(
                  id: e.value.id,
                  minAmount: e.value.minAmount,
                  maxAmount: e.value.maxAmount,
                  incentiveAmount: e.value.incentiveAmount,
                  sortOrder: e.key,
                ))
            .toList();

        await ref.read(incentiveTierRepositoryProvider).replaceTiers(
              branchId: branchId,
              tiers: tierData,
            );
      }

      if (context.mounted) {
        isSaving.value = false;
        context.pop();

        showSuccessSnackBar(
          context,
          message: isEditing
              ? 'Branch updated successfully'
              : 'Branch created successfully',
        );
      }
    }

    return DialogCloseHandler(
      onClose: (ctx) => dirtyGuard.confirmDiscard(ctx),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: dirtyGuard.onPopInvokedWithResult,
        child: ConstrainedDialogContent(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: isSaving.value
                          ? null
                          : () async {
                              if (await dirtyGuard.confirmDiscard(context)) {
                                if (context.mounted) context.pop();
                              }
                            },
                    ),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Branch' : 'New Branch',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: isSaving.value
                            ? null
                            : () async {
                                if (await dirtyGuard.confirmDiscard(context)) {
                                  if (context.mounted) context.pop();
                                }
                              },
                        child: Text(t.common.cancel),
                      ),
                    ),
                    FilledButton(
                      onPressed: isSaving.value ? null : handleSave,
                      child: isSaving.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(t.common.save),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Content
              Expanded(
                child: FormBuilder(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // Name field
                        FormBuilderTextField(
                          name: 'name',
                          initialValue: branch?.name,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            hintText: 'Enter branch name (internal)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.store),
                          ),
                          enabled: !isSaving.value,
                          validator: FormBuilderValidators.required(
                            errorText: 'Name is required',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Address field
                        FormBuilderTextField(
                          name: 'address',
                          initialValue: branch?.address,
                          decoration: const InputDecoration(
                            labelText: 'Address *',
                            hintText: 'Enter address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          enabled: !isSaving.value,
                          maxLines: 2,
                          validator: FormBuilderValidators.required(
                            errorText: 'Address is required',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Contact number field
                        FormBuilderTextField(
                          name: 'contactNumber',
                          initialValue: branch?.contactNumber,
                          decoration: const InputDecoration(
                            labelText: 'Contact Number *',
                            hintText: 'Enter contact number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          enabled: !isSaving.value,
                          keyboardType: TextInputType.phone,
                          validator: FormBuilderValidators.required(
                            errorText: 'Contact number is required',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Operating hours field
                        FormBuilderTextField(
                          name: 'operatingHours',
                          initialValue: branch?.operatingHours,
                          decoration: const InputDecoration(
                            labelText: 'Operating Hours',
                            hintText: 'e.g., Mon-Sat 8:00 AM - 5:00 PM',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.schedule),
                          ),
                          enabled: !isSaving.value,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Cut-off time field
                        FormBuilderTextField(
                          name: 'cutOffTime',
                          initialValue: branch?.cutOffTime,
                          decoration: const InputDecoration(
                            labelText: 'Cut-off Time',
                            hintText: 'e.g., 4:30 PM',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer_off),
                          ),
                          enabled: !isSaving.value,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 24),

                        // Incentive tiers section
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Incentive Tiers',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: isSaving.value
                                  ? null
                                  : () {
                                      final currentTiers =
                                          List<_TierEntry>.from(tiers.value);
                                      final lastMax = currentTiers.isNotEmpty
                                          ? (currentTiers.last.maxAmount ?? 0)
                                          : 0;
                                      currentTiers.add(_TierEntry(
                                        minAmount: lastMax,
                                        maxAmount: lastMax + 200,
                                        incentiveAmount:
                                            (currentTiers.isNotEmpty
                                                    ? currentTiers
                                                        .last.incentiveAmount
                                                    : 0) +
                                                5,
                                      ));
                                      tiers.value = currentTiers;
                                    },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Tier'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Incentive earned based on service price range. If service price exceeds the last tier, the last tier\'s incentive is used.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tier list
                        if (!tiersLoaded.value)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          ...tiers.value.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final tier = entry.value;
                            return _IncentiveTierRow(
                              key: ValueKey('tier_$idx'),
                              index: idx,
                              tier: tier,
                              enabled: !isSaving.value,
                              onChanged: (updated) {
                                final currentTiers =
                                    List<_TierEntry>.from(tiers.value);
                                currentTiers[idx] = updated;
                                tiers.value = currentTiers;
                              },
                              onRemove: tiers.value.length > 1
                                  ? () {
                                      final currentTiers =
                                          List<_TierEntry>.from(tiers.value);
                                      currentTiers.removeAt(idx);
                                      tiers.value = currentTiers;
                                    }
                                  : null,
                            );
                          }),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _fieldLabels = {
    'name': 'Name',
    'address': 'Address',
    'contactNumber': 'Contact Number',
    'operatingHours': 'Operating Hours',
    'cutOffTime': 'Cut-off Time',
  };

  String? _nullIfEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}

/// Shows the branch form dialog.
void showBranchFormDialog(
  BuildContext context, {
  Branch? branch,
  String? organizationId,
}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => BranchFormDialog(
      branch: branch,
      organizationId: organizationId,
    ),
  );
}

/// Internal data class for a tier row in the form.
class _TierEntry {
  const _TierEntry({
    this.id,
    required this.minAmount,
    this.maxAmount,
    required this.incentiveAmount,
  });

  final String? id;
  final num minAmount;
  final num? maxAmount;
  final num incentiveAmount;

  _TierEntry copyWith({
    num? minAmount,
    num? maxAmount,
    bool clearMaxAmount = false,
    num? incentiveAmount,
  }) {
    return _TierEntry(
      id: id,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      incentiveAmount: incentiveAmount ?? this.incentiveAmount,
    );
  }
}

/// A single tier row in the incentive tiers form.
class _IncentiveTierRow extends HookWidget {
  const _IncentiveTierRow({
    super.key,
    required this.index,
    required this.tier,
    required this.enabled,
    required this.onChanged,
    this.onRemove,
  });

  final int index;
  final _TierEntry tier;
  final bool enabled;
  final ValueChanged<_TierEntry> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final minController =
        useTextEditingController(text: tier.minAmount.toStringAsFixed(0));
    final maxController = useTextEditingController(
        text: tier.maxAmount?.toStringAsFixed(0) ?? '');
    final amountController =
        useTextEditingController(text: tier.incentiveAmount.toStringAsFixed(0));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Tier ${index + 1}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (onRemove != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: enabled ? onRemove : null,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Remove tier',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minController,
                      decoration: const InputDecoration(
                        labelText: 'Min',
                        prefixText: '\u20B1 ',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      enabled: enabled,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final val = num.tryParse(v) ?? 0;
                        onChanged(tier.copyWith(minAmount: val));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: maxController,
                      decoration: InputDecoration(
                        labelText: 'Max',
                        prefixText: '\u20B1 ',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        hintText: 'No limit',
                        hintStyle: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      enabled: enabled,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        if (v.isEmpty) {
                          onChanged(tier.copyWith(clearMaxAmount: true));
                        } else {
                          final val = num.tryParse(v) ?? 0;
                          onChanged(tier.copyWith(maxAmount: val));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Incentive',
                        prefixText: '\u20B1 ',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      enabled: enabled,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final val = num.tryParse(v) ?? 0;
                        onChanged(tier.copyWith(incentiveAmount: val));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
