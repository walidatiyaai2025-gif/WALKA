import 'dart:typed_data';

import 'pav_models.dart';
import 'visual_proof.dart' show VproofStage, VproofStageMetrics, vproofDownscaleTargets;

const int vproofV2AlphaVisible = 8;
const int vproofV2AlphaOpaque = 245;
const int vproofV2NearWhiteFloor = 225;
const int vproofV2NearWhiteChroma = 28;
const int vproofV2InteriorLightFloor = 185;
const int vproofV2InteriorLightChroma = 70;
const int vproofV2NeighborRadius = 4;
const int vproofV2MinimumMismatchSamples = 96;
const double vproofV2MismatchPartialRatio = 0.18;
const double vproofV2MismatchNearWhiteRatio = 0.30;

class VproofV2StageMetrics {
  const VproofV2StageMetrics({
    required this.stage,
    required this.sampleCount,
    required this.brightDeltaCount,
    required this.meanCompositeLuma,
  });

  final String stage;
  final int sampleCount;
  final int brightDeltaCount;
  final double meanCompositeLuma;

  double get brightDeltaRatio =>
      sampleCount == 0 ? 0 : brightDeltaCount / sampleCount;

  Map<String, Object?> toJson() => <String, Object?>{
        'stage': stage,
        'sampleCount': sampleCount,
        'brightDeltaCount': brightDeltaCount,
        'brightDeltaRatio': brightDeltaRatio,
        'meanCompositeLuma': meanCompositeLuma,
      };
}

class VproofV2Metrics {
  const VproofV2Metrics({
    required this.width,
    required this.height,
    required this.edgePixelCount,
    required this.partialAlphaEdgeCount,
    required this.rawNearWhitePartialEdgeCount,
    required this.mismatchNearWhitePartialEdgeCount,
    required this.lightInteriorNearWhitePartialEdgeCount,
    required this.noOpaqueInteriorNearWhitePartialEdgeCount,
    required this.nearWhiteSubject,
    required this.stages,
    required this.downscaleMismatchBinRatios,
  });

  final int width;
  final int height;
  final int edgePixelCount;
  final int partialAlphaEdgeCount;
  final int rawNearWhitePartialEdgeCount;
  final int mismatchNearWhitePartialEdgeCount;
  final int lightInteriorNearWhitePartialEdgeCount;
  final int noOpaqueInteriorNearWhitePartialEdgeCount;
  final bool nearWhiteSubject;
  final List<VproofV2StageMetrics> stages;
  final Map<int, double> downscaleMismatchBinRatios;

  double get rawNearWhitePartialEdgeRatio => partialAlphaEdgeCount == 0
      ? 0
      : rawNearWhitePartialEdgeCount / partialAlphaEdgeCount;

  double get mismatchPartialEdgeRatio => partialAlphaEdgeCount == 0
      ? 0
      : mismatchNearWhitePartialEdgeCount / partialAlphaEdgeCount;

  double get mismatchNearWhiteEdgeRatio => rawNearWhitePartialEdgeCount == 0
      ? 0
      : mismatchNearWhitePartialEdgeCount / rawNearWhitePartialEdgeCount;

  VproofV2StageMetrics get navy =>
      stages.firstWhere((VproofV2StageMetrics item) => item.stage == 'navy');

  bool get obviousWhiteHalo =>
      !nearWhiteSubject &&
      mismatchNearWhitePartialEdgeCount >= vproofV2MinimumMismatchSamples &&
      mismatchPartialEdgeRatio >= vproofV2MismatchPartialRatio &&
      mismatchNearWhiteEdgeRatio >= vproofV2MismatchNearWhiteRatio &&
      navy.brightDeltaRatio >= 0.45;

  String get diagnosticDisposition =>
      obviousWhiteHalo ? 'REJECT_OBVIOUS_WHITE_HALO' : 'NO_OBVIOUS_HALO';

