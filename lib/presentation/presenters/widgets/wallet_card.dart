import 'package:flutter/material.dart';

import '../../../core/helpers/formatters.dart';

class WalletCard extends StatelessWidget {
  final String title;
  final List<MapEntry<String, double>> rows;

  const WalletCard({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...rows.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${e.key}: ${formatPrice(e.value)}'),
            )),
          ],
        ),
      ),
    );
  }
}
