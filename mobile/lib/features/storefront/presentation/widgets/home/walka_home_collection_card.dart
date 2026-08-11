import 'package:flutter/material.dart';

import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaHomeCollectionCard extends StatelessWidget {
  const WalkaHomeCollectionCard({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.primaryColor,
    required this.visualBackground,
    required this.semanticLabel,
    required this.onTap,
    super.key,
    this.variantId,
  });

  final String? variantId;
  final String title;
  final String subtitle;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color visualBackground;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.textScalerOf(context).scale(1);
    final double bodyMinHeight = scale > 1.15 ? 138 : 116;
    final Widget visual = variantId == null
        ? WalkaProductVisual(
            kind: kind,
            primaryColor: primaryColor,
            backgroundColor: visualBackground,
            compact: true,
            semanticLabel: semanticLabel,
          )
        : WalkaResolvedProductMedia(
            variantId: variantId!,
            kind: kind,
            primaryColor: primaryColor,
            backgroundColor: visualBackground,
            compact: true,
            mediaSurface: WalkaProductMediaSurface.home,
            semanticLabel: semanticLabel,
          );

    return SizedBox(
      width: 238,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: WalkaColors.line),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 174,
                  width: double.infinity,
                  child: ColoredBox(
                    color: visualBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: visual,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: bodyMinHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 13, 13, 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: WalkaColors.navy,
                                  fontSize: 15,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: WalkaColors.muted,
                                  fontSize: 10.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: WalkaColors.gold,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
