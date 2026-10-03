import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Result of [showDeliveryPhotoPrompt].
typedef DeliveryPhotoResult = ({bool proceed, XFile? photo});

/// Asks staff for an optional proof-of-delivery photo before a delivery order
/// is marked fulfilled. The photo is attached to the "delivered" email.
///
/// Returns `proceed: false` when cancelled. Skipping the photo is allowed.
// No snackbars are shown here, so the ScaffoldMessenger wrapper is skipped.
Future<DeliveryPhotoResult> showDeliveryPhotoPrompt(
  BuildContext context,
) async {
  final result = await showDialog<DeliveryPhotoResult>(
    context: context,
    builder: (_) => const _DeliveryPhotoDialog(),
  );
  return result ?? (proceed: false, photo: null);
}

class _DeliveryPhotoDialog extends HookConsumerWidget {
  const _DeliveryPhotoDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picker = useMemoized(() => ImagePicker());
    final photo = useState<XFile?>(null);

    Future<void> pick(ImageSource source) async {
      try {
        final picked = await picker.pickImage(
          source: source,
          maxWidth: 1280,
          maxHeight: 1280,
          imageQuality: 80,
        );
        if (picked != null) photo.value = picked;
      } catch (_) {
        // Camera/gallery unavailable (e.g. desktop): photo is optional.
      }
    }

    return AlertDialog(
      title: const Text('Mark as fulfilled'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optionally attach a photo of the delivered order. It is sent to '
            'the customer in the delivery email.',
          ),
          const SizedBox(height: 16),
          if (photo.value != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.image_outlined),
              title: Text(photo.value!.name, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                tooltip: 'Remove photo',
                icon: const Icon(Icons.close),
                onPressed: () => photo.value = null,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Take photo'),
                ),
                OutlinedButton.icon(
                  onPressed: () => pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose photo'),
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop((proceed: false, photo: null)),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop((proceed: true, photo: photo.value)),
          child: Text(photo.value == null ? 'Skip photo' : 'Mark fulfilled'),
        ),
      ],
    );
  }
}
