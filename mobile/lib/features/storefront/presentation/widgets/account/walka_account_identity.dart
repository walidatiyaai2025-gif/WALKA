import 'package:flutter/material.dart';

import 'package:walka/design_system/components/cards/walka_surface_card.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaAccountIdentity extends StatelessWidget {
  const WalkaAccountIdentity({super.key});

  @override
  Widget build(BuildContext context) {
    return WalkaSurfaceCard(
      key: const ValueKey<String>('reference-account-identity'),
      padding: const EdgeInsets.all(18),
      radius: 22,
      child: Row(
        children: <Widget>[
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF063A70), WalkaColors.navyDark],
              ),
            ),
            child: const Text(
              'W',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'serif',
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your WALKA Space',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontFamily: 'serif',
                    fontSize: 22,
                    height: 1.08,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'No account or sign-in is required.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Favorites stay on this device.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: WalkaColors.gold),
        ],
      ),
    );
  }
}

class WalkaAccountDestinationNotice extends StatelessWidget {
  const WalkaAccountDestinationNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-account-notice'),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFF9EE), Color(0xFFFFFCF7)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.20)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.verified_outlined, color: WalkaColors.gold, size: 27),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Official WALKA destinations',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Discover here. Purchase continues on the official Amazon listing.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
