import 'dart:typed_data';

import 'pav_models.dart';

const int vproofAlphaVisible = 8;
const int vproofAlphaOpaque = 245;
const int vproofNearWhiteFloor = 225;
const int vproofNearWhiteChroma = 28;
const int vproofMinimumHaloSamples = 128;
const double vproofObviousHaloRatio = 0.55;
const List<int> vproofDownscaleTargets = <int>[96, 160, 240, 384];

class VproofStage {
  const VproofStage(this.id, this.r, this.g, this.b);

  final String id;
  final int r;
  final int g;
  final int b;

  static const VproofStage white = VproofStage('white', 255, 255, 255);
  static const VproofStage ivory = VproofStage('ivory', 248, 246, 239);
  static const VproofStage navy = VproofStage('navy', 0, 51, 102);
  static const List<VproofStage> all = <VproofStage>[white, ivory, navy];
}

class VproofStageMetrics {
  const VproofStageMetrics({
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

class VproofMetrics {
  const VproofMetrics({
    required this.width,
    required this.height,
    required this.edgePixelCount,
    required this.partialAlphaEdgeCount,
    required this.nearWhitePartialEdgeCount,
    required this.nearWhiteOpaqueEdgeCount,
    required this.nearWhiteSubject,
    required this.stages,
    required this.downscaleHaloBinRatios,
  });

  final int width;
  final int height;
  final int edgePixelCount;
  final int partialAlphaEdgeCount;
  final int nearWhitePartialEdgeCount;
  final int nearWhiteOpaqueEdgeCount;
  final bool nearWhiteSubject;
  final List<VproofStageMetrics> stages;
  final Map<int, double> downscaleHaloBinRatios;

  double get nearWhitePartialEdgeRatio => partialAlphaEdgeCount == 0
      ? 0
      : nearWhitePartialEdgeCount / partialAlphaEdgeCount;

  double get nearWhiteOpaqueEdgeRatio => edgePixelCount == 0
      ? 0
      : nearWhiteOpaqueEdgeCount / edgePixelCount;

  VproofStageMetrics get navy =>
      stages.firstWhere((VproofStageMetrics item) => item.stage == 'navy');

  bool get obviousWhiteHalo =>
      !nearWhiteSubject &&
      nearWhitePartialEdgeCount >= vproofMinimumHaloSamples &&
      nearWhitePartialEdgeRatio >= vproofObviousHaloRatio &&
      navy.brightDeltaRatio >= 0.45;

  String get diagnosticDisposition =>
      obviousWhiteHalo ? 'REJECT_OBVIOUS_WHITE_HALO' : 'NO_OBVIOUS_HALO';

  Map<String, Object?> toJson() => <String, Object?>{
        'width': width,
        'height': height,
        'edgePixelCount': edgePixelCount,
        'partialAlphaEdgeCount': partialAlphaEdgeCount,
        'nearWhitePartialEdgeCount': nearWhitePartialEdgeCount,
        'nearWhitePartialEdgeRatio': nearWhitePartialEdgeRatio,
        'nearWhiteOpaqueEdgeCount': nearWhiteOpaqueEdgeCount,
        'nearWhiteOpaqueEdgeRatio': nearWhiteOpaqueEdgeRatio,
        'nearWhiteSubject': nearWhiteSubject,
        'stages': stages.map((VproofStageMetrics item) => item.toJson()).toList(),
        'downscaleHaloBinRatios': <String, double>{
          for (final MapEntry<int, double> entry
              in downscaleHaloBinRatios.entries)
            entry.key.toString(): entry.value,
        },
        'obviousWhiteHalo': obviousWhiteHalo,
        'diagnosticDisposition': diagnosticDisposition,
        'automationCanAcceptVisualFidelity': false,
      };
}

class VproofDecision {
  const VproofDecision({
    required this.lifecycleState,
    required this.knownRejected,
    required this.metrics,
    required this.blockerCodes,
    required this.warningCodes,
  });

  final String lifecycleState;
  final bool knownRejected;
  final VproofMetrics metrics;
  final List<String> blockerCodes;
  final List<String> warningCodes;

  bool get blocked => blockerCodes.isNotEmpty;

  Map<String, Object?> toJson() => <String, Object?>{
        'lifecycleState': lifecycleState,
        'knownRejected': knownRejected,
        'blocked': blocked,
        'blockerCodes': blockerCodes,
        'warningCodes': warningCodes,
        'metrics': metrics.toJson(),
      };
}

class VproofAnalyzer {
  const VproofAnalyzer();

  VproofMetrics analyzeInspection(
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

  VproofMetrics analyzeRgba(
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
    int nearWhitePartialEdgeCount = 0;
    int nearWhiteOpaqueEdgeCount = 0;
    final Map<String, _StageAccumulator> stageAccumulators =
        <String, _StageAccumulator>{
      for (final VproofStage stage in VproofStage.all)
        stage.id: _StageAccumulator(stage),
    };
    final Map<int, Set<int>> partialBins = <int, Set<int>>{
      for (final int size in vproofDownscaleTargets) size: <int>{},
    };
    final Map<int, Set<int>> haloBins = <int, Set<int>>{
      for (final int size in vproofDownscaleTargets) size: <int>{},
    };

    for (int y = 0; y < height; y += 1) {
      for (int x = 0; x < width; x += 1) {
        final int offset = (y * width + x) * 4;
        final int alpha = rgba[offset + 3];
        if (alpha < vproofAlphaVisible) continue;
        if (!_isEdge(rgba, width: width, height: height, x: x, y: y)) {
          continue;
        }
        edgePixelCount += 1;
        final int r = rgba[offset];
        final int g = rgba[offset + 1];
        final int b = rgba[offset + 2];
        final bool nearWhite = _isNearWhite(r, g, b);
        final bool partial = alpha < vproofAlphaOpaque;
        if (partial) {
          partialAlphaEdgeCount += 1;
          if (nearWhite) nearWhitePartialEdgeCount += 1;
          for (final int size in vproofDownscaleTargets) {
            final int tx = (x * size) ~/ width;
            final int ty = (y * size) ~/ height;
            final int bin = ty * size + tx;
            partialBins[size]!.add(bin);
            if (nearWhite) haloBins[size]!.add(bin);
          }
        } else if (nearWhite) {
          nearWhiteOpaqueEdgeCount += 1;
        }

        if (partial) {
          for (final _StageAccumulator accumulator
              in stageAccumulators.values) {
            accumulator.add(r, g, b, alpha);
          }
        }
      }
    }

    final Map<int, double> downscale = <int, double>{};
    for (final int size in vproofDownscaleTargets) {
      final int denominator = partialBins[size]!.length;
      downscale[size] = denominator == 0
          ? 0
          : haloBins[size]!.length / denominator;
    }

    return VproofMetrics(
      width: width,
      height: height,
      edgePixelCount: edgePixelCount,
      partialAlphaEdgeCount: partialAlphaEdgeCount,
      nearWhitePartialEdgeCount: nearWhitePartialEdgeCount,
      nearWhiteOpaqueEdgeCount: nearWhiteOpaqueEdgeCount,
      nearWhiteSubject: nearWhiteSubject,
      stages: stageAccumulators.values
          .map((_StageAccumulator item) => item.finish())
          .toList(growable: false),
      downscaleHaloBinRatios: downscale,
    );
  }

  VproofDecision decide({
    required String lifecycleState,
    required bool knownRejected,
    required VproofMetrics metrics,
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

    return VproofDecision(
      lifecycleState: normalized,
      knownRejected: knownRejected,
      metrics: metrics,
      blockerCodes: blockers,
      warningCodes: warnings,
    );
  }

  bool _isEdge(
    Uint8List rgba, {
    required int width,
    required int height,
    required int x,
    required int y,
  }) {
    final int offset = (y * width + x) * 4;
    final int alpha = rgba[offset + 3];
    if (alpha < vproofAlphaOpaque) return true;
    const List<List<int>> neighbors = <List<int>>[
      <int>[-1, 0],
      <int>[1, 0],
      <int>[0, -1],
      <int>[0, 1],
    ];
    for (final List<int> delta in neighbors) {
      final int nx = x + delta[0];
      final int ny = y + delta[1];
      if (nx < 0 || nx >= width || ny < 0 || ny >= height) return true;
      final int neighborAlpha = rgba[(ny * width + nx) * 4 + 3];
      if (neighborAlpha < vproofAlphaVisible) return true;
    }
    return false;
  }

  bool _isNearWhite(int r, int g, int b) {
    final int minimum = r < g ? (r < b ? r : b) : (g < b ? g : b);
    final int maximum = r > g ? (r > b ? r : b) : (g > b ? g : b);
    return minimum >= vproofNearWhiteFloor &&
        maximum - minimum <= vproofNearWhiteChroma;
  }
}

class _StageAccumulator {
  _StageAccumulator(this.stage);

  final VproofStage stage;
  int sampleCount = 0;
  int brightDeltaCount = 0;
  double totalLuma = 0;

  void add(int r, int g, int b, int alpha) {
    final double a = alpha / 255.0;
    final double cr = r * a + stage.r * (1 - a);
    final double cg = g * a + stage.g * (1 - a);
    final double cb = b * a + stage.b * (1 - a);
    final double compositeLuma = _luma(cr, cg, cb);
    final double backgroundLuma =
        _luma(stage.r.toDouble(), stage.g.toDouble(), stage.b.toDouble());
    sampleCount += 1;
    totalLuma += compositeLuma;
    if (compositeLuma - backgroundLuma >= 80) brightDeltaCount += 1;
  }

  VproofStageMetrics finish() => VproofStageMetrics(
        stage: stage.id,
        sampleCount: sampleCount,
        brightDeltaCount: brightDeltaCount,
        meanCompositeLuma: sampleCount == 0 ? 0 : totalLuma / sampleCount,
      );

  double _luma(double r, double g, double b) =>
      0.2126 * r + 0.7152 * g + 0.0722 * b;
}
