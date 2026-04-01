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
import '../../../pos/domain/payment_method.dart';
import '../../../pos/domain/payment_type.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/presentation/payments_controller.dart';
import '../controllers/sale_provider.dart';

/// Bottom sheet for recording a payment against a sale.
class RecordPaymentSheet extends HookConsumerWidget {
  const RecordPaymentSheet({
    super.key,
    required this.sale,
    required this.balanceDue,
  });

  final Sale sale;
  final num balanceDue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final selectedPaymentType = useState(PaymentType.payment);
    final proofImage = useState<XFile?>(null);
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
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
      final payment = await controller.recordPayment(
        saleId: sale.id,
        amount: amount,
        paymentMethod: paymentMethod,
        type: paymentType,
        paymentRef: paymentRef,
        notes: notes,
        paymentProofFile: proofFile,
      );

      isSaving.value = false;

      if (!context.mounted) return;

      if (payment != null) {
        // Refresh the sale to get updated isPaid status
        ref.invalidate(saleProvider(sale.id));
        Navigator.of(context).pop(true);
        showSuccessSnackBar(context,
            message: 'Payment recorded successfully', useRootMessenger: false);
      } else {
        showErrorSnackBar(context,
            message: 'Failed to record payment', useRootMessenger: false);
      }
    }

    // Check if reference field should be shown (only for GCash/Bank)
    final showReferenceField = selectedPaymentType.value == PaymentType.deposit;

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Record Payment',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Balance due info
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Balance Due:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            currencyFormat.format(balanceDue),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount field
                  FormBuilderTextField(
                    name: 'amount',
                    initialValue: balanceDue.toString(),
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
                    initialValue: PaymentType.payment,
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
                    initialValue: PaymentMethod.cash,
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
                    style: Theme.of(context).textTheme.titleSmall,
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
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Optional notes about this payment',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  FilledButton.icon(
                    onPressed: isSaving.value ? null : handleSave,
                    icon: isSaving.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label:
                        Text(isSaving.value ? 'Saving...' : 'Record Payment'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the record payment sheet and returns true if a payment was recorded.
Future<bool?> showRecordPaymentSheet(
  BuildContext context, {
  required Sale sale,
  required num balanceDue,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => RecordPaymentSheet(
      sale: sale,
      balanceDue: balanceDue,
    ),
  );
}
