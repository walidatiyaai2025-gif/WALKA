import 'package:flutter/material.dart';

import '../domain/walka_remote_media.dart';
import '../walka_remote_media_state.dart';
import 'walka_verified_remote_media_image.dart';

/// Prefers one verified CMS-035 product-gallery item and falls back to the
/// existing compiled/bundled visual when remote metadata or bytes are absent.
///
/// The remote source is selected only by stable compiled [variantId] and
/// deterministic gallery [index]; the CMS never supplies a widget or URL.
class WalkaResolvedProductRemoteMedia extends StatelessWidget {
  const WalkaResolvedProductRemoteMedia({
    required this.variantId,
    required this.fallback,
    required this.semanticContext,
    this.index = 0,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.cacheHeight,
    super.key,
  });

  final String variantId;
  final int index;
  final Widget fallback;
  final String semanticContext;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    final WalkaRemoteMediaController? controller =
        WalkaRemoteMediaScope.maybeOf(context);
    if (controller == null || index < 0) return fallback;

    final List<WalkaRemoteMediaItem> gallery =
        controller.galleryForVariant(variantId);
    if (index >= gallery.length) return fallback;

    return WalkaVerifiedRemoteMediaImage(
      item: gallery[index],
      fallback: fallback,
      fit: fit,
      alignment: alignment,
      semanticContext: semanticContext,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }
}
