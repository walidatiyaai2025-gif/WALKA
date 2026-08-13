import 'package:flutter/material.dart';

import '../domain/walka_remote_media.dart';
import '../walka_remote_media_state.dart';
import 'walka_verified_remote_media_image.dart';

class WalkaResolvedSurfaceMedia extends StatelessWidget {
  const WalkaResolvedSurfaceMedia({
    required this.slotKey,
    required this.fallback,
    required this.semanticContext,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.cacheHeight,
    super.key,
  });

  final String slotKey;
  final Widget fallback;
  final String semanticContext;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    if (!walkaSupportedRemoteMediaSlots.containsKey(slotKey)) return fallback;
    final WalkaRemoteMediaItem? item =
        WalkaRemoteMediaScope.maybeOf(context)?.firstForSlot(slotKey);
    if (item == null) return fallback;

    return WalkaVerifiedRemoteMediaImage(
      item: item,
      fallback: fallback,
      fit: fit,
      alignment: alignment,
      semanticContext: semanticContext,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }
}
