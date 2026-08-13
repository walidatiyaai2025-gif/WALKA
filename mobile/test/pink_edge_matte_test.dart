import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/pav_models.dart';
import '../tool/src/pink_edge_matte.dart';
import '../tool/src/png_asset_inspector.dart';
import '../tool/src/png_rgba_encoder.dart';
import '../tool/src/visual_proof_v2.dart';

void main() {
  const PinkEdgeMatteRemediator remediator = PinkEdgeMatteRemediator();
  const PavPngInspector inspector = PavPngInspector();
  const VproofAnalyzerV2 analyzer = VproofAnalyzerV2();

  test('colored subject white matte is reduced without changing alpha', () {
    final Uint8List source = _subject(
      width: 32,
      height: 32,
      interior: const <int>[180, 45, 110],
      halo: const <int>[252, 252, 252],
    );
    final VproofV2Metrics before = analyzer.analyzeRgba(
      source,
      width: 32,
      height: 32,
    );
    final PinkEdgeMatteResult result = remediator.transform(
      source,
      width: 32,
      height: 32,
    );
    final VproofV2Metrics after = analyzer.analyzeRgba(
      result.rgba,
      width: 32,
      height: 32,
    );

    expect(result.changedPixelCount, greaterThan(0));
    expect(
      after.mismatchNearWhitePartialEdgeCount,
      lessThan(before.mismatchNearWhitePartialEdgeCount),
    );
    expect(_alphaPlane(result.rgba), _alphaPlane(source));
    expect(_opaqueRgb(result.rgba), _opaqueRgb(source));
  });

  test('legitimate light neutral antialiasing is preserved', () {
    final Uint8List source = _subject(
      width: 32,
      height: 32,
      interior: const <int>[220, 218, 214],
      halo: const <int>[250, 250, 248],
    );
    final PinkEdgeMatteResult result = remediator.transform(
      source,
      width: 32,
      height: 32,
    );

    expect(result.changedPixelCount, 0);
    expect(result.skippedLightInteriorCount, greaterThan(0));
    expect(result.rgba, orderedEquals(source));
  });

  test('fully transparent and fully opaque pixels are never modified', () {
    final Uint8List source = Uint8List.fromList(<int>[
      255, 255, 255, 0,
      255, 255, 255, 255,
      250, 250, 250, 128,
      150, 40, 100, 255,
    ]);
    final PinkEdgeMatteResult result = remediator.transform(
      source,
      width: 2,
      height: 2,
    );

    expect(result.rgba.sublist(0, 4), orderedEquals(source.sublist(0, 4)));
    expect(result.rgba.sublist(4, 8), orderedEquals(source.sublist(4, 8)));
    expect(result.rgba.sublist(12, 16), orderedEquals(source.sublist(12, 16)));
    expect(_alphaPlane(result.rgba), _alphaPlane(source));
  });

  test('deterministic PNG encoder round-trips RGBA and sRGB metadata', () {
    final Uint8List rgba = _subject(
      width: 16,
      height: 16,
      interior: const <int>[175, 50, 115],
      halo: const <int>[252, 252, 252],
    );
    final Uint8List encoded = PavRgbaPngEncoder.encode(
      width: 16,
      height: 16,
      rgba: rgba,
    );
    final PavPngInspection inspection = inspector.inspect(encoded);

    expect(inspection.width, 16);
    expect(inspection.height, 16);
    expect(inspection.bitDepth, 8);
    expect(inspection.colorType, 6);
    expect(inspection.hasColorProfile, isTrue);
    expect(inspection.rgba, isNotNull);
    expect(inspection.rgba!, orderedEquals(rgba));
  });

  test('remediation preserves visible alpha bounds through PNG round-trip', () {
    final Uint8List sourceRgba = _subject(
      width: 32,
      height: 32,
      interior: const <int>[185, 50, 120],
      halo: const <int>[251, 251, 251],
    );
    final PavPngInspection before = inspector.inspect(
      PavRgbaPngEncoder.encode(width: 32, height: 32, rgba: sourceRgba),
    );
    final PinkEdgeMatteResult result = remediator.transform(
      sourceRgba,
      width: 32,
      height: 32,
    );
    final PavPngInspection after = inspector.inspect(
      PavRgbaPngEncoder.encode(width: 32, height: 32, rgba: result.rgba),
    );

    expect(before.alphaMetrics?.bounds?.left, after.alphaMetrics?.bounds?.left);
    expect(before.alphaMetrics?.bounds?.top, after.alphaMetrics?.bounds?.top);
    expect(before.alphaMetrics?.bounds?.right, after.alphaMetrics?.bounds?.right);
    expect(before.alphaMetrics?.bounds?.bottom, after.alphaMetrics?.bounds?.bottom);
    expect(_alphaPlane(result.rgba), _alphaPlane(sourceRgba));
  });
}

Uint8List _subject({
  required int width,
  required int height,
  required List<int> interior,
  required List<int> halo,
}) {
  final Uint8List rgba = Uint8List(width * height * 4);
  final int left = width ~/ 4;
  final int right = width - left - 1;
  final int top = height ~/ 4;
  final int bottom = height - top - 1;

  for (int y = top; y <= bottom; y += 1) {
    for (int x = left; x <= right; x += 1) {
      final int offset = (y * width + x) * 4;
      final bool edge = x == left || x == right || y == top || y == bottom;
      final List<int> rgb = edge ? halo : interior;
      rgba[offset] = rgb[0];
      rgba[offset + 1] = rgb[1];
      rgba[offset + 2] = rgb[2];
      rgba[offset + 3] = edge ? 128 : 255;
    }
  }
  return rgba;
}

List<int> _alphaPlane(Uint8List rgba) => <int>[
      for (int offset = 3; offset < rgba.length; offset += 4) rgba[offset],
    ];

List<int> _opaqueRgb(Uint8List rgba) {
  final List<int> result = <int>[];
  for (int offset = 0; offset < rgba.length; offset += 4) {
    if (rgba[offset + 3] != 255) continue;
    result
      ..add(rgba[offset])
      ..add(rgba[offset + 1])
      ..add(rgba[offset + 2]);
  }
  return result;
}
