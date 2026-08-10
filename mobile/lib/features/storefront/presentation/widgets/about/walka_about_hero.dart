import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

import 'walka_about_product_story.dart';

class WalkaAboutHero extends StatelessWidget {
  const WalkaAboutHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-about-hero'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF7F0E5), Color(0xFFFFFCF7)],
        ),
        border: Border.all(color: WalkaColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(22, 24, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('OUR STORY', style: WalkaType.eyebrow),
                SizedBox(height: 9),
                Text(
                  'Organized living.\nElevated everyday.',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontFamily: 'serif',
                    fontSize: 32,
                    height: 1.02,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.45,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Thoughtful organization essentials that make everyday spaces easier to use and calmer to look at.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          WalkaAboutProductStory(),
        ],
      ),
    );
  }
}
