import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../users/presentation/controllers/user_provider.dart';

/// Shows "Voided by {name}" for a voided sale or payment row.
class VoidedByLabel extends ConsumerWidget {
  const VoidedByLabel({
    super.key,
    required this.voidedById,
    this.compact = false,
  });

  final String? voidedById;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (voidedById == null || voidedById!.isEmpty) {
      return const SizedBox.shrink();
    }

    final userAsync = ref.watch(userProvider(voidedById!));
    final name = userAsync.value?.name ?? '…';

    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    final style = theme.textTheme.bodySmall?.copyWith(
      color: color,
      fontWeight: FontWeight.w500,
      fontSize: compact ? 12 : null,
    );

    // Compact (list rows): the "Voided" chip already states the status, so
    // only show who did it.
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'by $name',
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      'Voided by $name',
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
