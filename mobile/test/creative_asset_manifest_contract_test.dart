import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ASSET-001 manifest classifies every protected reference', () {
    final String manifest =
        File('../docs/ui/CREATIVE_ASSET_MANIFEST.md').readAsStringSync();
    final List<FileSystemEntity> protected = Directory('../Images')
        .listSync()
        .where((FileSystemEntity entity) {
          if (entity is! File) return false;
          final String path = entity.path.toLowerCase();
          return path.endsWith('.png') ||
              path.endsWith('.jpg') ||
              path.endsWith('.jpeg') ||
              path.endsWith('.webp');
        })
        .toList(growable: false);

    expect(protected, hasLength(18));
    for (final FileSystemEntity entity in protected) {
      final String fileName = entity.uri.pathSegments.last;
      expect(
        manifest,
        contains('`$fileName`'),
        reason: '$fileName must be explicitly classified in ASSET-001.',
      );
    }

    expect(manifest, isNot(contains('| Unclassified |')));
    expect(manifest, isNot(contains('visual classification required')));
    expect(manifest, contains('18/18 classified'));

    const String uuid = 'f96465c7-d756-4409-9963-d96bb6b5893e.png';
    expect(
      manifest,
      contains(
        '`$uuid` | **Design System / Web UI Foundation (non-route)**',
      ),
    );
    expect(
      manifest,
      contains('NO — design-system/style-board reference; explicitly non-blocking'),
    );
    expect(manifest, contains('**“WALKA Design System”**'));
    expect(
      manifest,
      contains('**“Premium Home Organization · Web UI Foundation”**'),
    );
    expect(manifest, contains('**1491×1055**'));
  });

  test('ASSET-001 manifest preserves current source-to-canonical mapping', () {
    final String manifest =
        File('../docs/ui/CREATIVE_ASSET_MANIFEST.md').readAsStringSync();
    final Map<String, dynamic> admission = jsonDecode(
      File('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final List<dynamic> variants = admission['variants'] as List<dynamic>;
    expect(variants, hasLength(5));

    int canonicalReady = 0;
    for (final dynamic raw in variants) {
      final Map<String, dynamic> row = raw as Map<String, dynamic>;
      final String sourceFilename = row['sourceFilename'] as String;
      final String sourceState = row['sourceState'] as String;
      final String canonicalPath = row['canonicalPath'] as String;
      final bool canonicalExportPresent = row['canonicalExportPresent'] as bool;

      expect(manifest, contains('`$sourceFilename`'));
      expect(manifest, contains('mobile/$canonicalPath'));
      expect(manifest, contains(sourceState));
      if (canonicalExportPresent) canonicalReady += 1;
    }

    expect(canonicalReady, 3);
    expect(manifest, contains('Current stable-publication readiness is **3/5**'));
    expect(
      manifest,
      contains('no approved Categories / Desktop screenshot'),
    );
    expect(
      manifest,
      contains('no approved PDP / Desktop screenshot'),
    );
    expect(
      manifest,
      contains('Closing ASSET-001 must **not** be interpreted as 5/5 media readiness'),
    );
  });
}
