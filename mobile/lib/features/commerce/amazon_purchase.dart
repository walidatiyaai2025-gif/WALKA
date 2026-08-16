import 'package:url_launcher/url_launcher.dart';

import '../catalog/domain/walka_catalog.dart';
import 'protected_commerce_master.dart';
import 'walka_commerce_map.dart';

export 'protected_commerce_master.dart'
    show
        walkaDrawerOrganizerGrayAsin,
        walkaDrawerOrganizerWhiteAsin,
        walkaLunchBoxBlueAsin,
        walkaLunchBoxGreenAsin,
        walkaLunchBoxPinkAsin;

enum WalkaAmazonLunchVariant { blue, pink, green }

typedef WalkaAmazonUriLauncher = Future<bool> Function(Uri uri);

abstract final class WalkaAmazonPurchaseRegistry {
  static Map<String, Uri> _catalogUris = <String, Uri>{};
  static Map<String, Map<String, Uri>> _commerceUris =
      <String, Map<String, Uri>>{};
  static String _activeMarket = 'US';

  static void replaceFromSnapshot(WalkaCatalogSnapshot snapshot) {
    final Map<String, Uri> next = <String, Uri>{};
    for (final WalkaCatalogVariant variant in snapshot.variants) {
      final String? protectedAsin =
          WalkaProtectedCommerceMaster.asinByVariant[variant.id];
      if (protectedAsin == null) continue;

      Uri fallback;
      try {
        fallback = WalkaProtectedCommerceMaster.destinationForVariant(variant.id);
      } on FormatException {
        continue;
      }

      if (variant.asin.trim().toUpperCase() != protectedAsin) {
        next[variant.id] = fallback;
        continue;
      }

      try {
        final Uri candidate = variant.purchaseUri;
        next[variant.id] = WalkaProtectedCommerceMaster.isApprovedAmazonUri(
          candidate,
          asin: protectedAsin,
        )
            ? candidate
            : fallback;
      } on Object {
        next[variant.id] = fallback;
      }
    }
    _catalogUris = Map<String, Uri>.unmodifiable(next);
  }

  static void replaceCommerceSnapshot(
    WalkaCommerceSnapshot snapshot, {
    String market = 'US',
  }) {
    final String normalizedMarket =
        WalkaProtectedCommerceMaster.normalizeMarket(market);
    _activeMarket = normalizedMarket;

    if (snapshot.revision < 1 || snapshot.verificationDigest == null) {
      _commerceUris = <String, Map<String, Uri>>{};
      return;
    }

    final Map<String, Map<String, Uri>> byMarket = <String, Map<String, Uri>>{};
    for (final WalkaCommerceMapping mapping in snapshot.mappings) {
      final String? protectedAsin =
          WalkaProtectedCommerceMaster.asinByVariant[mapping.variantId];
      if (protectedAsin == null || protectedAsin != mapping.asin) continue;
      if (!WalkaProtectedCommerceMaster.isApprovedDestination(
        mapping.destinationUri,
        market: mapping.regionMarket,
        asin: protectedAsin,
      )) {
        continue;
      }
      byMarket
          .putIfAbsent(mapping.regionMarket, () => <String, Uri>{})
          [mapping.variantId] = mapping.destinationUri;
    }

    _commerceUris = Map<String, Map<String, Uri>>.unmodifiable(
      byMarket.map(
        (String key, Map<String, Uri> value) =>
            MapEntry<String, Map<String, Uri>>(
          key,
          Map<String, Uri>.unmodifiable(value),
        ),
      ),
    );
  }

  static Uri? uriForVariant(String variantId) {
    final Uri? remote = _commerceUris[_activeMarket]?[variantId];
    if (remote != null) return remote;

    final Uri? catalog = _catalogUris[variantId];
    if (catalog != null) return catalog;

    if (!WalkaProtectedCommerceMaster.asinByVariant.containsKey(variantId)) {
      return null;
    }
    return WalkaProtectedCommerceMaster.destinationForVariant(variantId);
  }

