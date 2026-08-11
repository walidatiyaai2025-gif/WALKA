import 'dart:async';

import 'package:flutter/material.dart';

import '../../walka_product_visual.dart';
import 'walka_product_media.dart';
import 'walka_product_media_admission.dart';

enum WalkaProductMediaSurface {
  home,
  discovery,
  pdp,
  favorites,
  about,
  generic,
}

enum WalkaProductMediaLoadState {
  loading,
  loaded,
  fallback,
}

enum WalkaProductMediaPrefetchState {
  prefetched,
  skipped,
  failed,
}

typedef WalkaProductMediaLoadCallback = void Function(
  WalkaProductMediaLoadEvent event,
);

@immutable
class WalkaProductMediaLoadEvent {
  const WalkaProductMediaLoadEvent({
    required this.variantId,
    required this.assetPath,
    required this.surface,
    required this.state,
  });

  final String variantId;
  final String assetPath;
  final WalkaProductMediaSurface surface;
  final WalkaProductMediaLoadState state;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WalkaProductMediaLoadEvent &&
            other.variantId == variantId &&
            other.assetPath == assetPath &&
            other.surface == surface &&
            other.state == state;
  }

  @override
  int get hashCode => Object.hash(variantId, assetPath, surface, state);
}

@immutable
class WalkaProductMediaPrefetchResult {
  const WalkaProductMediaPrefetchResult({
    required this.variantId,
    required this.surface,
    required this.state,
    this.assetPath,
    this.skipReason,
  });

  final String variantId;
  final String? assetPath;
  final WalkaProductMediaSurface surface;
  final WalkaProductMediaPrefetchState state;
  final String? skipReason;

  bool get prefetched => state == WalkaProductMediaPrefetchState.prefetched;
  bool get skipped => state == WalkaProductMediaPrefetchState.skipped;
  bool get failed => state == WalkaProductMediaPrefetchState.failed;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WalkaProductMediaPrefetchResult &&
            other.variantId == variantId &&
            other.assetPath == assetPath &&
            other.surface == surface &&
            other.state == state &&
            other.skipReason == skipReason;
  }

  @override
  int get hashCode =>
      Object.hash(variantId, assetPath, surface, state, skipReason);
}

abstract final class WalkaProductMediaDecodeBudget {
  static const int home = 1200;
  static const int discovery = 1200;
  static const int pdp = 1600;
  static const int favorites = 1200;
  static const int about = 1200;
  static const int defaultAsset = 1200;

  static int forSurface(WalkaProductMediaSurface surface) {
    return switch (surface) {
      WalkaProductMediaSurface.home => home,
      WalkaProductMediaSurface.discovery => discovery,
      WalkaProductMediaSurface.pdp => pdp,
      WalkaProductMediaSurface.favorites => favorites,
      WalkaProductMediaSurface.about => about,
      WalkaProductMediaSurface.generic => defaultAsset,
    };
  }
}

@immutable
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

  WalkaProductMediaAsset withCacheWidth(int value) {
    if (value == cacheWidth) return this;
    return WalkaProductMediaAsset(
      variantId: variantId,
      assetPath: assetPath,
      cacheWidth: value,
    );
  }
}

/// Asset-backed product media used only after runtime admission.
class WalkaAssetProductMedia implements WalkaProductMedia {
  const WalkaAssetProductMedia({
    required this.asset,
    required this.fallback,
    required this.semanticLabel,
    this.surface = WalkaProductMediaSurface.generic,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.onLoadEvent,
  });

  final WalkaProductMediaAsset asset;
  final WalkaProductMedia fallback;
  final WalkaProductMediaSurface surface;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final WalkaProductMediaLoadCallback? onLoadEvent;

  @override
  final String semanticLabel;

  FilterQuality get filterQuality => surface == WalkaProductMediaSurface.pdp
      ? FilterQuality.high
      : FilterQuality.medium;

  @override
  Widget build(BuildContext context) {
    return _WalkaAssetProductMediaImage(
      asset: asset,
      fallback: fallback,
      semanticLabel: semanticLabel,
      surface: surface,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      onLoadEvent: onLoadEvent,
    );
  }
}

