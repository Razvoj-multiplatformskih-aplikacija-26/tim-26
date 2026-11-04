import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../texts.dart';

class PriceDetailPanel extends StatelessWidget {
  const PriceDetailPanel({
    super.key,
    required this.entry,
    required this.onApprove,
    required this.onReject,
  });

  final PriceEntry entry;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final canApprove = canChangePriceStatus(entry.status, PriceStatus.approved);
    final canReject = canChangePriceStatus(entry.status, PriceStatus.rejected);
    final stale = isPriceStale(entry, DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.product.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(entry.product.packaging),
          const SizedBox(height: 16),
          _Row(label: 'Prodavnica', value: entry.store.name),
          _Row(label: 'Cena', value: '${entry.price} RSD'),
          _Row(label: 'Status', value: priceStatusLabel(entry.status)),
          _Row(label: 'Ažurirano', value: formatDate(entry.updatedAt)),
          if (stale)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Cena je starija od $maxPriceAgeDays dana.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: canApprove ? onApprove : null,
                child: const Text('Potvrdi'),
              ),
              OutlinedButton(
                onPressed: canReject ? onReject : null,
                child: const Text('Odbij'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}