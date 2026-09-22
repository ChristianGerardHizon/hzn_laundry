import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../organizations/domain/organization_platform_stats.dart';
import '../../../organizations/presentation/controllers/organization_platform_stats_controller.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../domain/billing_interval_unit.dart';
import '../../domain/subscription_package.dart';
import '../../domain/subscription_status.dart';
import '../controllers/packages_controller.dart';

const _kBrandTeal = Color(0xFF45A9AB);
const _kInk = Color(0xFF0B0B0B);
const _kSurface = Color(0xFF141414);
const _kMuted = Color(0xFF9CA3AF);

/// Opens the org subscription management dialog.
Future<void> showOrgSubscriptionDialog(
  BuildContext context,
  OrganizationPlatformStats org,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => OrgSubscriptionDialog(org: org),
  );
}

/// Dialog for managing one organization's subscription.
class OrgSubscriptionDialog extends HookConsumerWidget {
  const OrgSubscriptionDialog({super.key, required this.org});

  final OrganizationPlatformStats org;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final dateFmt = useMemoized(() => DateFormat.yMMMd());
    final status = _parseStatus(org.subscriptionStatus);
    final hasSubscription = org.subscriptionStatus != null &&
        org.subscriptionStatus!.isNotEmpty;

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) {
          return AlertDialog(
            backgroundColor: _kSurface,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  org.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.subscriptions.orgDetails,
                  style: const TextStyle(
                    color: _kMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DetailRow(
                      label: t.subscriptions.packageName,
                      value: org.packageName?.isNotEmpty == true
                          ? org.packageName!
                          : t.subscriptions.noSubscription,
                    ),
                    _DetailRow(
                      label: t.subscriptions.subscription,
                      value: hasSubscription
                          ? _statusLabel(t, status)
                          : t.subscriptions.noSubscription,
                    ),
                    if (org.periodEnd != null)
                      _DetailRow(
                        label: t.subscriptions.periodEnds,
                        value: dateFmt.format(org.periodEnd!.toLocal()),
                      ),
                    if (org.graceEndsAt != null)
                      _DetailRow(
                        label: t.subscriptions.graceEnds,
                        value: dateFmt.format(org.graceEndsAt!.toLocal()),
                      ),
                    _DetailRow(
                      label: t.subscriptions.pendingProofs,
                      value: '${org.pendingPaymentCount}',
                    ),
                    if (org.pendingPaymentCount > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          t.subscriptions.pendingPayments,
                          style: TextStyle(
                            color: Colors.amber.shade200,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _showAssignDialog(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: _kBrandTeal,
                        foregroundColor: _kInk,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      icon: const Icon(Icons.card_membership_outlined),
                      label: Text(
                        hasSubscription
                            ? t.subscriptions.changePackage
                            : t.subscriptions.assignPackage,
                      ),
                    ),
                    if (hasSubscription &&
                        status != SubscriptionStatus.locked) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _showLockDialog(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          minimumSize: const Size.fromHeight(44),
                        ),
                        icon: const Icon(Icons.lock_outline),
                        label: Text(t.subscriptions.manualLock),
                      ),
                    ],
                    if (hasSubscription) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _showUnlockDialog(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kBrandTeal,
                          side: const BorderSide(color: _kBrandTeal),
                          minimumSize: const Size.fromHeight(44),
                        ),
                        icon: const Icon(Icons.lock_open_outlined),
                        label: Text(t.subscriptions.manualUnlock),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAssignDialog(BuildContext context, WidgetRef ref) async {
    final t = Translations.of(context);
    final assigned = await showDialog<bool>(
      context: context,
      builder: (ctx) => _AssignPackageDialog(organizationId: org.id),
    );
    if (!context.mounted) return;
    if (assigned == true) {
      showSuccessSnackBar(
        context,
        message: t.subscriptions.assignSuccess,
        useRootMessenger: false,
      );
      context.pop();
    }
  }

  Future<void> _showLockDialog(BuildContext context, WidgetRef ref) async {
    final t = Translations.of(context);
    final locked = await showDialog<bool>(
      context: context,
      builder: (ctx) => _LockDialog(organizationId: org.id),
    );
    if (!context.mounted) return;
    if (locked == true) {
      showSuccessSnackBar(
        context,
        message: t.subscriptions.lockSuccess,
        useRootMessenger: false,
      );
      context.pop();
    }
  }

  Future<void> _showUnlockDialog(BuildContext context, WidgetRef ref) async {
    final t = Translations.of(context);
    final unlocked = await showDialog<bool>(
      context: context,
      builder: (ctx) => _UnlockDialog(organizationId: org.id),
    );
    if (!context.mounted) return;
    if (unlocked == true) {
      showSuccessSnackBar(
        context,
        message: t.subscriptions.unlockSuccess,
        useRootMessenger: false,
      );
      context.pop();
    }
  }
}

class _LockDialog extends HookConsumerWidget {
  const _LockDialog({required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isSaving = useState(false);
    final noteController = useTextEditingController();

    Future<void> lock() async {
      if (isSaving.value) return;
      isSaving.value = true;
      try {
        final result = await ref
            .read(subscriptionRepositoryProvider)
            .lockOrganization(
              organizationId,
              note: noteController.text.trim().isEmpty
                  ? null
                  : noteController.text.trim(),
            );
        if (!context.mounted) return;
        result.fold(
          (_) => showErrorSnackBar(
            context,
            message: t.subscriptions.lockFailed,
            useRootMessenger: false,
          ),
          (_) {
            ref
                .read(organizationPlatformStatsControllerProvider.notifier)
                .refresh();
            context.pop(true);
          },
        );
      } finally {
        if (context.mounted) isSaving.value = false;
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          backgroundColor: _kSurface,
          title: Text(t.subscriptions.manualLock),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.subscriptions.lockConfirmMessage,
                style: const TextStyle(color: _kMuted, height: 1.35),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: t.subscriptions.adminNote,
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving.value ? null : () => context.pop(),
              child: Text(t.common.cancel),
            ),
            FilledButton(
              onPressed: isSaving.value ? null : lock,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: isSaving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(t.subscriptions.manualLock),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockDialog extends HookConsumerWidget {
  const _UnlockDialog({required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final until = useState(DateTime.now().add(const Duration(days: 7)));
    final isSaving = useState(false);
    final noteController = useTextEditingController();

    Future<void> unlock() async {
      if (isSaving.value) return;
      isSaving.value = true;
      try {
        final result = await ref
            .read(subscriptionRepositoryProvider)
            .unlockOrganization(
              organizationId,
              until: until.value,
              note: noteController.text.trim().isEmpty
                  ? null
                  : noteController.text.trim(),
            );
        if (!context.mounted) return;
        result.fold(
          (_) => showErrorSnackBar(
            context,
            message: t.subscriptions.unlockFailed,
            useRootMessenger: false,
          ),
          (_) {
            ref
                .read(organizationPlatformStatsControllerProvider.notifier)
                .refresh();
            context.pop(true);
          },
        );
      } finally {
        if (context.mounted) isSaving.value = false;
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          backgroundColor: _kSurface,
          title: Text(t.subscriptions.manualUnlock),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.subscriptions.unlockUntil),
                subtitle: Text(
                  DateFormat.yMMMd().add_jm().format(until.value),
                ),
                trailing: const Icon(Icons.calendar_today, color: _kBrandTeal),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: until.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date == null || !context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(until.value),
                  );
                  if (time == null) {
                    until.value = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      until.value.hour,
                      until.value.minute,
                    );
                  } else {
                    until.value = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  }
                },
              ),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: t.subscriptions.adminNote,
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving.value ? null : () => context.pop(),
              child: Text(t.common.cancel),
            ),
            FilledButton(
              onPressed: isSaving.value ? null : unlock,
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
                  : Text(t.subscriptions.manualUnlock),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignPackageDialog extends HookConsumerWidget {
  const _AssignPackageDialog({required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final useCustom = useState(false);
    final packagesAsync = ref.watch(packagesControllerProvider());

    Future<void> assign() async {
      if (!formKey.currentState!.saveAndValidate()) return;
      if (isSaving.value) return;
      isSaving.value = true;
      try {
        final values = formKey.currentState!.value;
        final periodStart = values['periodStart'] as DateTime?;
        final periodEnd = values['periodEnd'] as DateTime?;
        final result = useCustom.value
            ? await ref.read(subscriptionRepositoryProvider).assignSubscription(
                  organizationId,
                  customPackage: {
                    'name': (values['customName'] as String).trim(),
                    'description':
                        (values['customDescription'] as String?)?.trim() ?? '',
                    'price': num.parse(values['customPrice'].toString()),
                    'intervalCount':
                        int.parse(values['customIntervalCount'].toString()),
                    'intervalUnit':
                        (values['customIntervalUnit'] as BillingIntervalUnit)
                            .name,
                  },
                  periodStart: periodStart,
                  periodEnd: periodEnd,
                )
            : await ref.read(subscriptionRepositoryProvider).assignSubscription(
                  organizationId,
                  packageId: values['packageId'] as String,
                  periodStart: periodStart,
                  periodEnd: periodEnd,
                );

        if (!context.mounted) return;
        result.fold(
          (_) => showErrorSnackBar(
            context,
            message: t.subscriptions.assignFailed,
            useRootMessenger: false,
          ),
          (_) {
            ref
                .read(organizationPlatformStatsControllerProvider.notifier)
                .refresh();
            context.pop(true);
          },
        );
      } finally {
        if (context.mounted) isSaving.value = false;
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          backgroundColor: _kSurface,
          title: Text(t.subscriptions.assignPackage),
          content: SizedBox(
            width: 440,
            child: FormBuilder(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.subscriptions.customPackage),
                      value: useCustom.value,
                      activeThumbColor: _kBrandTeal,
                      onChanged: (v) => useCustom.value = v,
                    ),
                    const SizedBox(height: 8),
                    if (!useCustom.value)
                      packagesAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: _kBrandTeal),
                        ),
                        error: (e, _) => Text('$e'),
                        data: (packages) {
                          final premade = packages
                              .where((p) => p.isPremade && p.isActive)
                              .toList();
                          return FormBuilderDropdown<String>(
                            name: 'packageId',
                            decoration: InputDecoration(
                              labelText: t.subscriptions.selectPackage,
                            ),
                            items: premade
                                .map(
                                  (SubscriptionPackage p) => DropdownMenuItem(
                                    value: p.id,
                                    child: Text(
                                      '${p.name} · '
                                      '${NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(p.price)}',
                                    ),
                                  ),
                                )
                                .toList(),
                            validator: FormBuilderValidators.required(),
                          );
                        },
                      )
                    else ...[
                      FormBuilderTextField(
                        name: 'customName',
                        decoration: InputDecoration(
                          labelText: t.subscriptions.packageName,
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'customDescription',
                        decoration: InputDecoration(
                          labelText: t.subscriptions.packageDescription,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'customPrice',
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'customIntervalCount',
                              initialValue: '1',
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: FormBuilderDropdown<BillingIntervalUnit>(
                              name: 'customIntervalUnit',
                              initialValue: BillingIntervalUnit.month,
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
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        t.subscriptions.periodDatesHint,
                        style: const TextStyle(color: _kMuted, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormBuilderDateTimePicker(
                      name: 'periodStart',
                      inputType: InputType.date,
                      decoration: InputDecoration(
                        labelText: t.subscriptions.periodStart,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FormBuilderDateTimePicker(
                      name: 'periodEnd',
                      inputType: InputType.date,
                      decoration: InputDecoration(
                        labelText: t.subscriptions.periodEnd,
                      ),
                      validator: (end) {
                        final start = formKey
                            .currentState?.fields['periodStart']?.value
                            as DateTime?;
                        if (end != null && start == null) {
                          return t.subscriptions.periodStartRequiredWithEnd;
                        }
                        if (end != null &&
                            start != null &&
                            !end.isAfter(start)) {
                          return t.subscriptions.periodEndAfterStart;
                        }
                        return null;
                      },
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
              onPressed: isSaving.value ? null : assign,
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
                  : Text(t.subscriptions.assignPackage),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: _kMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

SubscriptionStatus? _parseStatus(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return SubscriptionStatus.fromString(raw);
}

String _statusLabel(Translations t, SubscriptionStatus? status) {
  if (status == null) return t.subscriptions.noSubscription;
  return switch (status) {
    SubscriptionStatus.active => t.subscriptions.statusActive,
    SubscriptionStatus.grace => t.subscriptions.statusGrace,
    SubscriptionStatus.locked => t.subscriptions.statusLocked,
    SubscriptionStatus.cancelled => t.subscriptions.statusCancelled,
  };
}
