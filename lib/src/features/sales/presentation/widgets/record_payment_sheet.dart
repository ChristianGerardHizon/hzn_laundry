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
    final selectedPaymentType = useState(
      existingPayment?.type ?? PaymentType.payment,
    );
    final proofImage = useState<XFile?>(null);
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
      final paymentMethod = values['paymentMethod'] as PaymentMethod;
      final paymentType = values['paymentType'] as PaymentType;
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

    // Check if reference field should be shown (only for GCash/Bank)
    final showReferenceField = selectedPaymentType.value == PaymentType.deposit;
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
                    // Balance due info
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Balance Due:',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              currencyFormat.format(effectiveBalanceDue),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
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
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
                        prefixText: '₱ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.min(0.01,
                            errorText: 'Amount must be greater than 0'),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Payment type
                    FormBuilderChoiceChips<PaymentType>(
                      name: 'paymentType',
                      initialValue:
                          existingPayment?.type ?? PaymentType.payment,
                      decoration: const InputDecoration(
                        labelText: 'Payment Type',
                        border: InputBorder.none,
                      ),
                      spacing: 8,
                      options: PaymentType.values
                          .map((type) => FormBuilderChipOption(
                                value: type,
                                child: Text(type.displayName),
                              ))
                          .toList(),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedPaymentType.value = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Payment method
                    FormBuilderDropdown<PaymentMethod>(
                      name: 'paymentMethod',
                      initialValue:
                          existingPayment?.paymentMethod ?? PaymentMethod.cash,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method *',
                        border: OutlineInputBorder(),
                      ),
                      items: PaymentMethod.values
                          .map((method) => DropdownMenuItem(
                                value: method,
                                child: Text(method.displayName),
                              ))
                          .toList(),
                      validator: FormBuilderValidators.required(),
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

                    // Proof of payment
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
