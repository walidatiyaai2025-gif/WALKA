import 'package:flutter/material.dart';

import '../../walka_product_visual.dart';
import 'walka_product_media.dart';

abstract final class WalkaProductMediaDecodeBudget {
  static const int home = 1200;
  static const int discovery = 1200;
  static const int pdp = 1600;
  static const int favorites = 1200;
  static const int defaultAsset = 1200;
}

class WalkaProductMediaAsset {
  const WalkaProductMediaAsset({
    required this.variantId,
    required this.assetPath,
    this.cacheWidth = WalkaProductMediaResolver.defaultCacheWidth,
  });

  final String variantId;
  final String assetPath;
  final int cacheWidth;

  String get cacheIdentity => '$variantId::$assetPath@$cacheWidth';
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
    return Image.asset(
      asset.assetPath,
      key: ValueKey<String>(asset.cacheIdentity),
      fit: BoxFit.contain,
      cacheWidth: asset.cacheWidth,
      filterQuality: FilterQuality.medium,
      semanticLabel: semanticLabel,
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
    );
  }
}

/// Stable variant-id -> approved-asset resolver.
///
/// The production registry intentionally owns the only asset naming contract
/// used by feature widgets. Product files can therefore be admitted under the
/// declared Flutter asset directories without teaching each screen a path.
class WalkaProductMediaResolver {
  const WalkaProductMediaResolver({
    this.assetsByVariant = const <String, WalkaProductMediaAsset>{},
  });

  const WalkaProductMediaResolver.production()
      : assetsByVariant = productionAssets;

  static const int defaultCacheWidth =
      WalkaProductMediaDecodeBudget.defaultAsset;

  static const Map<String, WalkaProductMediaAsset> productionAssets =
      <String, WalkaProductMediaAsset>{
    'drawer-organizer:white': WalkaProductMediaAsset(
      variantId: 'drawer-organizer:white',
      assetPath: 'assets/products/drawer/white.png',
    ),
    'drawer-organizer:gray': WalkaProductMediaAsset(
      variantId: 'drawer-organizer:gray',
      assetPath: 'assets/products/drawer/gray.png',
    ),
    'lunch-box:blue': WalkaProductMediaAsset(
      variantId: 'lunch-box:blue',
      assetPath: 'assets/products/lunch/blue.png',
    ),
    'lunch-box:pink': WalkaProductMediaAsset(
      variantId: 'lunch-box:pink',
      assetPath: 'assets/products/lunch/pink.png',
    ),
    'lunch-box:green': WalkaProductMediaAsset(
      variantId: 'lunch-box:green',
      assetPath: 'assets/products/lunch/green.png',
    ),
  };

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

  bool hasApprovedAsset(String variantId) =>
      assetsByVariant.containsKey(variantId);
}

/// Owner-visible product media boundary used by Home, discovery and PDP.
///
/// It prefers the stable production asset path for the catalog variant and
/// preserves the existing CustomPaint renderer as a deterministic fallback.
class WalkaResolvedProductMedia extends StatelessWidget {
  const WalkaResolvedProductMedia({
    required this.variantId,
    required this.kind,
    required this.primaryColor,
    required this.semanticLabel,
    super.key,
    this.backgroundColor = Colors.transparent,
    this.compact = false,
    this.resolver = const WalkaProductMediaResolver.production(),
  });

  final String variantId;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color backgroundColor;
  final bool compact;
  final String semanticLabel;
  final WalkaProductMediaResolver resolver;

  @override
  Widget build(BuildContext context) {
    final WalkaProductMedia fallback = WalkaPaintedProductMedia(
      kind: kind,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      compact: compact,
      semanticLabel: semanticLabel,
    );
    return WalkaProductMediaView(
      media: resolver.resolve(
        variantId: variantId,
        fallback: fallback,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
