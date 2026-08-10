import 'package:flutter/material.dart';

import 'package:walka/design_system/components/cards/walka_surface_card.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaAboutValueCard extends StatelessWidget {
  const WalkaAboutValueCard({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return WalkaSurfaceCard(
      surfaceColor: WalkaColors.navy,
      borderColor: WalkaColors.navy,
      padding: const EdgeInsets.all(16),
      child: Semantics(
        container: true,
        label: '$title. $body',
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: WalkaColors.gold, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        color: Color(0xFFB9C8D6),
                        fontSize: 10.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
