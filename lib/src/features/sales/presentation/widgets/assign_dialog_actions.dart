import 'package:flutter/material.dart';

/// Compact Cancel / Skip / primary actions for assign dialogs.
///
/// On narrow screens the primary button is full-width with secondary actions
/// below, avoiding AlertDialog overflow stacking and empty vertical gaps.
class AssignDialogActions extends StatelessWidget {
  const AssignDialogActions({
    super.key,
    required this.isSaving,
    required this.showSkip,
    required this.primaryLabel,
    required this.compact,
    required this.onCancel,
    required this.onSkip,
    required this.onPrimary,
  });

  final bool isSaving;
  final bool showSkip;
  final String primaryLabel;
  final bool compact;
  final VoidCallback onCancel;
  final VoidCallback onSkip;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final primary = FilledButton(
      onPressed: isSaving ? null : onPrimary,
      child: isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(primaryLabel),
    );

    final secondary = [
      TextButton(
        onPressed: isSaving ? null : onCancel,
        child: const Text('Cancel'),
      ),
      if (showSkip)
        TextButton(
          onPressed: isSaving ? null : onSkip,
          child: const Text('Skip'),
        ),
    ];

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          const SizedBox(height: 4),
          Row(children: secondary),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ...secondary,
        const SizedBox(width: 8),
        primary,
      ],
    );
  }
}
