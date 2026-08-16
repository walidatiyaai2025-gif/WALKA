const String walkaDrawerOrganizerWhiteAsin = 'B0FQN4DCTG';
const String walkaDrawerOrganizerGrayAsin = 'B0FQN4L2ZD';
const String walkaLunchBoxBlueAsin = 'B0FQN4L8MW';
const String walkaLunchBoxPinkAsin = 'B0FQN3W4SF';
const String walkaLunchBoxGreenAsin = 'B0GPZNKF9F';

abstract final class WalkaProtectedCommerceMaster {
  static const Map<String, String> asinByVariant = <String, String>{
    'drawer-organizer:white': walkaDrawerOrganizerWhiteAsin,
    'drawer-organizer:gray': walkaDrawerOrganizerGrayAsin,
    'lunch-box:blue': walkaLunchBoxBlueAsin,
    'lunch-box:pink': walkaLunchBoxPinkAsin,
    'lunch-box:green': walkaLunchBoxGreenAsin,
  };

  static const Map<String, String> hostByMarket = <String, String>{
    'US': 'www.amazon.com',
    'CA': 'www.amazon.ca',
    'MX': 'www.amazon.com.mx',
  };

  static String normalizeMarket(String market) {
    final String normalized = market.trim().toUpperCase();
    if (!hostByMarket.containsKey(normalized)) {
      throw const FormatException('Unsupported WALKA Amazon market.');
    }
    return normalized;
  }

  static String asinForVariant(String variantId) {
    final String? asin = asinByVariant[variantId];
    if (asin == null) {
      throw const FormatException('Unknown WALKA protected commerce variant.');
    }
    return asin;
  }

  static Uri destinationForVariant(
    String variantId, {
    String market = 'US',
  }) {
    return destinationForAsin(asinForVariant(variantId), market: market);
  }

  static Uri destinationForAsin(
    String asin, {
    String market = 'US',
  }) {
    final String normalizedMarket = normalizeMarket(market);
    final String normalizedAsin = asin.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{10}$').hasMatch(normalizedAsin)) {
      throw const FormatException('Invalid protected WALKA ASIN.');
    }
    return Uri.https(hostByMarket[normalizedMarket]!, '/dp/$normalizedAsin');
  }

  static bool isApprovedDestination(
    Uri uri, {
    required String market,
    required String asin,
  }) {
    String normalizedMarket;
    try {
      normalizedMarket = normalizeMarket(market);
    } on FormatException {
      return false;
    }

    final String normalizedAsin = asin.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{10}$').hasMatch(normalizedAsin)) {
      return false;
    }

    return uri.scheme == 'https' &&
        uri.host.toLowerCase() == hostByMarket[normalizedMarket] &&
        !uri.hasPort &&
        uri.userInfo.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        uri.pathSegments.length == 2 &&
        uri.pathSegments[0] == 'dp' &&
        uri.pathSegments[1].toUpperCase() == normalizedAsin;
  }

  static bool isApprovedAmazonUri(Uri uri, {required String asin}) {
    for (final String market in hostByMarket.keys) {
      if (isApprovedDestination(uri, market: market, asin: asin)) {
        return true;
      }
    }
    return false;
  }
}
