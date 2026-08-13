import 'package:flutter/material.dart';

import '../../../../design_system/components/media/walka_product_media_resolver.dart';
import '../../../../design_system/walka_product_visual.dart';
import '../../../../design_system/walka_theme.dart';
import '../../../media/presentation/walka_resolved_product_remote_media.dart';
import '../../../media/walka_remote_media_state.dart';

class WalkaRemotePdpGalleryViewport extends StatelessWidget {
  const WalkaRemotePdpGalleryViewport({
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

  static const int bundledPageCount = 3;

  static int itemCountFor(BuildContext context, String variantId) {
    final int count =
        WalkaRemoteMediaScope.maybeOf(context)?.galleryForVariant(variantId).length ??
            0;
    return count > 0 ? count : bundledPageCount;
  }

  @override
  Widget build(BuildContext context) {
    final int remoteCount =
        WalkaRemoteMediaScope.maybeOf(context)?.galleryForVariant(variantId).length ??
            0;
    final int itemCount = remoteCount > 0 ? remoteCount : bundledPageCount;
    final int safeIndex = selectedIndex.clamp(0, itemCount - 1);

    return AspectRatio(
      aspectRatio: 1.02,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            PageView.builder(
              key: const ValueKey<String>('walka-pdp-gallery-page-view'),
              controller: controller,
              itemCount: itemCount,
              onPageChanged: onPageChanged,
              itemBuilder: (BuildContext context, int index) {
                final Widget fallback = index == 0
                    ? WalkaResolvedProductMedia(
                        variantId: variantId,
                        kind: kind,
                        primaryColor: primaryColor,
                        backgroundColor: surface,
                        mediaSurface: WalkaProductMediaSurface.pdp,
                        semanticLabel: '$semanticLabel primary product image',
                      )
                    : WalkaProductVisual(
                        kind: kind,
                        primaryColor: primaryColor,
                        backgroundColor: surface,
                        compact: true,
                        semanticLabel:
                            '$semanticLabel illustrative fallback view ${index + 1}',
                      );
                final Widget media = remoteCount == 0
                    ? fallback
                    : WalkaResolvedProductRemoteMedia(
                        variantId: variantId,
                        index: index,
                        fallback: fallback,
                        semanticContext:
                            '$semanticLabel gallery image ${index + 1}',
                        cacheWidth: 1600,
                      );

                return InkWell(
                  key: ValueKey<String>('walka-pdp-gallery-page-$index'),
                  onTap: () => onExpand(index),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(index == 0 ? 22 : 30),
                      child: media,
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
                  onPressed: () => onExpand(safeIndex),
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
                  '${safeIndex + 1} / $itemCount',
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
