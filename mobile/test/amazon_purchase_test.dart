import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/commerce/amazon_purchase.dart';

void main() {
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
}
