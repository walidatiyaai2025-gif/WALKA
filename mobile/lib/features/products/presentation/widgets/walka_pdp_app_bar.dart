import 'package:flutter/material.dart';

import '../../../../design_system/walka_shell.dart';
import '../../../../design_system/walka_theme.dart';
import 'walka_pdp_action_row.dart';

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
        WalkaPdpActionRow(
          onShare: onShare,
          onFavorite: onFavorite,
          isFavorite: isFavorite,
        ),
        const SizedBox(width: trailingInset),
      ],
      shape: const Border(
        bottom: BorderSide(color: WalkaColors.line, width: dividerWidth),
      ),
    );
  }
}
