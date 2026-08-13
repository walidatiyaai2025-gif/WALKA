import 'dart:typed_data';

import 'visual_proof_v2.dart'
    show
        vproofV2AlphaOpaque,
        vproofV2AlphaVisible,
        vproofV2InteriorLightChroma,
        vproofV2InteriorLightFloor,
        vproofV2NearWhiteChroma,
        vproofV2NearWhiteFloor,
        vproofV2NeighborRadius;

class PinkEdgeMatteResult {
  const PinkEdgeMatteResult({
    required this.rgba,
    required this.changedPixelCount,
    required this.nearWhiteCandidateCount,
    required this.skippedLightInteriorCount,
    required this.skippedNoInteriorCount,
  });

  final Uint8List rgba;
  final int changedPixelCount;
  final int nearWhiteCandidateCount;
  final int skippedLightInteriorCount;
  final int skippedNoInteriorCount;

  Map<String, Object?> toJson() => <String, Object?>{
        'changedPixelCount': changedPixelCount,
        'nearWhiteCandidateCount': nearWhiteCandidateCount,
        'skippedLightInteriorCount': skippedLightInteriorCount,
        'skippedNoInteriorCount': skippedNoInteriorCount,
        'alphaModified': false,
        'opaquePixelsModified': false,
        'transparentPixelsModified': false,
        'geometryModified': false,
        'automationCanAdmitMedia': false,
      };
}

/// Deterministic white-matte decontamination for a quarantined Pink candidate.
///
/// Only RGB bytes of semi-transparent, near-white pixels are eligible. Alpha
/// bytes are copied unchanged. Fully opaque and fully transparent pixels are
/// never touched. A candidate pixel is left unchanged when the nearest opaque
/// interior ring contains any light/neutral material, preserving legitimate
/// stainless/white antialiasing. Otherwise its RGB is replaced by the mean of
/// the nearest source-derived opaque interior ring while preserving alpha.
class PinkEdgeMatteRemediator {
  const PinkEdgeMatteRemediator();

  PinkEdgeMatteResult transform(
    Uint8List source, {
    required int width,
    required int height,
  }) {
    if (width <= 0 || height <= 0 || source.length != width * height * 4) {
      throw ArgumentError('RGBA buffer length must equal width*height*4.');
    }

    final Uint8List output = Uint8List.fromList(source);
    int changed = 0;
    int candidates = 0;
    int skippedLight = 0;
    int skippedNoInterior = 0;

    for (int y = 0; y < height; y += 1) {
      for (int x = 0; x < width; x += 1) {
        final int offset = (y * width + x) * 4;
        final int alpha = source[offset + 3];
        if (alpha < vproofV2AlphaVisible || alpha >= vproofV2AlphaOpaque) {
          continue;
        }

        final int r = source[offset];
        final int g = source[offset + 1];
        final int b = source[offset + 2];
        if (!_isNearWhite(r, g, b)) continue;
        candidates += 1;

        final _InteriorSample sample = _nearestOpaqueInterior(
          source,
          width: width,
          height: height,
          x: x,
          y: y,
        );
        if (!sample.found) {
          skippedNoInterior += 1;
          continue;
        }
        if (sample.containsLightNeutral) {
          skippedLight += 1;
          continue;
        }

        final int replacementR = sample.sumR ~/ sample.count;
        final int replacementG = sample.sumG ~/ sample.count;
        final int replacementB = sample.sumB ~/ sample.count;
        if (replacementR == r && replacementG == g && replacementB == b) {
          continue;
        }
        output[offset] = replacementR;
        output[offset + 1] = replacementG;
        output[offset + 2] = replacementB;
        changed += 1;
      }
    }

    return PinkEdgeMatteResult(
      rgba: output,
      changedPixelCount: changed,
      nearWhiteCandidateCount: candidates,
      skippedLightInteriorCount: skippedLight,
      skippedNoInteriorCount: skippedNoInterior,
    );
  }

  _InteriorSample _nearestOpaqueInterior(
    Uint8List rgba, {
    required int width,
    required int height,
    required int x,
    required int y,
  }) {
    for (int radius = 1; radius <= vproofV2NeighborRadius; radius += 1) {
      int count = 0;
      int sumR = 0;
      int sumG = 0;
      int sumB = 0;
      bool light = false;
      for (int dy = -radius; dy <= radius; dy += 1) {
        for (int dx = -radius; dx <= radius; dx += 1) {
          if (dx.abs() != radius && dy.abs() != radius) continue;
          final int nx = x + dx;
          final int ny = y + dy;
          if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue;
          final int offset = (ny * width + nx) * 4;
          if (rgba[offset + 3] < vproofV2AlphaOpaque) continue;
          final int r = rgba[offset];
          final int g = rgba[offset + 1];
          final int b = rgba[offset + 2];
          count += 1;
          sumR += r;
          sumG += g;
          sumB += b;
          light = light || _isLightNeutral(r, g, b);
        }
      }
      if (count > 0) {
        return _InteriorSample(
          found: true,
          containsLightNeutral: light,
          count: count,
          sumR: sumR,
          sumG: sumG,
          sumB: sumB,
        );
      }
    }
    return const _InteriorSample.empty();
  }

  bool _isNearWhite(int r, int g, int b) =>
      _minimum(r, g, b) >= vproofV2NearWhiteFloor &&
      _maximum(r, g, b) - _minimum(r, g, b) <= vproofV2NearWhiteChroma;

  bool _isLightNeutral(int r, int g, int b) =>
      _minimum(r, g, b) >= vproofV2InteriorLightFloor &&
      _maximum(r, g, b) - _minimum(r, g, b) <= vproofV2InteriorLightChroma;

  int _minimum(int r, int g, int b) =>
      r < g ? (r < b ? r : b) : (g < b ? g : b);
  int _maximum(int r, int g, int b) =>
      r > g ? (r > b ? r : b) : (g > b ? g : b);
}

class _InteriorSample {
  const _InteriorSample({
    required this.found,
    required this.containsLightNeutral,
    required this.count,
    required this.sumR,
    required this.sumG,
    required this.sumB,
  });

  const _InteriorSample.empty()
      : found = false,
        containsLightNeutral = false,
        count = 0,
        sumR = 0,
        sumG = 0,
        sumB = 0;

  final bool found;
  final bool containsLightNeutral;
  final int count;
  final int sumR;
  final int sumG;
  final int sumB;
}
