import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../texts.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ShoppingListStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = switch (status) {
      ShoppingListStatus.preparing => colors.surfaceContainerHighest,
      ShoppingListStatus.ready => colors.secondaryContainer,
      ShoppingListStatus.shopping => colors.primaryContainer,
      ShoppingListStatus.completed => colors.tertiaryContainer,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(statusLabel(status), style: const TextStyle(fontSize: 12)),
    );
  }
}
