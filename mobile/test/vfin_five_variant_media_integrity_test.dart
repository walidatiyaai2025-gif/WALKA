import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

List<Map<String, dynamic>> _rows(String path) {
  final Object? raw = _readJson(path)['variants'];
  if (raw is! List) throw StateError('$path must expose a variants array.');
  return raw.cast<Map<String, dynamic>>();
}

void main() {
  const Map<String, String> released = <String, String>{
    'drawer-organizer:white': 'assets/products/drawer/white.png',
    'drawer-organizer:gray': 'assets/products/drawer/gray.png',
    'lunch-box:blue': 'assets/products/lunch/blue.png',
    'lunch-box:pink': 'assets/products/lunch/pink.png',
    'lunch-box:green': 'assets/products/lunch/green.png',
  };

  test('production provenance owns exactly the five released canonical paths', () {
    final List<Map<String, dynamic>> rows =
        _rows('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json');
    expect(rows, hasLength(released.length));
    expect(
      rows.map((Map<String, dynamic> row) => row['variantId']).toSet(),
      released.keys.toSet(),
    );
    for (final Map<String, dynamic> row in rows) {
      expect(row['canonicalPath'], released[row['variantId']]);
    }
  });

  test('all five registered canonical files are bundled repository assets', () {
    for (final String path in released.values) {
      expect(File(path).existsSync(), isTrue, reason: 'Missing $path');
    }

    final String pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- assets/products/drawer/'));
    expect(pubspec, contains('- assets/products/lunch/'));
  });

  test('admitted variants are source approved and carry unique fingerprints', () {
    final List<Map<String, dynamic>> provenance =
        _rows('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json');
    final List<Map<String, dynamic>> source =
        _rows('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json');
    final Map<String, Map<String, dynamic>> sourceById = <String, Map<String, dynamic>>{
      for (final Map<String, dynamic> row in source)
        row['variantId'] as String: row,
    };

    final Set<String> hashes = <String>{};
    for (final Map<String, dynamic> row in provenance) {
      if (row['lifecycleState'] != 'ADMITTED') continue;
      final String id = row['variantId'] as String;
      expect(sourceById[id]?['sourceState'], 'APPROVED');
      expect(sourceById[id]?['canonicalExportPresent'], isTrue);
      final String hash = row['sha256'] as String;
      expect(hash, hasLength(64));
      expect(hashes.add(hash), isTrue, reason: 'Duplicate admitted hash: $hash');
      expect(File(row['canonicalPath'] as String).existsSync(), isTrue);
    }
  });

  test('runtime canonical media never points into protected reference masters', () {
    for (final Map<String, dynamic> row
        in _rows('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json')) {
      expect((row['canonicalPath'] as String).startsWith('Images/'), isFalse);
      expect((row['sourceFilename'] as String).startsWith('Images/'), isFalse);
    }
  });
}
