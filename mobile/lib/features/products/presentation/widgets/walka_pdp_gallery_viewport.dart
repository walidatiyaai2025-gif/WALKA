import 'package:flutter/material.dart';

import '../../../../design_system/components/media/walka_product_media_resolver.dart';
import '../../../../design_system/walka_product_visual.dart';
import '../../../../design_system/walka_theme.dart';

/// Shared WALKA Product Detail gallery viewport.
///
/// Controller and selection ownership remain caller-owned so the indicator and
/// fullscreen viewer stay independent. Only the primary page may present the
/// canonical production asset. Secondary pages remain deterministic
/// illustrations until separately approved secondary photography exists.
class WalkaPdpGalleryViewport extends StatelessWidget {
  const WalkaPdpGalleryViewport({
    required this.controller,
    required this.selectedIndex,
    required this.variantId,
    required this.kind,
    required this.primaryColor,
    required this.surface,
    required this.semanticLabel,
    required this.onPageChanged,
    required this.onExpand,
    super.key,
  });

  final PageController controller;
  final int selectedIndex;
  final String variantId;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color surface;
  final String semanticLabel;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onExpand;

  static const int pageCount = 3;
  static const double aspectRatio = 1.02;
  static const double radius = 18;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            PageView.builder(
              key: const ValueKey<String>('walka-pdp-gallery-page-view'),
              controller: controller,
              itemCount: pageCount,
              onPageChanged: onPageChanged,
              itemBuilder: (BuildContext context, int index) {
                final Widget media = index == 0
                    ? WalkaResolvedProductMedia(
                        variantId: variantId,
                        kind: kind,
                        primaryColor: primaryColor,
                        backgroundColor: surface,
                        semanticLabel: '$semanticLabel primary product image',
                      )
                    : WalkaProductVisual(
                        kind: kind,
                        primaryColor: primaryColor,
                        backgroundColor: surface,
                        compact: true,
                        semanticLabel:
                            '$semanticLabel illustrative fallback view ${index + 1}; approved secondary product photography pending',
                      );

                return InkWell(
                  key: ValueKey<String>('walka-pdp-gallery-page-$index'),
                  onTap: () => onExpand(index),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(index == 0 ? 22 : 30),
                      child: Transform.rotate(
                        angle: index == 1 ? -0.035 : 0,
                        child: Transform.scale(
                          scale: index == 2 ? 0.90 : 1,
                          child: media,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Material(
                color: Colors.white.withValues(alpha: 0.94),
                shape: const CircleBorder(),
                child: IconButton(
                  key: const ValueKey<String>('walka-pdp-gallery-fullscreen'),
                  onPressed: () => onExpand(selectedIndex),
                  tooltip: 'View fullscreen',
                  icon: const Icon(
                    Icons.fullscreen_rounded,
                    color: WalkaColors.navy,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 13,
              bottom: 12,
              child: Container(
                key: const ValueKey<String>('walka-pdp-gallery-count'),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${selectedIndex + 1} / $pageCount',
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
