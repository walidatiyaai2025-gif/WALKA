import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaSearchEmptyState extends StatelessWidget {
  const WalkaSearchEmptyState({required this.onReset, super.key});

  final VoidCallback onReset;

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
          const Text(
            'No WALKA pieces found',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: WalkaColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Try another color, collection or verified product detail.',
            textAlign: TextAlign.center,
            style: TextStyle(
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
