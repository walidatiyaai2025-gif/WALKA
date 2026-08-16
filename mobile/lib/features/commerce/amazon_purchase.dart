import 'package:url_launcher/url_launcher.dart';

import '../catalog/domain/walka_catalog.dart';

enum WalkaAmazonLunchVariant { blue, pink, green }

abstract final class WalkaAmazonPurchaseRegistry {
  static Map<String, Uri> _purchaseUris = <String, Uri>{};

  static void replaceFromSnapshot(WalkaCatalogSnapshot snapshot) {
    final Map<String, Uri> next = <String, Uri>{};
    for (final WalkaCatalogVariant variant in snapshot.variants) {
      final Uri uri = variant.purchaseUri;
      final String host = uri.host.toLowerCase();
      if (uri.scheme == 'https' &&
          (host == 'amazon.com' || host == 'www.amazon.com')) {
        next[variant.id] = uri;
      }
    }
    _purchaseUris = Map<String, Uri>.unmodifiable(next);
  }

  static Uri? uriForVariant(String variantId) => _purchaseUris[variantId];

  static Uri requireUriForVariant(String variantId) {
    final Uri? uri = uriForVariant(variantId);
    if (uri == null) {
      throw StateError(
        'No validated Dashboard purchase URL is loaded for variant $variantId.',
      );
    }
    return uri;
  }

  static void clearForTesting() {
    _purchaseUris = <String, Uri>{};
  }
}

Uri amazonDrawerOrganizerUri({required bool gray}) {
  return WalkaAmazonPurchaseRegistry.requireUriForVariant(
    gray ? 'drawer-organizer:gray' : 'drawer-organizer:white',
  );
}

Future<bool> openDrawerOrganizerOnAmazon({required bool gray}) {
  return openAmazonPurchaseUri(amazonDrawerOrganizerUri(gray: gray));
}

String _lunchVariantId(WalkaAmazonLunchVariant variant) {
  return switch (variant) {
    WalkaAmazonLunchVariant.blue => 'lunch-box:blue',
    WalkaAmazonLunchVariant.pink => 'lunch-box:pink',
    WalkaAmazonLunchVariant.green => 'lunch-box:green',
  };
}

String amazonLunchBoxAsin(WalkaAmazonLunchVariant variant) {
  final Uri uri = WalkaAmazonPurchaseRegistry.requireUriForVariant(
    _lunchVariantId(variant),
  );
  final List<String> segments = uri.pathSegments;
  if (segments.length < 2 || segments[segments.length - 2] != 'dp') {
    throw StateError('Loaded Dashboard purchase URL does not contain an ASIN.');
  }
  return segments.last;
}

Uri amazonLunchBoxUri(WalkaAmazonLunchVariant variant) {
  return WalkaAmazonPurchaseRegistry.requireUriForVariant(
    _lunchVariantId(variant),
  );
}

Future<bool> openLunchBoxOnAmazon(WalkaAmazonLunchVariant variant) {
  return openAmazonPurchaseUri(amazonLunchBoxUri(variant));
}

Future<bool> openAmazonPurchaseUri(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
