import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/org_selection.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../domain/subscription_payment_status.dart';
import '../../domain/subscription_status.dart';
import '../controllers/organization_pay_info_provider.dart';
import '../controllers/organization_subscription_provider.dart';

const _kBrandTeal = Color(0xFF45A9AB);

/// Pay screen for org admins (QRPH + proof upload).
class SubscriptionPayPage extends HookConsumerWidget {
  const SubscriptionPayPage({super.key, required this.organizationId});

  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final payAsync = ref.watch(organizationPayInfoProvider(organizationId));
    final isSubmitting = useState(false);
    final noteController = useTextEditingController();
    final proofBytes = useState<Uint8List?>(null);
    final proofName = useState<String?>(null);
    final currency = useMemoized(
      () => NumberFormat.currency(symbol: '₱', decimalDigits: 2),
    );

    Future<void> pickProof() async {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      proofBytes.value = await file.readAsBytes();
      proofName.value = file.name;
    }

    Future<void> submit() async {
      final bytes = proofBytes.value;
      if (bytes == null) {
        showErrorSnackBar(
          context,
          message: t.subscriptions.uploadProof,
          useRootMessenger: false,
        );
        return;
      }
      if (isSubmitting.value) return;
      isSubmitting.value = true;
      try {
        final result =
            await ref.read(subscriptionRepositoryProvider).submitPayment(
                  organizationId,
                  note: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                  proofImage: http.MultipartFile.fromBytes(
                    'proofImage',
                    bytes,
                    filename: proofName.value ?? 'proof.jpg',
                  ),
                );
        if (!context.mounted) return;
        result.fold(
          (f) => showErrorSnackBar(
            context,
            message: t.subscriptions.proofSubmitFailed,
            useRootMessenger: false,
          ),
          (_) {
            showSuccessSnackBar(
              context,
              message: t.subscriptions.proofSubmitted,
              useRootMessenger: false,
            );
            proofBytes.value = null;
            proofName.value = null;
            noteController.clear();
            ref.invalidate(organizationPayInfoProvider(organizationId));
            ref.invalidate(organizationSubscriptionProvider(organizationId));
          },
        );
      } finally {
        if (context.mounted) isSubmitting.value = false;
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(t.subscriptions.payTitle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    const SelectOrganizationRoute().go(context);
                  }
                },
              ),
            ),
            body: payAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: ErrorState.fromError(
                  e,
                  onRetry: () => ref
                      .invalidate(organizationPayInfoProvider(organizationId)),
                ),
              ),
              data: (info) {
                final sub = info.subscription;
                final latest = info.latestPayment;
                final locked = sub?.isEffectivelyLocked == true;
                final settings = info.settings;

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (locked) ...[
                      Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.subscriptions.lockedTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.red.shade800,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(t.subscriptions.lockedMessage),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      info.organizationName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(t.subscriptions.paySubtitle),
                    const SizedBox(height: 20),
                    if (sub == null)
                      Text(t.subscriptions.noActiveSubscription)
                    else ...[
                      _InfoRow(
                        label: t.subscriptions.packageName,
                        value: sub.packageName,
                      ),
                      _InfoRow(
                        label: t.subscriptions.amount,
                        value: currency.format(sub.price),
                      ),
                      _InfoRow(
                        label: t.subscriptions.periodEnds,
                        value: DateFormat.yMMMd().format(sub.periodEnd),
                      ),
                      _InfoRow(
                        label: t.subscriptions.subscription,
                        value: _statusLabel(t, sub.status),
                      ),
                      const SizedBox(height: 16),
                      if (settings.payeeName.isNotEmpty)
                        _InfoRow(
                          label: t.subscriptions.payeeName,
                          value: settings.payeeName,
                        ),
                      if (settings.instructions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          settings.instructions,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (settings.qrphImageUrl != null &&
                          settings.qrphImageUrl!.isNotEmpty)
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: Image.network(
                              settings.qrphImageUrl!,
                              key: ValueKey(settings.qrphImageUrl),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 48,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t.subscriptions.qrphImage,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Text(
                          t.subscriptions.qrphImage,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      const SizedBox(height: 24),
                      if (latest?.status == SubscriptionPaymentStatus.pending)
                        Card(
                          color: Colors.amber.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(t.subscriptions.proofPending),
                          ),
                        )
                      else ...[
                        if (latest?.status ==
                            SubscriptionPaymentStatus.rejected) ...[
                          Card(
                            color: Colors.orange.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                latest?.adminNote?.isNotEmpty == true
                                    ? '${t.subscriptions.proofRejected} ${latest!.adminNote}'
                                    : t.subscriptions.proofRejected,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: noteController,
                          decoration: InputDecoration(
                            labelText: 'Note',
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: isSubmitting.value ? null : pickProof,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(
                            proofName.value ?? t.subscriptions.uploadProof,
                          ),
                        ),
                        if (proofBytes.value != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              proofBytes.value!,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: isSubmitting.value ? null : submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: _kBrandTeal,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: isSubmitting.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(t.subscriptions.submitProof),
                        ),
                      ],
                    ],
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(Translations t, SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return t.subscriptions.statusActive;
      case SubscriptionStatus.grace:
        return t.subscriptions.statusGrace;
      case SubscriptionStatus.locked:
        return t.subscriptions.statusLocked;
      case SubscriptionStatus.cancelled:
        return t.subscriptions.statusCancelled;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
