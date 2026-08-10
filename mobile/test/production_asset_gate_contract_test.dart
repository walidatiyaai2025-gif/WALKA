import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production asset gate tracks all canonical resolver paths', () {
    final String script = File(
      'tool/verify_production_assets.sh',
    ).readAsStringSync();

    const List<String> required = <String>[
      'assets/products/drawer/white.png',
      'assets/products/drawer/gray.png',
      'assets/products/lunch/blue.png',
      'assets/products/lunch/pink.png',
      'assets/products/lunch/green.png',
    ];

    for (final String path in required) {
      expect(script, contains(path), reason: 'release gate must cover $path');
    }
  });

  test('production asset gate has report and enforce modes', () {
    final String script = File(
      'tool/verify_production_assets.sh',
    ).readAsStringSync();

    expect(script, contains('--report'));
    expect(script, contains('--enforce'));
    expect(script, contains('stable owner-visible APK publication is blocked'));
  });
}
