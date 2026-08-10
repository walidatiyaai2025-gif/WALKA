import 'package:flutter/material.dart';

import 'walka_product_media.dart';

class WalkaProductMediaAsset {
  const WalkaProductMediaAsset({
    required this.variantId,
    required this.assetPath,
    this.cacheWidth = WalkaProductMediaResolver.defaultCacheWidth,
  });

  final String variantId;
  final String assetPath;
  final int cacheWidth;
}

/// Asset-backed product media that always falls back to deterministic WALKA
/// painted media when the bundle cannot load the approved asset.
class WalkaAssetProductMedia implements WalkaProductMedia {
  const WalkaAssetProductMedia({
    required this.asset,
    required this.fallback,
    required this.semanticLabel,
  });

  final WalkaProductMediaAsset asset;
  final WalkaProductMedia fallback;

  @override
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Image.asset(
          asset.assetPath,
          fit: BoxFit.contain,
          cacheWidth: asset.cacheWidth,
          filterQuality: FilterQuality.medium,
          errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) {
            return Semantics(
              image: true,
              label: '$semanticLabel. Product visual fallback.',
              child: ExcludeSemantics(child: fallback.build(context)),
            );
          },
        ),
      ),
    );
  }
}

/// Stable variant-id -> approved-asset resolver.
///
/// The production registry is deliberately empty until MEDIA-002/003 receive
/// approved bundle images. Callers still get a deterministic painted fallback.
class WalkaProductMediaResolver {
  const WalkaProductMediaResolver({
    this.assetsByVariant = const <String, WalkaProductMediaAsset>{},
  });

  static const int defaultCacheWidth = 1200;

  final Map<String, WalkaProductMediaAsset> assetsByVariant;

  WalkaProductMedia resolve({
    required String variantId,
    required WalkaProductMedia fallback,
    String? semanticLabel,
  }) {
    final WalkaProductMediaAsset? asset = assetsByVariant[variantId];
    if (asset == null) return fallback;

    return WalkaAssetProductMedia(
      asset: asset,
      fallback: fallback,
      semanticLabel: semanticLabel ?? fallback.semanticLabel,
    );
  }

  bool hasApprovedAsset(String variantId) => assetsByVariant.containsKey(variantId);
}
