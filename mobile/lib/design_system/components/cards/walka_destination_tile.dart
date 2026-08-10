import 'package:flutter/material.dart';

import '../../walka_theme.dart';
import 'walka_surface_card.dart';

/// Shared destination row used by Account, Information and support surfaces.
class WalkaDestinationTile extends StatelessWidget {
  const WalkaDestinationTile({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.semanticLabel,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final String label = semanticLabel ??
        (subtitle == null || subtitle!.isEmpty ? title : '$title. $subtitle');

    return Semantics(
      container: true,
      button: onTap != null,
      enabled: onTap != null,
      label: label,
      child: ExcludeSemantics(
        child: WalkaSurfaceCard(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(
            horizontal: WalkaSpacing.md,
            vertical: WalkaSpacing.sm,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: WalkaColors.gold.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(WalkaRadius.sm),
                  ),
                  child: Icon(icon, color: WalkaColors.navy, size: 21),
                ),
                const SizedBox(width: WalkaSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: WalkaType.cardTitle.copyWith(fontSize: 17)),
                      if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: WalkaSpacing.xxs),
                        Text(subtitle!, style: WalkaType.caption),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: WalkaSpacing.xs),
                trailing ??
                    (onTap == null
                        ? const SizedBox.shrink()
                        : const Icon(
                            Icons.chevron_right_rounded,
                            color: WalkaColors.muted,
                          )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
