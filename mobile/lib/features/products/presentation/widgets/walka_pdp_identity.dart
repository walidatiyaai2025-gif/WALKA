import 'package:flutter/material.dart';

import '../../../../design_system/walka_theme.dart';

class WalkaPdpIdentity extends StatelessWidget {
  const WalkaPdpIdentity({
    required this.eyebrow,
    required this.title,
    required this.facts,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String facts;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<String>('walka-pdp-identity'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(eyebrow, style: WalkaType.eyebrow),
        const SizedBox(height: 7),
        Text(
          title,
          key: const ValueKey<String>('reference-pdp-title'),
          style: const TextStyle(
            fontFamily: 'serif',
            color: WalkaColors.navy,
            fontSize: 30,
            height: 1.04,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          facts,
          style: const TextStyle(
            color: WalkaColors.muted,
            fontSize: 12.5,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