  Map<String, Object?> toJson() => <String, Object?>{
        'algorithm': 'edge-interior-mismatch-v2',
        'width': width,
        'height': height,
        'edgePixelCount': edgePixelCount,
        'partialAlphaEdgeCount': partialAlphaEdgeCount,
        'rawNearWhitePartialEdgeCount': rawNearWhitePartialEdgeCount,
        'rawNearWhitePartialEdgeRatio': rawNearWhitePartialEdgeRatio,
        'mismatchNearWhitePartialEdgeCount': mismatchNearWhitePartialEdgeCount,
        'mismatchPartialEdgeRatio': mismatchPartialEdgeRatio,
        'mismatchNearWhiteEdgeRatio': mismatchNearWhiteEdgeRatio,
        'lightInteriorNearWhitePartialEdgeCount':
            lightInteriorNearWhitePartialEdgeCount,
        'noOpaqueInteriorNearWhitePartialEdgeCount':
            noOpaqueInteriorNearWhitePartialEdgeCount,
        'nearWhiteSubject': nearWhiteSubject,
        'neighborRadius': vproofV2NeighborRadius,
        'stages': stages.map((VproofV2StageMetrics item) => item.toJson()).toList(),
        'downscaleMismatchBinRatios': <String, double>{
          for (final MapEntry<int, double> entry
              in downscaleMismatchBinRatios.entries)
            entry.key.toString(): entry.value,
        },
        'obviousWhiteHalo': obviousWhiteHalo,
        'diagnosticDisposition': diagnosticDisposition,
        'automationCanAcceptVisualFidelity': false,
      };
}

class VproofV2Decision {
  const VproofV2Decision({
    required this.lifecycleState,
    required this.knownRejected,
    required this.metrics,
    required this.blockerCodes,
    required this.warningCodes,
  });

  final String lifecycleState;
  final bool knownRejected;
  final VproofV2Metrics metrics;
  final List<String> blockerCodes;
  final List<String> warningCodes;

  bool get blocked => blockerCodes.isNotEmpty;
}

class VproofAnalyzerV2 {
  const VproofAnalyzerV2();

  VproofV2Metrics analyzeInspection(
    PavPngInspection inspection, {
    bool nearWhiteSubject = false,
  }) {
    final Uint8List? rgba = inspection.rgba;
    final int? width = inspection.width;
    final int? height = inspection.height;
    if (rgba == null || width == null || height == null) {
      throw ArgumentError('VPROOF requires a decoded RGBA PNG inspection.');
    }
    return analyzeRgba(
      rgba,
      width: width,
      height: height,
      nearWhiteSubject: nearWhiteSubject,
    );
  }

