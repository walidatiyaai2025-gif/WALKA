import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('information surfaces resolve published storefront copy instead of compiled business copy', () {
    final String source =
        File('lib/features/information/information_v102.dart').readAsStringSync();

    expect(source, contains('WalkaContentScope.maybeOf(context)'));
    expect(source, contains('controller.storefrontCopy'));
    expect(source, contains('snapshot.content.informationJson'));
    expect(source, contains('WalkaContentSource.remote'));
    expect(source, contains('WalkaContentSource.cache'));
    expect(source, contains('_InformationData.fromJsonString'));
    expect(source, contains('Icons.cloud_off_rounded'));

    for (final String forbidden in <String>[
      'https://www.amazon.com/stores/',
      'https://www.instagram.com/',
      'https://walkastore.com',
      'Is the lunch box leakproof?',
      'Frequently Asked Questions',
      'Account & information',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('Flutter manifest does not declare local product media directories', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, isNot(contains('assets/products/')));
    expect(pubspec, contains('assets/branding/walka_logo.svg'));
  });

  test('legacy product PNGs are intentionally absent from the release source tree', () {
    for (final String path in <String>[
      'assets/products/drawer/white.png',
      'assets/products/drawer/gray.png',
      'assets/products/lunch/blue.png',
      'assets/products/lunch/pink.png',
      'assets/products/lunch/green.png',
    ]) {
      expect(File(path).existsSync(), isFalse, reason: path);
    }
  });

  test('dynamic storefront has no compiled PDP or featured-product fallback', () {
    final String source =
        File('lib/features/storefront/dynamic_catalog_v140.dart').readAsStringSync();

    expect(source, contains('_isPublishedContent'));
    expect(source, isNot(contains('WalkaPdpLayoutContent.bundled')));
    expect(source, isNot(contains('catalog.products.take(3)')));
    expect(source, isNot(contains('assets/products/')));
    expect(source, isNot(contains('Image.asset(')));
  });
}