class _WalkaAssetProductMediaImage extends StatefulWidget {
  const _WalkaAssetProductMediaImage({
    required this.asset,
    required this.fallback,
    required this.semanticLabel,
    required this.surface,
    required this.fit,
    required this.alignment,
    required this.filterQuality,
    this.onLoadEvent,
  });

  final WalkaProductMediaAsset asset;
  final WalkaProductMedia fallback;
  final String semanticLabel;
  final WalkaProductMediaSurface surface;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final FilterQuality filterQuality;
  final WalkaProductMediaLoadCallback? onLoadEvent;

  @override
  State<_WalkaAssetProductMediaImage> createState() =>
      _WalkaAssetProductMediaImageState();
}

class _WalkaAssetProductMediaImageState
    extends State<_WalkaAssetProductMediaImage> {
  bool _loadingEmitted = false;
  bool _loadedEmitted = false;
  bool _fallbackEmitted = false;

  @override
  void initState() {
    super.initState();
    _scheduleLoadingEvent();
  }

  @override
  void didUpdateWidget(covariant _WalkaAssetProductMediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.cacheIdentity != widget.asset.cacheIdentity ||
        oldWidget.surface != widget.surface) {
      _loadingEmitted = false;
      _loadedEmitted = false;
      _fallbackEmitted = false;
      _scheduleLoadingEvent();
    }
  }

  void _scheduleLoadingEvent() {
    if (_loadingEmitted) return;
    _loadingEmitted = true;
    scheduleMicrotask(() => _emit(WalkaProductMediaLoadState.loading));
  }

  void _emitLoaded() {
    if (_loadedEmitted) return;
    _loadedEmitted = true;
    scheduleMicrotask(() => _emit(WalkaProductMediaLoadState.loaded));
  }

  void _emitFallback() {
    if (_fallbackEmitted) return;
    _fallbackEmitted = true;
    scheduleMicrotask(() => _emit(WalkaProductMediaLoadState.fallback));
  }

  void _emit(WalkaProductMediaLoadState state) {
    widget.onLoadEvent?.call(
      WalkaProductMediaLoadEvent(
        variantId: widget.asset.variantId,
        assetPath: widget.asset.assetPath,
        surface: widget.surface,
        state: state,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.asset.assetPath,
      key: ValueKey<String>(widget.asset.cacheIdentity),
      fit: widget.fit,
      alignment: widget.alignment,
      cacheWidth: widget.asset.cacheWidth,
      filterQuality: widget.filterQuality,
      gaplessPlayback: true,
      semanticLabel: widget.semanticLabel,
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        if (frame != null || wasSynchronouslyLoaded) _emitLoaded();
        return child;
      },
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        _emitFallback();
        return Semantics(
          image: true,
          label: '${widget.semanticLabel}. Product visual fallback.',
          child: ExcludeSemantics(child: widget.fallback.build(context)),
        );
      },
    );
  }
}

/// Stable variant-id -> registered canonical-path resolver.
///
/// [productionAssets] is a naming registry, not an admission registry. The
/// production constructor enforces [WalkaProductMediaAdmissionRegistry] so a
/// provisional PNG cannot become owner-visible merely because it exists in the
/// Flutter bundle. Dependency-injected resolvers keep their legacy behavior for
/// tests and previews.
class WalkaProductMediaResolver {
  const WalkaProductMediaResolver({
    this.assetsByVariant = const <String, WalkaProductMediaAsset>{},
    this.enforceRuntimeAdmission = false,
  });

  const WalkaProductMediaResolver.production()
      : assetsByVariant = productionAssets,
        enforceRuntimeAdmission = true;

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

  static const List<String> productionVariantIds = <String>[
    'drawer-organizer:white',
    'drawer-organizer:gray',
    'lunch-box:blue',
    'lunch-box:pink',
    'lunch-box:green',
  ];

  static const List<String> drawerVariantIds = <String>[
    'drawer-organizer:white',
    'drawer-organizer:gray',
  ];