  VproofV2Metrics analyzeRgba(
    Uint8List rgba, {
    required int width,
    required int height,
    bool nearWhiteSubject = false,
  }) {
    if (width <= 0 || height <= 0 || rgba.length != width * height * 4) {
      throw ArgumentError('RGBA buffer length must equal width*height*4.');
    }

    int edgePixelCount = 0;
    int partialAlphaEdgeCount = 0;
    int rawNearWhitePartialEdgeCount = 0;
    int mismatchNearWhitePartialEdgeCount = 0;
    int lightInteriorNearWhitePartialEdgeCount = 0;
    int noOpaqueInteriorNearWhitePartialEdgeCount = 0;

    final Map<String, _Accumulator> stageAccumulators = <String, _Accumulator>{
      for (final VproofStage stage in VproofStage.all)
        stage.id: _Accumulator(stage),
    };
    final Map<int, Set<int>> rawBins = <int, Set<int>>{
      for (final int size in vproofDownscaleTargets) size: <int>{},
    };
    final Map<int, Set<int>> mismatchBins = <int, Set<int>>{
      for (final int size in vproofDownscaleTargets) size: <int>{},
    };

    for (int y = 0; y < height; y += 1) {
      for (int x = 0; x < width; x += 1) {
        final int offset = (y * width + x) * 4;
        final int alpha = rgba[offset + 3];
        if (alpha < vproofV2AlphaVisible) continue;
        if (!_isEdge(rgba, width: width, height: height, x: x, y: y)) {
          continue;
        }
        edgePixelCount += 1;
        if (alpha >= vproofV2AlphaOpaque) continue;
        partialAlphaEdgeCount += 1;

        final int r = rgba[offset];
        final int g = rgba[offset + 1];
        final int b = rgba[offset + 2];
        if (!_isNearWhite(r, g, b)) continue;
        rawNearWhitePartialEdgeCount += 1;

        final _InteriorClass interior = _classifyInterior(
          rgba,
          width: width,
          height: height,
          x: x,
          y: y,
        );
        if (interior == _InteriorClass.lightNeutral) {
          lightInteriorNearWhitePartialEdgeCount += 1;
          continue;
        }
        if (interior == _InteriorClass.none) {
          noOpaqueInteriorNearWhitePartialEdgeCount += 1;
          continue;
        }

        mismatchNearWhitePartialEdgeCount += 1;
        for (final _Accumulator accumulator in stageAccumulators.values) {
          accumulator.add(r, g, b, alpha);
        }
        for (final int size in vproofDownscaleTargets) {
          final int tx = (x * size) ~/ width;
          final int ty = (y * size) ~/ height;
          final int bin = ty * size + tx;
          mismatchBins[size]!.add(bin);
        }
      }
    }

    for (int y = 0; y < height; y += 1) {
      for (int x = 0; x < width; x += 1) {
        final int offset = (y * width + x) * 4;
        final int alpha = rgba[offset + 3];
        if (alpha < vproofV2AlphaVisible || alpha >= vproofV2AlphaOpaque) {
          continue;
        }
        final int r = rgba[offset];
        final int g = rgba[offset + 1];
        final int b = rgba[offset + 2];
        if (!_isNearWhite(r, g, b)) continue;
        for (final int size in vproofDownscaleTargets) {
          final int tx = (x * size) ~/ width;
          final int ty = (y * size) ~/ height;
          rawBins[size]!.add(ty * size + tx);
        }
      }
    }

    final Map<int, double> downscale = <int, double>{};
    for (final int size in vproofDownscaleTargets) {
      final int denominator = rawBins[size]!.length;
      downscale[size] = denominator == 0
          ? 0
          : mismatchBins[size]!.length / denominator;
    }

    return VproofV2Metrics(
      width: width,
      height: height,
      edgePixelCount: edgePixelCount,
      partialAlphaEdgeCount: partialAlphaEdgeCount,
      rawNearWhitePartialEdgeCount: rawNearWhitePartialEdgeCount,
      mismatchNearWhitePartialEdgeCount: mismatchNearWhitePartialEdgeCount,
      lightInteriorNearWhitePartialEdgeCount:
          lightInteriorNearWhitePartialEdgeCount,
      noOpaqueInteriorNearWhitePartialEdgeCount:
          noOpaqueInteriorNearWhitePartialEdgeCount,
      nearWhiteSubject: nearWhiteSubject,
      stages: stageAccumulators.values
          .map((_Accumulator item) => item.finish())
          .toList(growable: false),
      downscaleMismatchBinRatios: downscale,
    );
  }

  VproofV2Decision decide({
    required String lifecycleState,
    required bool knownRejected,
    required VproofV2Metrics metrics,
  }) {
    final String normalized = lifecycleState.toUpperCase();
    final List<String> blockers = <String>[];
    final List<String> warnings = <String>[];
    if (knownRejected) {
      if (normalized == 'ADMITTED') {
        blockers.add('visual-proof.known-rejected-binary-admitted');
      } else {
        warnings.add('visual-proof.known-rejected-binary-quarantined');
      }
    }
    if (metrics.obviousWhiteHalo) {
      if (normalized == 'ADMITTED') {
        blockers.add('visual-proof.obvious-white-halo-admitted');
      } else {
        warnings.add('visual-proof.obvious-white-halo-quarantined');
      }
    }
    if (normalized != 'ADMITTED') {
      warnings.add('visual-proof.owner-acceptance-not-applicable-to-quarantined-media');
    }
    return VproofV2Decision(
      lifecycleState: normalized,
      knownRejected: knownRejected,
      metrics: metrics,
      blockerCodes: blockers,
      warningCodes: warnings,
    );
  }

