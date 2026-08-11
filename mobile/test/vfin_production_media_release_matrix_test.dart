import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const Map<String, String> _released = <String, String>{
  'drawer-organizer:white': 'assets/products/drawer/white.png',
  'drawer-organizer:gray': 'assets/products/drawer/gray.png',
  'lunch-box:blue': 'assets/products/lunch/blue.png',
  'lunch-box:pink': 'assets/products/lunch/pink.png',
  'lunch-box:green': 'assets/products/lunch/green.png',
};

const List<String> _mandatoryQa = <String>[
  'surfaceWhite',
  'surfaceIvory',
  'surfaceNavy',
  'downscale96',
  'downscale160',
  'downscale240',
  'downscale384',
  'geometryPreserved',
  'bakedUiExcluded',
];

List<Map<String, dynamic>> _provenanceRows() {
  final Map<String, dynamic> root = jsonDecode(
    File('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return (root['variants'] as List<dynamic>).cast<Map<String, dynamic>>();
}

void main() {
  test('released production media registry is exact, stable and unique', () {
    final List<Map<String, dynamic>> rows = _provenanceRows();
    expect(rows, hasLength(5));
    expect(
      rows.map((Map<String, dynamic> row) => row['variantId']).toList(),
      _released.keys.toList(),
    );
    expect(
      rows.map((Map<String, dynamic> row) => row['canonicalPath']).toSet(),
      _released.values.toSet(),
    );
    expect(rows.map((Map<String, dynamic> row) => row['variantId']).toSet(), hasLength(5));
  });

  test('all canonical paths exist and stay inside the mobile asset namespace', () {
    for (final MapEntry<String, String> entry in _released.entries) {
      expect(entry.value.startsWith('assets/products/'), isTrue);
      expect(entry.value.startsWith('Images/'), isFalse);
      expect(File(entry.value).existsSync(), isTrue, reason: '${entry.key}: ${entry.value}');
    }
  });

  test('pubspec bundles both canonical product directories', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- assets/products/drawer/'));
    expect(pubspec, contains('- assets/products/lunch/'));
  });

  test('every provenance row carries the complete visual QA matrix', () {
    for (final Map<String, dynamic> row in _provenanceRows()) {
      final Map<String, dynamic> qa = row['qa'] as Map<String, dynamic>;
      expect(qa.keys.toSet(), containsAll(_mandatoryQa));
      for (final String key in _mandatoryQa) {
        expect(
          <String>{'PENDING', 'PASS', 'BLOCKED'},
          contains(qa[key]),
          reason: '${row['variantId']} / $key',
        );
      }
    }
  });

  test('ADMITTED means deterministic metadata plus all mandatory QA PASS', () {
    for (final Map<String, dynamic> row in _provenanceRows()) {
      if (row['lifecycleState'] != 'ADMITTED') continue;
      expect(row['sha256'], isA<String>());
      expect(row['sha256'], hasLength(64));
      expect(row['byteSize'], isA<int>());
      expect(row['width'], 1024);
      expect(row['height'], 1024);
      final Map<String, dynamic> qa = row['qa'] as Map<String, dynamic>;
      for (final String key in _mandatoryQa) {
        expect(qa[key], 'PASS', reason: '${row['variantId']} / $key');
      }
      final File file = File(row['canonicalPath'] as String);
      expect(file.lengthSync(), row['byteSize']);
    }
  });

  test('canonical product files are PNGs and stay below the 1.2 MiB hard budget', () {
    const List<int> signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
    const int hardBudget = 1258291;
    for (final String path in _released.values) {
      final File file = File(path);
      final Uint8List bytes = file.readAsBytesSync();
      expect(bytes.length, lessThanOrEqualTo(hardBudget), reason: path);
      expect(bytes.take(8).toList(), signature, reason: path);
    }
  });

  test('blocked media cannot masquerade as admitted production media', () {
    for (final Map<String, dynamic> row in _provenanceRows()) {
      if (row['sourceState'] == 'BLOCKED') {
        expect(row['lifecycleState'], isNot('ADMITTED'));
      }
    }
  });

  test('runtime provenance never uses protected Images reference masters', () {
    for (final Map<String, dynamic> row in _provenanceRows()) {
      expect((row['canonicalPath'] as String).startsWith('Images/'), isFalse);
      expect((row['sourceFilename'] as String).startsWith('Images/'), isFalse);
    }
  });
}
