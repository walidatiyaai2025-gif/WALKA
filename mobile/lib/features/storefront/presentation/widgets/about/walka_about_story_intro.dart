import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaAboutStoryIntro extends StatelessWidget {
  const WalkaAboutStoryIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('OUR POINT OF VIEW', style: WalkaType.eyebrow),
        SizedBox(height: 9),
        Text(
          'A calmer home begins with thoughtful details.',
          style: WalkaType.sectionTitle,
        ),
        SizedBox(height: 13),
        Text(
          'WALKA creates organization essentials that balance practical function with a refined visual language. We believe useful objects should make everyday spaces easier to live with and quieter to look at.',
          style: WalkaType.body,
        ),
      ],
    );
  }
}
