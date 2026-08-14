import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaAboutClosing extends StatelessWidget {
  const WalkaAboutClosing({
    this.eyebrow = 'WALKA',
    this.title = 'Thoughtful pieces for a better organized everyday.',
    this.body =
        'Explore the current collection in the app. When you are ready to purchase, WALKA sends you to the official Amazon listing.',
    super.key,
  });

  final String eyebrow;
  final String title;
  final String body;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(eyebrow, style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          Text(title, style: WalkaType.sectionTitle),
          const SizedBox(height: 10),
          Text(body, style: WalkaType.body),
        ],
      ),
    );
  }
}