  static const List<String> lunchVariantIds = <String>[
    'lunch-box:blue',
    'lunch-box:pink',
    'lunch-box:green',
  ];

  static const Map<String, String> _familiesByVariant = <String, String>{
    'drawer-organizer:white': 'Drawer Organizer',
    'drawer-organizer:gray': 'Drawer Organizer',
    'lunch-box:blue': 'Lunch Box',
    'lunch-box:pink': 'Lunch Box',
    'lunch-box:green': 'Lunch Box',
  };

  static const Map<String, String> _labelsByVariant = <String, String>{
    'drawer-organizer:white': 'WALKA Drawer Organizer White',
    'drawer-organizer:gray': 'WALKA Drawer Organizer Gray',
    'lunch-box:blue': 'WALKA Lunch Box Blue',
    'lunch-box:pink': 'WALKA Lunch Box Pink',
    'lunch-box:green': 'WALKA Lunch Box Green',
  };

  final Map<String, WalkaProductMediaAsset> assetsByVariant;
  final bool enforceRuntimeAdmission;

  List<String> get releasedVariantIds => List<String>.unmodifiable(
        productionVariantIds.where(assetsByVariant.containsKey),
      );

  List<WalkaProductMediaAsset> get releasedAssets =>
      List<WalkaProductMediaAsset>.unmodifiable(
        productionVariantIds
            .map((String id) => assetsByVariant[id])
            .whereType<WalkaProductMediaAsset>(),
      );

  List<WalkaProductMediaAsset> get admittedAssets =>
      List<WalkaProductMediaAsset>.unmodifiable(
        releasedAssets.where(
          (WalkaProductMediaAsset asset) => _isAssetEligible(asset),
        ),
      );

  WalkaProductMediaAsset? assetFor(String variantId) =>
      assetsByVariant[variantId];

  bool containsReleasedVariant(String variantId) =>
      productionVariantIds.contains(variantId);

  bool hasRegisteredAsset(String variantId) =>
      assetsByVariant.containsKey(variantId);

  bool hasAdmittedAsset(String variantId) {
    final WalkaProductMediaAsset? asset = assetFor(variantId);
    return asset != null && _isAssetEligible(asset);
  }

  /// Compatibility name retained with corrected admission semantics.
  bool hasApprovedAsset(String variantId) => hasAdmittedAsset(variantId);

  String? quarantineReasonFor(String variantId) {
    if (!enforceRuntimeAdmission) return null;
    return WalkaProductMediaAdmissionRegistry.entryFor(variantId)
        ?.quarantineReason;
  }

  String? familyFor(String variantId) => _familiesByVariant[variantId];

  String? displayLabelFor(String variantId) => _labelsByVariant[variantId];

  List<String> siblingVariantIds(String variantId) {
    if (drawerVariantIds.contains(variantId)) return drawerVariantIds;
    if (lunchVariantIds.contains(variantId)) return lunchVariantIds;
    return const <String>[];
  }

  bool _isAssetEligible(WalkaProductMediaAsset asset) {
    if (!enforceRuntimeAdmission) return true;
    final WalkaProductMediaAdmissionEntry? entry =
        WalkaProductMediaAdmissionRegistry.entryFor(asset.variantId);
    return entry != null &&
        entry.canonicalPath == asset.assetPath &&
        entry.eligibleForRuntime;
  }

  WalkaProductMedia resolve({
    required String variantId,
    required WalkaProductMedia fallback,
    String? semanticLabel,
  }) {
    return resolveForSurface(
      variantId: variantId,
      fallback: fallback,
      semanticLabel: semanticLabel,
    );
  }

