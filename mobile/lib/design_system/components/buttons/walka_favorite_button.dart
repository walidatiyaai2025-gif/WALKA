import 'package:flutter/material.dart';

import '../../walka_motion.dart';
import '../../walka_theme.dart';

/// Shared favorite heart action for WALKA presentation surfaces.
///
/// Persistence and product state stay feature-owned. This atom owns only the
/// visual state, tooltip/semantics and WALKA motion contract.
class WalkaFavoriteButton extends StatelessWidget {
  const WalkaFavoriteButton({
    required this.isFavorite,
    required this.onPressed,
    super.key,
    this.addTooltip = 'Add favorite',
    this.removeTooltip = 'Remove favorite',
    this.selectedColor = WalkaColors.gold,
    this.unselectedColor = WalkaColors.navy,
  });

  final bool isFavorite;
  final VoidCallback? onPressed;
  final String addTooltip;
  final String removeTooltip;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final String tooltip = isFavorite ? removeTooltip : addTooltip;
    final Color color = enabled
        ? (isFavorite ? selectedColor : unselectedColor)
        : WalkaColors.muted;

    return Semantics(
      container: true,
      button: true,
      toggled: isFavorite,
      enabled: enabled,
      label: tooltip,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: AnimatedSwitcher(
            duration: WalkaMotion.duration(context, WalkaMotion.standard),
            switchInCurve: WalkaMotion.standardCurve,
            switchOutCurve: WalkaMotion.standardCurve,
            child: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              key: ValueKey<bool>(isFavorite),
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
