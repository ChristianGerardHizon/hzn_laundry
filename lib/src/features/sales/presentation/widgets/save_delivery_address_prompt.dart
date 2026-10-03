import 'package:flutter/material.dart';

/// What staff chose when asked whether to save a newly typed address.
enum SaveAddressChoice { saveAsDefault, save, skip, cancel }

/// Asks whether a delivery address typed for an order should be saved to the
/// customer, optionally as their default delivery location.
///
/// [hasSavedAddresses] false means this would be the customer's first address,
/// which the server makes the default regardless.
///
/// No snackbars are shown here, so the ScaffoldMessenger wrapper is skipped.
Future<SaveAddressChoice> showSaveDeliveryAddressPrompt(
  BuildContext context, {
  required String customerName,
  required String address,
  required bool hasSavedAddresses,
}) async {
  final result = await showDialog<SaveAddressChoice>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Save this address?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(address, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Text(
            hasSavedAddresses
                ? 'Save it for $customerName so it can be picked next time. '
                    'You can also make it their default delivery location.'
                : 'This is $customerName\'s first delivery address, so it '
                    'will be saved as their default delivery location.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(SaveAddressChoice.cancel),
          child: const Text('Back'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(SaveAddressChoice.skip),
          child: const Text("Don't save"),
        ),
        if (hasSavedAddresses)
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(SaveAddressChoice.save),
            child: const Text('Save'),
          ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(SaveAddressChoice.saveAsDefault),
          child: Text(hasSavedAddresses ? 'Save as default' : 'Save address'),
        ),
      ],
    ),
  );
  return result ?? SaveAddressChoice.cancel;
}
