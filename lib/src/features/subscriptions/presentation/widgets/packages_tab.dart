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
import '../../domain/billing_interval_unit.dart';
import '../../domain/subscription_package.dart';
import '../controllers/packages_controller.dart';

const _kBrandTeal = Color(0xFF45A9AB);
const _kInk = Color(0xFF0B0B0B);
const _kSurface = Color(0xFF141414);
const _kSurfaceBorder = Color(0xFF2A2A2A);
const _kMuted = Color(0xFF9CA3AF);

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
      loading: () => const Center(
        child: CircularProgressIndicator(color: _kBrandTeal),
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
          color: _kBrandTeal,
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
                        backgroundColor: _kBrandTeal,
                        foregroundColor: _kInk,
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
                      style: const TextStyle(color: _kMuted),
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
                        onDelete: () =>
                            _confirmDelete(context, ref, pkg),
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
            backgroundColor: _kSurface,
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
                  backgroundColor: Colors.redAccent,
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
        color: _kSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kSurfaceBorder),
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
                      style: const TextStyle(color: _kMuted, fontSize: 13),
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
                          color: _kBrandTeal,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, color: _kMuted),
              tooltip: t.subscriptions.editPackage,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
          backgroundColor: _kSurface,
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
                      decoration: const InputDecoration(border: InputBorder.none),
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
                backgroundColor: _kBrandTeal,
                foregroundColor: _kInk,
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
