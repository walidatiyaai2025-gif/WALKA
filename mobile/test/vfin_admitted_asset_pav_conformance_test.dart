import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/pav_png_inspector.dart';

List<Map<String, dynamic>> _rows() {
  final Map<String, dynamic> root = jsonDecode(
    File('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return (root['variants'] as List<dynamic>).cast<Map<String, dynamic>>();
}

void main() {
  const PavPngInspector inspector = PavPngInspector();

  test('every ADMITTED PNG conforms to PAV mechanical media rules', () {
    for (final Map<String, dynamic> row in _rows()) {
      if (row['lifecycleState'] != 'ADMITTED') continue;
      final dynamic inspection = inspector.inspect(
        File(row['canonicalPath'] as String).readAsBytesSync(),
      );

      expect(inspection.width, 1024, reason: row['variantId'] as String);
      expect(inspection.height, 1024, reason: row['variantId'] as String);
      expect(inspection.bitDepth, 8, reason: row['variantId'] as String);
      expect(inspection.colorType, 6, reason: row['variantId'] as String);
      expect(inspection.hasColorProfile, isTrue, reason: row['variantId'] as String);
      expect(
        inspection.alphaMetrics?.hasTransparentPixels,
        isTrue,
        reason: row['variantId'] as String,
      );
      expect(
        inspection.alphaMetrics?.perimeterTransparent,
        isTrue,
        reason: row['variantId'] as String,
      );
      expect(
        inspection.alphaMetrics?.safeMargins?.passes,
        isTrue,
        reason: row['variantId'] as String,
      );
    }
  });

  test('provenance dimensions and bytes match admitted binaries', () {
    for (final Map<String, dynamic> row in _rows()) {
      if (row['lifecycleState'] != 'ADMITTED') continue;
      final dynamic inspection = inspector.inspect(
        File(row['canonicalPath'] as String).readAsBytesSync(),
      );
      expect(row['width'], inspection.width, reason: row['variantId'] as String);
      expect(row['height'], inspection.height, reason: row['variantId'] as String);
      expect(row['byteSize'], inspection.bytes, reason: row['variantId'] as String);
    }
  });
}
