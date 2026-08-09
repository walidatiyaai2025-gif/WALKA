import 'package:url_launcher/url_launcher.dart';

import '../catalog/domain/walka_catalog.dart';

const String walkaDrawerOrganizerWhiteAsin = 'B0FQN4DCTG';
const String walkaDrawerOrganizerGrayAsin = 'B0FQN4L2ZD';
const String walkaLunchBoxBlueAsin = 'B0FQN4L8MW';
const String walkaLunchBoxPinkAsin = 'B0FQN3W4SF';
const String walkaLunchBoxGreenAsin = 'B0GPZNKF9F';

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

  static void clearForTesting() {
    _purchaseUris = <String, Uri>{};
  }
}

Uri amazonDrawerOrganizerUri({required bool gray}) {
  final String variantId = gray
      ? 'drawer-organizer:gray'
      : 'drawer-organizer:white';
  final Uri? catalogUri = WalkaAmazonPurchaseRegistry.uriForVariant(variantId);
  if (catalogUri != null) return catalogUri;

  final String asin = gray
      ? walkaDrawerOrganizerGrayAsin
      : walkaDrawerOrganizerWhiteAsin;
  return Uri.https('www.amazon.com', '/dp/$asin');
}

Future<bool> openDrawerOrganizerOnAmazon({required bool gray}) {
  return openAmazonPurchaseUri(amazonDrawerOrganizerUri(gray: gray));
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
  final Uri? catalogUri = WalkaAmazonPurchaseRegistry.uriForVariant(
    _lunchVariantId(variant),
  );
  return catalogUri ??
      Uri.https('www.amazon.com', '/dp/${amazonLunchBoxAsin(variant)}');
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
