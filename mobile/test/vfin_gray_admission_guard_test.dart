import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readJson(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _variantRows(Map<String, dynamic> root) {
  final Object? raw = root['variants'];
  if (raw is! List) {
    throw StateError('Expected a variants array.');
  }
  return raw.cast<Map<String, dynamic>>();
}

Map<String, dynamic> _rowFor(
  Map<String, dynamic> root,
  String variantId,
) {
  final List<Map<String, dynamic>> rows = _variantRows(root);
  return rows.singleWhere(
    (Map<String, dynamic> row) => row['variantId'] == variantId,
  );
}

void main() {
  const String grayVariant = 'drawer-organizer:gray';
  const String grayCanonicalPath = 'assets/products/drawer/gray.png';

  test('Gray admission remains fail-closed unless source truth is APPROVED', () {
    final Map<String, dynamic> source =
        _readJson('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json');
    final Map<String, dynamic> provenance =
        _readJson('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json');

    final Map<String, dynamic> sourceRow = _rowFor(source, grayVariant);
    final Map<String, dynamic> provenanceRow = _rowFor(provenance, grayVariant);

    expect(provenanceRow['canonicalPath'], grayCanonicalPath);

    final String sourceState = sourceRow['sourceState'] as String;
    final String lifecycleState = provenanceRow['lifecycleState'] as String;

    if (sourceState != 'APPROVED') {
      expect(
        lifecycleState,
        isNot('ADMITTED'),
        reason: 'Gray must never be admitted while source truth is $sourceState.',
      );
    }
  });

  test('any admitted Gray export has deterministic metadata and bundled bytes', () {
    final Map<String, dynamic> source =
        _readJson('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json');
    final Map<String, dynamic> provenance =
        _readJson('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json');

    final Map<String, dynamic> sourceRow = _rowFor(source, grayVariant);
    final Map<String, dynamic> provenanceRow = _rowFor(provenance, grayVariant);

    if (provenanceRow['lifecycleState'] != 'ADMITTED') {
      return;
    }

    expect(sourceRow['sourceState'], 'APPROVED');
    expect(sourceRow['canonicalExportPresent'], isTrue);
    expect(provenanceRow['sha256'], isA<String>());
    expect((provenanceRow['sha256'] as String).length, 64);
    expect(provenanceRow['byteSize'], isA<int>());
    expect((provenanceRow['byteSize'] as int), greaterThan(0));
    expect(provenanceRow['width'], 1024);
    expect(provenanceRow['height'], 1024);

    final File canonical = File(grayCanonicalPath);
    expect(canonical.existsSync(), isTrue);
    expect(canonical.lengthSync(), provenanceRow['byteSize']);
  });

  test('Gray canonical path remains exact and protected Images is not a source', () {
    final Map<String, dynamic> provenance =
        _readJson('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json');
    final Map<String, dynamic> row = _rowFor(provenance, grayVariant);

    expect(row['canonicalPath'], grayCanonicalPath);
    expect((row['sourceFilename'] as String).startsWith('Images/'), isFalse);
  });
}