  static void clearForTesting() {
    _catalogUris = <String, Uri>{};
    _commerceUris = <String, Map<String, Uri>>{};
    _activeMarket = 'US';
  }
}

Uri amazonDrawerOrganizerUri({required bool gray}) {
  final String variantId = gray
      ? 'drawer-organizer:gray'
      : 'drawer-organizer:white';
  return WalkaAmazonPurchaseRegistry.uriForVariant(variantId) ??
      WalkaProtectedCommerceMaster.destinationForVariant(variantId);
}

Future<bool> openDrawerOrganizerOnAmazon({required bool gray}) {
  final String variantId = gray
      ? 'drawer-organizer:gray'
      : 'drawer-organizer:white';
  return openAmazonPurchaseUri(
    amazonDrawerOrganizerUri(gray: gray),
    expectedAsin: WalkaProtectedCommerceMaster.asinForVariant(variantId),
    fallbackUri: WalkaProtectedCommerceMaster.destinationForVariant(variantId),
  );
}

String amazonLunchBoxAsin(WalkaAmazonLunchVariant variant) {
  return switch (variant) {
    WalkaAmazonLunchVariant.blue => walkaLunchBoxBlueAsin,
    WalkaAmazonLunchVariant.pink => walkaLunchBoxPinkAsin,
    WalkaAmazonLunchVariant.green => walkaLunchBoxGreenAsin,
  };
}

String _lunchVariantId(WalkaAmazonLunchVariant variant) {
  return switch (variant) {
    WalkaAmazonLunchVariant.blue => 'lunch-box:blue',
    WalkaAmazonLunchVariant.pink => 'lunch-box:pink',
    WalkaAmazonLunchVariant.green => 'lunch-box:green',
  };
}

Uri amazonLunchBoxUri(WalkaAmazonLunchVariant variant) {
  final String variantId = _lunchVariantId(variant);
  return WalkaAmazonPurchaseRegistry.uriForVariant(variantId) ??
      WalkaProtectedCommerceMaster.destinationForVariant(variantId);
}

Future<bool> openLunchBoxOnAmazon(WalkaAmazonLunchVariant variant) {
  final String variantId = _lunchVariantId(variant);
  return openAmazonPurchaseUri(
    amazonLunchBoxUri(variant),
    expectedAsin: WalkaProtectedCommerceMaster.asinForVariant(variantId),
    fallbackUri: WalkaProtectedCommerceMaster.destinationForVariant(variantId),
  );
}

Future<bool> openAmazonPurchaseUri(
  Uri uri, {
  String? expectedAsin,
  Uri? fallbackUri,
  WalkaAmazonUriLauncher? launcher,
}) async {
  final String? normalizedAsin = expectedAsin?.trim().toUpperCase();
  final bool candidateSafe = normalizedAsin == null
      ? _isAnyProtectedAmazonUri(uri)
      : WalkaProtectedCommerceMaster.isApprovedAmazonUri(
          uri,
          asin: normalizedAsin,
        );

  Uri? resolved = candidateSafe ? uri : null;
  if (resolved == null && fallbackUri != null) {
    final bool fallbackSafe = normalizedAsin == null
        ? _isAnyProtectedAmazonUri(fallbackUri)
        : WalkaProtectedCommerceMaster.isApprovedAmazonUri(
            fallbackUri,
            asin: normalizedAsin,
          );
    if (fallbackSafe) resolved = fallbackUri;
  }
  if (resolved == null) return false;

  final WalkaAmazonUriLauncher effectiveLauncher =
      launcher ?? _launchExternalAmazonUri;
  try {
    return await effectiveLauncher(resolved);
  } on Object {
    return false;
  }
}

bool _isAnyProtectedAmazonUri(Uri uri) {
  for (final String asin in WalkaProtectedCommerceMaster.asinByVariant.values) {
    if (WalkaProtectedCommerceMaster.isApprovedAmazonUri(uri, asin: asin)) {
      return true;
    }
  }
  return false;
}

Future<bool> _launchExternalAmazonUri(Uri uri) {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
