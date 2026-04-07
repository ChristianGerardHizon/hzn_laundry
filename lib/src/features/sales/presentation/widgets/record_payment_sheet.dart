import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../pos/domain/payment.dart';
import '../../../pos/domain/payment_method.dart';
import '../../../pos/domain/payment_type.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/presentation/payments_controller.dart';
import '../controllers/sale_provider.dart';

/// Dialog for recording or editing a payment against a sale.
class RecordPaymentDialog extends HookConsumerWidget {
  const RecordPaymentDialog({
    super.key,
    required this.sale,
    required this.balanceDue,
    this.existingPayment,
    this.canEditDate = false,
  });

  final Sale sale;
  final num balanceDue;

  /// If provided, the dialog is in edit mode for this payment.
  final Payment? existingPayment;

  /// Whether the user can edit the payment date (admin-only).
  final bool canEditDate;

  bool get isEditing => existingPayment != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final selectedPaymentOption = useState(
      _paymentOptionFromExisting(existingPayment),
    );
    final proofImage = useState<XFile?>(null);
    final enteredAmount = useState<num>(
      isEditing ? existingPayment!.amount : balanceDue,
    );
    final currencyFormat =
        NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final imagePicker = useMemoized(() => ImagePicker());

    Future<void> pickImage() async {
      final picked = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked != null) {
        proofImage.value = picked;
      }
    }

    Future<void> takePhoto() async {
      final picked = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked != null) {
        proofImage.value = picked;
      }
    }

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final values = formKey.currentState!.value;
      final amount = num.tryParse(values['amount']?.toString() ?? '') ?? 0;
      final paymentOption = values['paymentOption'] as _PaymentOption;
      final paymentMethod = paymentOption.toPaymentMethod();
      final paymentType = paymentOption.toPaymentType();
      final paymentRef = values['paymentRef'] as String?;
      final notes = values['notes'] as String?;
      final paymentDate = values['paymentDate'] as DateTime?;

      isSaving.value = true;

      // Prepare file if selected
      http.MultipartFile? proofFile;
      if (proofImage.value != null) {
        final bytes = await proofImage.value!.readAsBytes();
        proofFile = http.MultipartFile.fromBytes(
          'paymentProof',
          bytes,
          filename: proofImage.value!.name,
        );
      }

      final controller = ref.read(paymentsControllerProvider.notifier);
      Payment? payment;

      if (isEditing) {
        payment = await controller.updatePayment(
          id: existingPayment!.id,
          saleId: sale.id,
          amount: amount,
          paymentMethod: paymentMethod,
          type: paymentType,
          paymentRef: paymentRef,
          notes: notes,
          paymentProofFile: proofFile,
          paymentDate: paymentDate,
        );
      } else {
        payment = await controller.recordPayment(
          saleId: sale.id,
          amount: amount,
          paymentMethod: paymentMethod,
          type: paymentType,
          paymentRef: paymentRef,
          notes: notes,
          paymentProofFile: proofFile,
          paymentDate: paymentDate,
        );
      }

      isSaving.value = false;

      if (!context.mounted) return;

      if (payment != null) {
        // Refresh the sale to get updated isPaid status
        ref.invalidate(saleProvider(sale.id));
        Navigator.of(context).pop(true);
        showSuccessSnackBar(context,
            message: isEditing
                ? 'Payment updated successfully'
                : 'Payment recorded successfully',
            useRootMessenger: false);
      } else {
        showErrorSnackBar(context,
            message: isEditing
                ? 'Failed to update payment'
                : 'Failed to record payment',
            useRootMessenger: false);
      }
    }

    // Check if reference field should be shown (for GCash/Bank)
    final showReferenceField =
        selectedPaymentOption.value == _PaymentOption.gcashBank;
    final theme = Theme.of(context);

    // For editing, the effective balance is the balance + existing payment amount
    final effectiveBalanceDue =
        isEditing ? balanceDue + existingPayment!.amount : balanceDue;

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => AlertDialog(
          title: Text(isEditing ? 'Edit Payment' : 'Record Payment'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: FormBuilder(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Payment summary info
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount:',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(sale.totalAmount),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Paid:',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(
                                      sale.totalAmount - effectiveBalanceDue),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Balance Due:',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(effectiveBalanceDue),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment date field (admin-only)
                    if (canEditDate) ...[
                      FormBuilderDateTimePicker(
                        name: 'paymentDate',
                        initialValue:
                            existingPayment?.postedDate ?? DateTime.now(),
                        decoration: const InputDecoration(
                          labelText: 'Payment Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        inputType: InputType.both,
                        format: DateFormat('MMM dd, yyyy hh:mm a'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Amount field
                    FormBuilderTextField(
                      name: 'amount',
                      initialValue: isEditing
                          ? existingPayment!.amount.toString()
                          : effectiveBalanceDue.toString(),
                      decoration: InputDecoration(
                        labelText: 'Amount *',
                        prefixText: '₱ ',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.restart_alt, size: 20),
                          tooltip: 'Reset to balance due',
                          onPressed: () {
                            final initial = isEditing
                                ? existingPayment!.amount.toString()
                                : effectiveBalanceDue.toString();
                            formKey.currentState?.fields['amount']
                                ?.didChange(initial);
                            enteredAmount.value =
                                num.tryParse(initial) ?? 0;
                          },
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        enteredAmount.value =
                            num.tryParse(value ?? '') ?? 0;
                      },
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.min(0.01,
                            errorText: 'Amount must be greater than 0'),
                      ]),
                    ),
                    const SizedBox(height: 8),

                    // Overpayment warning
                    if (enteredAmount.value > effectiveBalanceDue)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 18,
                                color: theme.colorScheme.error),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Amount exceeds balance due by ${currencyFormat.format(enteredAmount.value - effectiveBalanceDue)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Quick amount adjustment buttons
                    Row(
                      children: [
                        _QuickAmountButton(
                          label: '−100',
                          onPressed: () {
                            _adjustAmount(formKey, -100);
                            enteredAmount.value = num.tryParse(
                                  formKey.currentState?.fields['amount']?.value
                                          ?.toString() ??
                                      '',
                                ) ??
                                0;
                          },
                        ),
                        const SizedBox(width: 4),
                        _QuickAmountButton(
                          label: '−10',
                          onPressed: () {
                            _adjustAmount(formKey, -10);
                            enteredAmount.value = num.tryParse(
                                  formKey.currentState?.fields['amount']?.value
                                          ?.toString() ??
                                      '',
                                ) ??
                                0;
                          },
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              final current = num.tryParse(
                                    formKey.currentState?.fields['amount']?.value
                                            ?.toString() ??
                                        '',
                                  ) ??
                                  0;
                              final halved = (current / 2).toStringAsFixed(2);
                              formKey.currentState?.fields['amount']
                                  ?.didChange(halved);
                              enteredAmount.value =
                                  num.tryParse(halved) ?? 0;
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                            child: const Text('½',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        _QuickAmountButton(
                          label: '+10',
                          onPressed: () {
                            _adjustAmount(formKey, 10);
                            enteredAmount.value = num.tryParse(
                                  formKey.currentState?.fields['amount']?.value
                                          ?.toString() ??
                                      '',
                                ) ??
                                0;
                          },
                        ),
                        const SizedBox(width: 4),
                        _QuickAmountButton(
                          label: '+100',
                          onPressed: () {
                            _adjustAmount(formKey, 100);
                            enteredAmount.value = num.tryParse(
                                  formKey.currentState?.fields['amount']?.value
                                          ?.toString() ??
                                      '',
                                ) ??
                                0;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Payment option (combined type + method)
                    FormBuilderChoiceChips<_PaymentOption>(
                      name: 'paymentOption',
                      initialValue: selectedPaymentOption.value,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        border: InputBorder.none,
                      ),
                      spacing: 8,
                      options: _PaymentOption.values
                          .map((option) => FormBuilderChipOption(
                                value: option,
                                child: Text(option.displayName),
                              ))
                          .toList(),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedPaymentOption.value = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Payment reference - only shown for GCash/Bank
                    if (showReferenceField) ...[
                      FormBuilderTextField(
                        name: 'paymentRef',
                        initialValue: existingPayment?.paymentRef,
                        decoration: const InputDecoration(
                          labelText: 'Reference Number',
                          hintText: 'GCash/Bank transaction reference',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Proof of payment - only for GCash/Bank
                    if (showReferenceField) ...[
                      Text(
                        'Proof of Payment',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      if (proofImage.value != null) ...[
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(proofImage.value!.path),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton.filled(
                                onPressed: () => proofImage.value = null,
                                icon: const Icon(Icons.close),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ] else if (isEditing &&
                          existingPayment!.paymentProofUrl != null &&
                          existingPayment!.paymentProofUrl!.isNotEmpty) ...[
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                existingPayment!.paymentProofUrl!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Current proof',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Notes
                    FormBuilderTextField(
                      name: 'notes',
                      initialValue: existingPayment?.notes,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Optional notes about this payment',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  isSaving.value ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: isSaving.value ? null : handleSave,
              icon: isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(isSaving.value
                  ? 'Saving...'
                  : isEditing
                      ? 'Update Payment'
                      : 'Record Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

void _adjustAmount(GlobalKey<FormBuilderState> formKey, num delta) {
  final current = num.tryParse(
        formKey.currentState?.fields['amount']?.value?.toString() ?? '',
      ) ??
      0;
  final adjusted = (current + delta).clamp(0, double.infinity);
  final formatted = adjusted == adjusted.toInt()
      ? adjusted.toInt().toString()
      : adjusted.toStringAsFixed(2);
  formKey.currentState?.fields['amount']?.didChange(formatted);
}

class _QuickAmountButton extends StatelessWidget {
  const _QuickAmountButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

/// Shows the record payment dialog and returns true if a payment was recorded.
Future<bool?> showRecordPaymentDialog(
  BuildContext context, {
  required Sale sale,
  required num balanceDue,
  bool canEditDate = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => RecordPaymentDialog(
      sale: sale,
      balanceDue: balanceDue,
      canEditDate: canEditDate,
    ),
  );
}

/// Shows the edit payment dialog and returns true if the payment was updated.
Future<bool?> showEditPaymentDialog(
  BuildContext context, {
  required Sale sale,
  required num balanceDue,
  required Payment existingPayment,
  bool canEditDate = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => RecordPaymentDialog(
      sale: sale,
      balanceDue: balanceDue,
      existingPayment: existingPayment,
      canEditDate: canEditDate,
    ),
  );
}

/// Combined payment option shown in the record payment dialog.
/// Maps to both [PaymentType] and [PaymentMethod] on save.
enum _PaymentOption {
  cash,
  gcashBank,
  refund;

  String get displayName => switch (this) {
        _PaymentOption.cash => 'Cash',
        _PaymentOption.gcashBank => 'GCash/Bank',
        _PaymentOption.refund => 'Refund',
      };

  PaymentType toPaymentType() => switch (this) {
        _PaymentOption.cash => PaymentType.payment,
        _PaymentOption.gcashBank => PaymentType.deposit,
        _PaymentOption.refund => PaymentType.refund,
      };

  PaymentMethod toPaymentMethod() => switch (this) {
        _PaymentOption.cash => PaymentMethod.cash,
        _PaymentOption.gcashBank => PaymentMethod.gcash,
        _PaymentOption.refund => PaymentMethod.cash,
      };
}

_PaymentOption _paymentOptionFromExisting(Payment? payment) {
  if (payment == null) return _PaymentOption.cash;
  if (payment.type == PaymentType.refund) return _PaymentOption.refund;
  if (payment.type == PaymentType.deposit ||
      payment.paymentMethod == PaymentMethod.gcash ||
      payment.paymentMethod == PaymentMethod.bankTransfer) {
    return _PaymentOption.gcashBank;
  }
  return _PaymentOption.cash;
}
