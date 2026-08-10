import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaAboutClosing extends StatelessWidget {
  const WalkaAboutClosing({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-about-closing'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.20)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('WALKA', style: WalkaType.eyebrow),
          SizedBox(height: 8),
          Text(
            'Thoughtful pieces for a better organized everyday.',
            style: WalkaType.sectionTitle,
          ),
          SizedBox(height: 10),
          Text(
            'Explore the current collection in the app. When you are ready to purchase, WALKA sends you to the official Amazon listing.',
            style: WalkaType.body,
          ),
        ],
      ),
    );
  }
}
