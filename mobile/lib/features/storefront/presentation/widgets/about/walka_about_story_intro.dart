import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaAboutStoryIntro extends StatelessWidget {
  const WalkaAboutStoryIntro({
    this.eyebrow = 'OUR POINT OF VIEW',
    this.title = 'A calmer home begins with thoughtful details.',
    this.body =
        'WALKA creates organization essentials that balance practical function with a refined visual language. We believe useful objects should make everyday spaces easier to live with and quieter to look at.',
    super.key,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(eyebrow, style: WalkaType.eyebrow),
        const SizedBox(height: 9),
        Text(title, style: WalkaType.sectionTitle),
        const SizedBox(height: 13),
        Text(body, style: WalkaType.body),
      ],
    );
  }
}
