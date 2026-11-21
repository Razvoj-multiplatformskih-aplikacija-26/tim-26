import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';

import '../texts.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.onRetry, this.notice});

  final VoidCallback onRetry;
  final Notice? notice;

  @override
  Widget build(BuildContext context) {
    final unreachable = notice == Notice.unreachable;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(unreachable ? Icons.cloud_off : Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              notice == null
                  ? 'Došlo je do greške pri učitavanju.'
                  : noticeMessage(notice!),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Pokušaj ponovo')),
          ],
        ),
      ),
    );
  }
}
