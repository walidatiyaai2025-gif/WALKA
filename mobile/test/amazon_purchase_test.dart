import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/commerce/amazon_purchase.dart';
import 'package:walka/features/commerce/protected_commerce_master.dart'
    show WalkaProtectedCommerceMaster;
import 'package:walka/features/commerce/walka_commerce_map.dart';

void main() {
  setUp(WalkaAmazonPurchaseRegistry.clearForTesting);

  group('Amazon drawer organizer routing', () {
    test('white variant maps to the white WALKA ASIN', () {
      final Uri uri = amazonDrawerOrganizerUri(gray: false);

      expect(uri.scheme, 'https');
      expect(uri.host, 'www.amazon.com');
      expect(uri.path, '/dp/$walkaDrawerOrganizerWhiteAsin');
      expect(walkaDrawerOrganizerWhiteAsin, 'B0FQN4DCTG');
    });

    test('gray variant maps to the gray WALKA ASIN', () {
      final Uri uri = amazonDrawerOrganizerUri(gray: true);

      expect(uri.scheme, 'https');
      expect(uri.host, 'www.amazon.com');
      expect(uri.path, '/dp/$walkaDrawerOrganizerGrayAsin');
      expect(walkaDrawerOrganizerGrayAsin, 'B0FQN4L2ZD');
    });

    test('white and gray listings stay distinct', () {
      expect(
        amazonDrawerOrganizerUri(gray: false),
        isNot(amazonDrawerOrganizerUri(gray: true)),
      );
    });
  });

  group('Amazon lunch box routing', () {
    test('blue variant maps to the official listing', () {
      final Uri uri = amazonLunchBoxUri(WalkaAmazonLunchVariant.blue);
      expect(uri.scheme, 'https');
      expect(uri.host, 'www.amazon.com');
      expect(uri.path, '/dp/$walkaLunchBoxBlueAsin');
      expect(walkaLunchBoxBlueAsin, 'B0FQN4L8MW');
    });

    test('pink variant maps to the official listing', () {
      final Uri uri = amazonLunchBoxUri(WalkaAmazonLunchVariant.pink);
      expect(uri.path, '/dp/$walkaLunchBoxPinkAsin');
      expect(walkaLunchBoxPinkAsin, 'B0FQN3W4SF');
    });

    test('green variant maps to the official listing', () {
      final Uri uri = amazonLunchBoxUri(WalkaAmazonLunchVariant.green);
      expect(uri.path, '/dp/$walkaLunchBoxGreenAsin');
      expect(walkaLunchBoxGreenAsin, 'B0GPZNKF9F');
    });

    test('all lunch listings stay distinct', () {
      final Set<Uri> uris = WalkaAmazonLunchVariant.values
          .map(amazonLunchBoxUri)
          .toSet();
      expect(uris.length, 3);
    });
  });

  group('dynamic governed destinations', () {
    test('verified CA mapping changes destination only', () {
      final WalkaCommerceSnapshot snapshot = WalkaCommerceSnapshot.fromApiJson(
        _commerceSnapshot(
          market: 'CA',
          destination: 'https://www.amazon.ca/dp/B0FQN4L8MW',
        ),
      );

      WalkaAmazonPurchaseRegistry.replaceCommerceSnapshot(
        snapshot,
        market: 'CA',
      );

      final Uri uri = amazonLunchBoxUri(WalkaAmazonLunchVariant.blue);
      expect(uri.host, 'www.amazon.ca');
      expect(uri.path, '/dp/$walkaLunchBoxBlueAsin');
    });

    test('unmapped variant falls back to bundled Product Master URL', () {
      final WalkaCommerceSnapshot snapshot = WalkaCommerceSnapshot.fromApiJson(
        _commerceSnapshot(
          market: 'CA',
          destination: 'https://www.amazon.ca/dp/B0FQN4L8MW',
        ),
      );
      WalkaAmazonPurchaseRegistry.replaceCommerceSnapshot(
        snapshot,
        market: 'CA',
      );

      final Uri uri = amazonLunchBoxUri(WalkaAmazonLunchVariant.pink);
      expect(uri.host, 'www.amazon.com');
      expect(uri.path, '/dp/$walkaLunchBoxPinkAsin');
    });
  });

  group('runtime purchase launch guard', () {
    test('rejects non-Amazon candidate and launches protected fallback', () async {
      Uri? launched;
      final Uri fallback = WalkaProtectedCommerceMaster.destinationForVariant(
        'lunch-box:blue',
      );

      final bool result = await openAmazonPurchaseUri(
        Uri.parse('https://example.invalid/dp/$walkaLunchBoxBlueAsin'),
        expectedAsin: walkaLunchBoxBlueAsin,
        fallbackUri: fallback,
        launcher: (Uri uri) async {
          launched = uri;
          return true;
        },
      );

      expect(result, isTrue);
      expect(launched, fallback);
    });

    test('rejects Amazon URL whose ASIN does not match protected variant', () async {
      Uri? launched;
      final Uri fallback = WalkaProtectedCommerceMaster.destinationForVariant(
        'lunch-box:blue',
      );

      final bool result = await openAmazonPurchaseUri(
        Uri.parse('https://www.amazon.com/dp/B0FQN3W4SF'),
        expectedAsin: walkaLunchBoxBlueAsin,
        fallbackUri: fallback,
        launcher: (Uri uri) async {
          launched = uri;
          return true;
        },
      );

      expect(result, isTrue);
      expect(launched, fallback);
    });

    test('allows canonical governed Amazon market URL', () async {
      Uri? launched;
      final Uri candidate = Uri.parse(
        'https://www.amazon.ca/dp/$walkaLunchBoxBlueAsin',
      );

      final bool result = await openAmazonPurchaseUri(
        candidate,
        expectedAsin: walkaLunchBoxBlueAsin,
        launcher: (Uri uri) async {
          launched = uri;
          return true;
        },
      );

      expect(result, isTrue);
      expect(launched, candidate);
    });

    test('fails closed when candidate and fallback are both unsafe', () async {
      bool launcherCalled = false;
      final bool result = await openAmazonPurchaseUri(
        Uri.parse('https://example.invalid/item'),
        expectedAsin: walkaLunchBoxBlueAsin,
        fallbackUri: Uri.parse('https://phishing.invalid/item'),
        launcher: (Uri _) async {
          launcherCalled = true;
          return true;
        },
      );

      expect(result, isFalse);
      expect(launcherCalled, isFalse);
    });
  });
}

Map<String, dynamic> _commerceSnapshot({
  required String market,
  required String destination,
}) {
  return <String, dynamic>{
    'data': <String, dynamic>{
      'schema_version': 1,
      'mappings': <Map<String, dynamic>>[
        <String, dynamic>{
          'variant_id': 'lunch-box:blue',
          'variant_revision': 1,
          'region_market': market,
          'asin': walkaLunchBoxBlueAsin,
          'destination_url': destination,
          'cta_key': 'commerce.amazon.buy',
          'disclosure_key': 'commerce.amazon.disclosure',
          'entitlements': <String>['amazon.redirect'],
          'active': true,
          'trace': <String, dynamic>{
            'source': 'cms.verified',
            'reference': '#375',
          },
        },
      ],
      'verification': <String, dynamic>{
        'algorithm': 'sha256',
        'digest': List<String>.filled(64, 'a').join(),
        'schema_version': 1,
        'published_revision': 2,
        'active_mapping_count': 1,
        'markets': <String>[market],
      },
    },
  };
}