  WalkaProductMedia resolveForSurface({
    required String variantId,
    required WalkaProductMedia fallback,
    String? semanticLabel,
    WalkaProductMediaSurface surface = WalkaProductMediaSurface.generic,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    WalkaProductMediaLoadCallback? onLoadEvent,
  }) {
    final WalkaProductMediaAsset? asset = assetsByVariant[variantId];
    if (asset == null || !_isAssetEligible(asset)) return fallback;

    final WalkaProductMediaAsset effectiveAsset = asset.withCacheWidth(
      WalkaProductMediaDecodeBudget.forSurface(surface),
    );

    return WalkaAssetProductMedia(
      asset: effectiveAsset,
      fallback: fallback,
      semanticLabel: semanticLabel ?? fallback.semanticLabel,
      surface: surface,
      fit: fit,
      alignment: alignment,
      onLoadEvent: onLoadEvent,
    );
  }

  Future<WalkaProductMediaPrefetchResult> prefetchVariant(
    BuildContext context, {
    required String variantId,
    WalkaProductMediaSurface surface = WalkaProductMediaSurface.generic,
  }) async {
    final WalkaProductMediaAsset? registered = assetFor(variantId);
    if (registered == null) {
      return WalkaProductMediaPrefetchResult(
        variantId: variantId,
        surface: surface,
        state: WalkaProductMediaPrefetchState.skipped,
        skipReason: 'asset-not-registered',
      );
    }
    if (!_isAssetEligible(registered)) {
      return WalkaProductMediaPrefetchResult(
        variantId: variantId,
        assetPath: registered.assetPath,
        surface: surface,
        state: WalkaProductMediaPrefetchState.skipped,
        skipReason: quarantineReasonFor(variantId) ?? 'runtime-not-admitted',
      );
    }

    final WalkaProductMediaAsset asset = registered.withCacheWidth(
      WalkaProductMediaDecodeBudget.forSurface(surface),
    );
    final ImageProvider<Object> provider = ResizeImage.resizeIfNeeded(
      asset.cacheWidth,
      null,
      AssetImage(asset.assetPath),
    );

    Object? loadError;
    try {
      await precacheImage(
        provider,
        context,
        onError: (Object error, StackTrace? stackTrace) {
          loadError = error;
        },
      );
      return WalkaProductMediaPrefetchResult(
        variantId: variantId,
        assetPath: asset.assetPath,
        surface: surface,
        state: loadError == null
            ? WalkaProductMediaPrefetchState.prefetched
            : WalkaProductMediaPrefetchState.failed,
      );
    } catch (_) {
      return WalkaProductMediaPrefetchResult(
        variantId: variantId,
        assetPath: asset.assetPath,
        surface: surface,
        state: WalkaProductMediaPrefetchState.failed,
      );
    }
  }

  Future<List<WalkaProductMediaPrefetchResult>> prefetchVariants(
    BuildContext context, {
    required Iterable<String> variantIds,
    WalkaProductMediaSurface surface = WalkaProductMediaSurface.generic,
  }) async {
    final Set<String> seen = <String>{};
    final List<WalkaProductMediaPrefetchResult> results =
        <WalkaProductMediaPrefetchResult>[];
    for (final String variantId in variantIds) {
      if (!seen.add(variantId)) continue;
      results.add(
        await prefetchVariant(
          context,
          variantId: variantId,
          surface: surface,
        ),
      );
    }
    return results;
  }
}

/// Owner-visible product media boundary used by Home, discovery and PDP.
class WalkaResolvedProductMedia extends StatelessWidget {
  const WalkaResolvedProductMedia({
    required this.variantId,
    required this.kind,
    required this.primaryColor,
    required this.semanticLabel,
    super.key,
    this.backgroundColor = Colors.transparent,
    this.compact = false,
    this.mediaSurface = WalkaProductMediaSurface.generic,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.onLoadEvent,
    this.resolver = const WalkaProductMediaResolver.production(),
  });

  final String variantId;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color backgroundColor;
  final bool compact;
  final String semanticLabel;
  final WalkaProductMediaSurface mediaSurface;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final WalkaProductMediaLoadCallback? onLoadEvent;
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
      media: resolver.resolveForSurface(
        variantId: variantId,
        fallback: fallback,
        semanticLabel: semanticLabel,
        surface: mediaSurface,
        fit: fit,
        alignment: alignment,
        onLoadEvent: onLoadEvent,
      ),
    );
  }
}
