import 'package:flutter/material.dart';

import '../../../../design_system/walka_theme.dart';

class WalkaPdpEditorialPanel extends StatelessWidget {
  const WalkaPdpEditorialPanel({
    required this.title,
    required this.body,
    super.key,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'DESIGNED FOR EVERYDAY ORDER',
            style: TextStyle(
              color: WalkaColors.gold,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'serif',
              fontSize: 22,
              height: 1.08,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFD6E0E8),
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
