import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../entitlements/domain/feature_key.dart';
import '../../domain/billing_interval_unit.dart';
import '../../domain/subscription_package.dart';
import '../controllers/packages_controller.dart';


/// Super Admin tab: list / create / edit / soft-delete subscription packages.
class PackagesTab extends HookConsumerWidget {
  const PackagesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final packagesAsync = ref.watch(packagesControllerProvider());
    final currency = useMemoized(
      () => NumberFormat.currency(symbol: '₱', decimalDigits: 2),
    );

    return packagesAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorState.fromError(
            e,
            onRetry: () =>
                ref.read(packagesControllerProvider().notifier).refresh(),
          ),
        ),
      ),
      data: (packages) {
        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () =>
              ref.read(packagesControllerProvider().notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => _showPackageDialog(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(t.subscriptions.createPackage),
                    ),
                  ),
                ),
              ),
              if (packages.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      t.subscriptions.noPackages,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList.separated(
                    itemCount: packages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final pkg = packages[index];
                      return _PackageCard(
                        package: pkg,
                        currency: currency,
                        onEdit: () =>
                            _showPackageDialog(context, ref, package: pkg),
                        onDelete: () => _confirmDelete(context, ref, pkg),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPackage package,
  ) async {
    final t = Translations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ScaffoldMessenger(
        child: Builder(
          builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            title: Text(t.subscriptions.deletePackage),
            content: Text(package.name),
            actions: [
              TextButton(
                onPressed: () => ctx.pop(false),
                child: Text(t.common.cancel),
              ),
              FilledButton(
                onPressed: () => ctx.pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: Text(t.subscriptions.deletePackage),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final ok = await ref
        .read(packagesControllerProvider().notifier)
        .softDeletePackage(package.id);
    if (!context.mounted) return;
    if (ok) {
      showSuccessSnackBar(
        context,
        message: t.subscriptions.packageDeleted,
        useRootMessenger: false,
      );
    } else {
      showErrorSnackBar(
        context,
        message: t.subscriptions.assignFailed,
        useRootMessenger: false,
      );
    }
  }

  Future<void> _showPackageDialog(
    BuildContext context,
    WidgetRef ref, {
    SubscriptionPackage? package,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _PackageFormDialog(package: package),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final SubscriptionPackage package;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final interval = switch (package.intervalUnit) {
      BillingIntervalUnit.day => t.subscriptions.intervalDay,
      BillingIntervalUnit.month => t.subscriptions.intervalMonth,
      BillingIntervalUnit.year => t.subscriptions.intervalYear,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (package.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      package.description,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${currency.format(package.price)} · '
                    '${package.intervalCount} $interval'
                    '${package.isPremade ? '' : ' · ${t.subscriptions.customPackage}'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Branches: ${package.maxBranches ?? 'Unlimited'} · '
                    'Employees: ${package.maxEmployees ?? 'Unlimited'}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
              tooltip: t.subscriptions.editPackage,
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              tooltip: t.subscriptions.deletePackage,
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageFormDialog extends HookConsumerWidget {
  const _PackageFormDialog({this.package});

  final SubscriptionPackage? package;

  bool get isEditing => package != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;
      final values = formKey.currentState!.value;
      isSaving.value = true;

      try {
        final name = (values['name'] as String).trim();
        final description = (values['description'] as String?)?.trim() ?? '';
        final price = num.parse(values['price'].toString());
        final intervalCount = int.parse(values['intervalCount'].toString());
        final intervalUnit = values['intervalUnit'] as BillingIntervalUnit;
        final isPremade = values['isPremade'] as bool? ?? true;
        final features =
            (values['features'] as List?)?.whereType<String>().toList() ??
                <String>[];
        // Blank = unlimited (sent as 0).
        int limitOf(String name) =>
            int.tryParse((values[name] as String?)?.trim() ?? '') ?? 0;
        final maxBranches = limitOf('maxBranches');
        final maxEmployees = limitOf('maxEmployees');

        final notifier = ref.read(packagesControllerProvider().notifier);
        if (isEditing) {
          final ok = await notifier.updatePackage(
            package!.id,
            name: name,
            description: description,
            price: price,
            intervalCount: intervalCount,
            intervalUnit: intervalUnit,
            isPremade: isPremade,
            features: features,
            maxBranches: maxBranches,
            maxEmployees: maxEmployees,
          );
          if (!context.mounted) return;
          if (ok) {
            showSuccessSnackBar(
              context,
              message: t.subscriptions.packageUpdated,
              useRootMessenger: false,
            );
            context.pop();
          } else {
            showErrorSnackBar(
              context,
              message: t.subscriptions.assignFailed,
              useRootMessenger: false,
            );
          }
        } else {
          final created = await notifier.createPackage(
            name: name,
            description: description,
            price: price,
            intervalCount: intervalCount,
            intervalUnit: intervalUnit,
            isPremade: isPremade,
            features: features,
            maxBranches: maxBranches,
            maxEmployees: maxEmployees,
          );
          if (!context.mounted) return;
          if (created != null) {
            showSuccessSnackBar(
              context,
              message: t.subscriptions.packageCreated,
              useRootMessenger: false,
            );
            context.pop();
          } else {
            showErrorSnackBar(
              context,
              message: t.subscriptions.assignFailed,
              useRootMessenger: false,
            );
          }
        }
      } finally {
        if (context.mounted) isSaving.value = false;
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          title: Text(
            isEditing
                ? t.subscriptions.editPackage
                : t.subscriptions.createPackage,
          ),
          content: SizedBox(
            width: 420,
            child: FormBuilder(
              key: formKey,
              initialValue: {
                'name': package?.name ?? '',
                'description': package?.description ?? '',
                'price': package?.price.toString() ?? '',
                'intervalCount': package?.intervalCount.toString() ?? '1',
                'intervalUnit':
                    package?.intervalUnit ?? BillingIntervalUnit.month,
                'isPremade': package?.isPremade ?? true,
                'features': package?.features ??
                    [
                      for (final f in FeatureKey.values)
                        if (!f.defaultOff) f.key,
                    ],
                'maxBranches': package?.maxBranches?.toString() ?? '',
                'maxEmployees': package?.maxEmployees?.toString() ?? '',
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: 'name',
                      decoration: InputDecoration(
                        labelText: t.subscriptions.packageName,
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'description',
                      decoration: InputDecoration(
                        labelText: t.subscriptions.packageDescription,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'price',
                      decoration: InputDecoration(
                        labelText: t.subscriptions.packagePrice,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderTextField(
                            name: 'intervalCount',
                            decoration: InputDecoration(
                              labelText: t.subscriptions.intervalCount,
                            ),
                            keyboardType: TextInputType.number,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.integer(),
                              FormBuilderValidators.min(1),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FormBuilderDropdown<BillingIntervalUnit>(
                            name: 'intervalUnit',
                            decoration: InputDecoration(
                              labelText: t.subscriptions.intervalUnit,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: BillingIntervalUnit.day,
                                child: Text(t.subscriptions.intervalDay),
                              ),
                              DropdownMenuItem(
                                value: BillingIntervalUnit.month,
                                child: Text(t.subscriptions.intervalMonth),
                              ),
                              DropdownMenuItem(
                                value: BillingIntervalUnit.year,
                                child: Text(t.subscriptions.intervalYear),
                              ),
                            ],
                            validator: FormBuilderValidators.required(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FormBuilderSwitch(
                      name: 'isPremade',
                      title: Text(t.subscriptions.isPremade),
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderTextField(
                            name: 'maxBranches',
                            decoration: const InputDecoration(
                              labelText: 'Max branches',
                              hintText: 'Unlimited',
                            ),
                            keyboardType: TextInputType.number,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.integer(),
                              FormBuilderValidators.min(0),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FormBuilderTextField(
                            name: 'maxEmployees',
                            decoration: const InputDecoration(
                              labelText: 'Max employees',
                              hintText: 'Unlimited',
                            ),
                            keyboardType: TextInputType.number,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.integer(),
                              FormBuilderValidators.min(0),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FormBuilderCheckboxGroup<String>(
                      name: 'features',
                      orientation: OptionsOrientation.vertical,
                      decoration: const InputDecoration(
                        labelText: 'Included features',
                        border: InputBorder.none,
                      ),
                      activeColor: Theme.of(context).colorScheme.primary,
                      options: [
                        for (final f in FeatureKey.values)
                          FormBuilderFieldOption<String>(
                            value: f.key,
                            child: Text(f.label),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving.value ? null : () => context.pop(),
              child: Text(t.common.cancel),
            ),
            FilledButton(
              onPressed: isSaving.value ? null : handleSave,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: isSaving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(t.common.save),
            ),
          ],
        ),
      ),
    );
  }
}
