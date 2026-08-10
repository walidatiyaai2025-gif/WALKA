import 'package:flutter/material.dart';

import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaCategoryCard extends StatelessWidget {
  const WalkaCategoryCard({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.primaryColor,
    required this.surface,
    required this.badge,
    required this.onTap,
    super.key,
    this.variantId,
  });

  final String? variantId;
  final String title;
  final String subtitle;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color surface;
  final String badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget visual = variantId == null
        ? WalkaProductVisual(
            kind: kind,
            primaryColor: primaryColor,
            backgroundColor: surface,
            compact: true,
            semanticLabel: '$title category visual',
          )
        : WalkaResolvedProductMedia(
            variantId: variantId!,
            kind: kind,
            primaryColor: primaryColor,
            backgroundColor: surface,
            compact: true,
            semanticLabel: '$title category visual',
          );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: WalkaColors.line),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: WalkaColors.navy.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 132,
                width: double.infinity,
                child: ColoredBox(
                  color: surface,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: visual,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 10, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 13.5,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            badge.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: WalkaColors.gold,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: WalkaColors.gold,
                          size: 22,
                        ),
                      ],
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
