import 'package:flutter/material.dart';

import '../../../../design_system/walka_shell.dart';
import '../../../../design_system/walka_theme.dart';

/// Shared WALKA Product Detail app/header bar.
///
/// The widget owns only the released PDP chrome. Route back behavior remains
/// AppBar-owned, while share/favorite business callbacks stay feature-owned.
class WalkaPdpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WalkaPdpAppBar({
    required this.onShare,
    required this.onFavorite,
    required this.isFavorite,
    super.key,
  });

  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final bool isFavorite;

  static const Duration favoriteSwitchDuration = Duration(milliseconds: 180);
  static const double trailingInset = 4;
  static const double dividerWidth = 0.7;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: const WalkaWordmark(compact: true, showDescriptor: false),
      actions: <Widget>[
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
            duration: favoriteSwitchDuration,
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey<bool>(isFavorite),
              color: isFavorite ? WalkaColors.gold : WalkaColors.navy,
            ),
          ),
        ),
        const SizedBox(width: trailingInset),
      ],
      shape: const Border(
        bottom: BorderSide(color: WalkaColors.line, width: dividerWidth),
      ),
    );
  }
}
