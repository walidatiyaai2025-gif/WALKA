import 'package:flutter/material.dart';

import '../../../../design_system/walka_theme.dart';

class WalkaPdpActionRow extends StatelessWidget {
  const WalkaPdpActionRow({
    required this.onShare,
    required this.onFavorite,
    required this.isFavorite,
    super.key,
  });

  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Row(
      key: const ValueKey<String>('walka-pdp-actions'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          key: const ValueKey<String>('walka-pdp-share'),
          onPressed: onShare,
          tooltip: 'Share product',
          icon: const Icon(Icons.ios_share_rounded, color: WalkaColors.navy),
        ),
        IconButton(
          key: const ValueKey<String>('walka-pdp-favorite'),
          onPressed: onFavorite,
          tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
          icon: AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey<bool>(isFavorite),
              color: isFavorite ? WalkaColors.gold : WalkaColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}
