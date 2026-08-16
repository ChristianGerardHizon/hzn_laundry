import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../domain/customer.dart';
import '../controllers/customers_controller.dart';

/// Shows a dialog to transfer [customer] to another branch.
///
/// Returns `true` if the transfer succeeded.
Future<bool?> showCustomerTransferBranchDialog(
  BuildContext context, {
  required Customer customer,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => CustomerTransferBranchDialog(customer: customer),
  );
}

/// Dialog for transferring a customer to another branch.
class CustomerTransferBranchDialog extends HookConsumerWidget {
  const CustomerTransferBranchDialog({
    super.key,
    required this.customer,
  });

  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final branchesAsync = ref.watch(branchesControllerProvider);
    final t = Translations.of(context);

    Future<void> handleTransfer() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final branchId = formKey.currentState!.value['branchId'] as String?;
      if (branchId == null || branchId.isEmpty) return;

      isSaving.value = true;
      final success = await ref
          .read(customersControllerProvider.notifier)
          .transferBranch(customer, branchId);
      isSaving.value = false;

      if (!context.mounted) return;

      if (success) {
        context.pop(true);
      } else {
        showFormErrorDialog(
          context,
          errors: ['Failed to transfer customer. Please try again.'],
        );
      }
    }

    return branchesAsync.when(
      data: (branches) {
        final currentBranch = _branchNamed(branches, customer.branchId);
        final destinations =
            branches.where((b) => b.id != customer.branchId).toList();

        return AlertDialog(
          title: const Text('Transfer Branch'),
          content: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Move ${customer.name} to another branch. '
                  'They will appear in that branch\'s customer list.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Current branch: ${currentBranch?.name ?? 'Unassigned'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (destinations.isEmpty)
                  const Text('No other branches are available.')
                else
                  FormBuilderDropdown<String>(
                    name: 'branchId',
                    decoration: const InputDecoration(
                      labelText: 'Destination branch *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.swap_horiz),
                    ),
                    validator: FormBuilderValidators.required(
                      errorText: 'Select a branch',
                    ),
                    enabled: !isSaving.value,
                    items: destinations
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving.value ? null : () => context.pop(false),
              child: Text(t.common.cancel),
            ),
            FilledButton(
              onPressed: isSaving.value || destinations.isEmpty
                  ? null
                  : handleTransfer,
              child: isSaving.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Transfer'),
            ),
          ],
        );
      },
      loading: () => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => AlertDialog(
        title: const Text('Transfer Branch'),
        content: Text('Failed to load branches: $error'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(t.common.cancel),
          ),
        ],
      ),
    );
  }

  static Branch? _branchNamed(List<Branch> branches, String? branchId) {
    if (branchId == null || branchId.isEmpty) return null;
    for (final branch in branches) {
      if (branch.id == branchId) return branch;
    }
    return null;
  }
}
