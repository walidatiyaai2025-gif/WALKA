import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaSearchEmptyState extends StatelessWidget {
  const WalkaSearchEmptyState({
    required this.onReset,
    this.title = 'No WALKA pieces found',
    this.body = 'Try another color, collection or verified product detail.',
    super.key,
  });

  final VoidCallback onReset;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.search_off_rounded, color: WalkaColors.gold, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: WalkaColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: WalkaColors.muted,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            key: const ValueKey<String>('premium-discovery-reset'),
            onPressed: onReset,
            child: const Text('RESET SEARCH'),
          ),
        ],
      ),
    );
  }
}