  _InteriorClass _classifyInterior(
    Uint8List rgba, {
    required int width,
    required int height,
    required int x,
    required int y,
  }) {
    bool foundOpaque = false;
    for (int radius = 1; radius <= vproofV2NeighborRadius; radius += 1) {
      for (int dy = -radius; dy <= radius; dy += 1) {
        for (int dx = -radius; dx <= radius; dx += 1) {
          if (dx.abs() != radius && dy.abs() != radius) continue;
          final int nx = x + dx;
          final int ny = y + dy;
          if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue;
          final int offset = (ny * width + nx) * 4;
          if (rgba[offset + 3] < vproofV2AlphaOpaque) continue;
          foundOpaque = true;
          if (_isLightNeutral(
            rgba[offset],
            rgba[offset + 1],
            rgba[offset + 2],
          )) {
            return _InteriorClass.lightNeutral;
          }
        }
      }
      if (foundOpaque) return _InteriorClass.coloredOrDark;
    }
    return _InteriorClass.none;
  }

  bool _isEdge(
    Uint8List rgba, {
    required int width,
    required int height,
    required int x,
    required int y,
  }) {
    final int alpha = rgba[(y * width + x) * 4 + 3];
    if (alpha < vproofV2AlphaOpaque) return true;
    for (final List<int> delta in const <List<int>>[
      <int>[-1, 0],
      <int>[1, 0],
      <int>[0, -1],
      <int>[0, 1],
    ]) {
      final int nx = x + delta[0];
      final int ny = y + delta[1];
      if (nx < 0 || nx >= width || ny < 0 || ny >= height) return true;
      if (rgba[(ny * width + nx) * 4 + 3] < vproofV2AlphaVisible) return true;
    }
    return false;
  }

  bool _isNearWhite(int r, int g, int b) =>
      _minimum(r, g, b) >= vproofV2NearWhiteFloor &&
      _maximum(r, g, b) - _minimum(r, g, b) <= vproofV2NearWhiteChroma;

  bool _isLightNeutral(int r, int g, int b) =>
      _minimum(r, g, b) >= vproofV2InteriorLightFloor &&
      _maximum(r, g, b) - _minimum(r, g, b) <= vproofV2InteriorLightChroma;

  int _minimum(int r, int g, int b) => r < g ? (r < b ? r : b) : (g < b ? g : b);
  int _maximum(int r, int g, int b) => r > g ? (r > b ? r : b) : (g > b ? g : b);
}

enum _InteriorClass { none, lightNeutral, coloredOrDark }

class _Accumulator {
  _Accumulator(this.stage);

  final VproofStage stage;
  int sampleCount = 0;
  int brightDeltaCount = 0;
  double totalLuma = 0;

  void add(int r, int g, int b, int alpha) {
    final double a = alpha / 255.0;
    final double cr = r * a + stage.r * (1 - a);
    final double cg = g * a + stage.g * (1 - a);
    final double cb = b * a + stage.b * (1 - a);
    final double composite = _luma(cr, cg, cb);
    final double background =
        _luma(stage.r.toDouble(), stage.g.toDouble(), stage.b.toDouble());
    sampleCount += 1;
    totalLuma += composite;
    if (composite - background >= 80) brightDeltaCount += 1;
  }

  VproofV2StageMetrics finish() => VproofV2StageMetrics(
        stage: stage.id,
        sampleCount: sampleCount,
        brightDeltaCount: brightDeltaCount,
        meanCompositeLuma: sampleCount == 0 ? 0 : totalLuma / sampleCount,
      );

  double _luma(double r, double g, double b) =>
      0.2126 * r + 0.7152 * g + 0.0722 * b;
}
