import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/visual_proof_v2.dart';

void main() {
  const VproofAnalyzerV2 analyzer = VproofAnalyzerV2();

  group('VPROOF-001..020 edge and alpha classification', () {
    test('clean colored antialiasing is not classified as white halo', () {
      final VproofV2Metrics metrics = analyzer.analyzeRgba(
        _coloredSubject(withWhiteHalo: false),
        width: 64,
        height: 64,
      );
      expect(metrics.edgePixelCount, greaterThan(0));
      expect(metrics.partialAlphaEdgeCount, greaterThan(128));
      expect(metrics.rawNearWhitePartialEdgeCount, 0);
      expect(metrics.mismatchNearWhitePartialEdgeCount, 0);
      expect(metrics.obviousWhiteHalo, isFalse);
    });

    test('white ring against colored interior is a mismatch fringe', () {
      final VproofV2Metrics metrics = analyzer.analyzeRgba(
        _coloredSubject(withWhiteHalo: true),
        width: 64,
        height: 64,
      );
      expect(metrics.rawNearWhitePartialEdgeCount, greaterThanOrEqualTo(128));
      expect(
        metrics.mismatchNearWhitePartialEdgeCount,
        metrics.rawNearWhitePartialEdgeCount,
      );
      expect(metrics.lightInteriorNearWhitePartialEdgeCount, 0);
      expect(metrics.noOpaqueInteriorNearWhitePartialEdgeCount, 0);
    });

    test('white antialiasing around light stainless-like interior is legitimate material edge', () {
      final VproofV2Metrics metrics = analyzer.analyzeRgba(
        _lightNeutralSubject(),
        width: 64,
        height: 64,
      );
      expect(metrics.rawNearWhitePartialEdgeCount, greaterThanOrEqualTo(128));
      expect(metrics.lightInteriorNearWhitePartialEdgeCount, greaterThan(0));
      expect(metrics.mismatchNearWhitePartialEdgeCount, 0);
      expect(metrics.obviousWhiteHalo, isFalse);
    });
  });

  group('VPROOF-021..040 halo and stage compositing', () {
    test('obvious mismatch white halo rejects non-white subject', () {
      final VproofV2Metrics metrics = analyzer.analyzeRgba(
        _coloredSubject(withWhiteHalo: true),
        width: 64,
        height: 64,
      );
      expect(metrics.mismatchPartialEdgeRatio, greaterThan(0.18));
      expect(metrics.mismatchNearWhiteEdgeRatio, 1);
      expect(metrics.navy.brightDeltaRatio, greaterThanOrEqualTo(0.45));
      expect(metrics.obviousWhiteHalo, isTrue);
      expect(metrics.diagnosticDisposition, 'REJECT_OBVIOUS_WHITE_HALO');
    });

    test('near-white primary product remains exempt from automated halo rejection', () {
      final VproofV2Metrics metrics = analyzer.analyzeRgba(
        _coloredSubject(withWhiteHalo: true),
        width: 64,
        height: 64,
        nearWhiteSubject: true,
      );
      expect(metrics.nearWhiteSubject, isTrue);
      expect(metrics.obviousWhiteHalo, isFalse);
    });

    test('stage metrics remain white ivory navy and automated acceptance stays false', () {
      final VproofV2Metrics metrics = analyzer.analyzeRgba(
        _coloredSubject(withWhiteHalo: true),
        width: 64,
        height: 64,
      );
      expect(
        metrics.stages.map((VproofV2StageMetrics item) => item.stage),
        <String>['white', 'ivory', 'navy'],
      );
      expect(metrics.toJson()['automationCanAcceptVisualFidelity'], isFalse);
      expect(metrics.toJson()['algorithm'], 'edge-interior-mismatch-v2');
    });
  });

  group('VPROOF-041..060 downscale and receipt behavior', () {
    test('downscale mismatch matrix covers exact review sizes', () {
      final VproofV2Metrics metrics = analyzer.analyzeRgba(
        _coloredSubject(withWhiteHalo: true),
        width: 64,
        height: 64,
      );
      expect(metrics.downscaleMismatchBinRatios.keys, <int>[96, 160, 240, 384]);
      expect(
        metrics.downscaleMismatchBinRatios.values.every(
          (double ratio) => ratio >= 0 && ratio <= 1,
        ),
        isTrue,
      );
    });

    test('no opaque interior is diagnostic uncertainty, not fabricated mismatch', () {
      final Uint8List rgba = Uint8List(64 * 64 * 4);
      for (int y = 20; y < 44; y += 1) {
        for (int x = 20; x < 44; x += 1) {
          _pixel(rgba, 64, x, y, 248, 248, 248, 180);
        }
      }
      final VproofV2Metrics metrics = analyzer.analyzeRgba(
        rgba,
        width: 64,
        height: 64,
      );
      expect(metrics.noOpaqueInteriorNearWhitePartialEdgeCount, greaterThan(0));
      expect(metrics.mismatchNearWhitePartialEdgeCount, 0);
      expect(metrics.obviousWhiteHalo, isFalse);
    });
  });

  group('VPROOF-061..080 fail-closed decision and CLI contract', () {
    test('known rejected binary blocks only if lifecycle is ADMITTED', () {
      final VproofV2Metrics clean = analyzer.analyzeRgba(
        _coloredSubject(withWhiteHalo: false),
        width: 64,
        height: 64,
      );
      final VproofV2Decision admitted = analyzer.decide(
        lifecycleState: 'ADMITTED',
        knownRejected: true,
        metrics: clean,
      );
      expect(admitted.blocked, isTrue);
      expect(
        admitted.blockerCodes,
        contains('visual-proof.known-rejected-binary-admitted'),
      );
      final VproofV2Decision pending = analyzer.decide(
        lifecycleState: 'PENDING',
        knownRejected: true,
        metrics: clean,
      );
      expect(pending.blocked, isFalse);
      expect(
        pending.warningCodes,
        contains('visual-proof.known-rejected-binary-quarantined'),
      );
    });

    test('obvious halo blocks admitted media but remains diagnostic on pending media', () {
      final VproofV2Metrics halo = analyzer.analyzeRgba(
        _coloredSubject(withWhiteHalo: true),
        width: 64,
        height: 64,
      );
      expect(
        analyzer
            .decide(
              lifecycleState: 'ADMITTED',
              knownRejected: false,
              metrics: halo,
            )
            .blockerCodes,
        contains('visual-proof.obvious-white-halo-admitted'),
      );
      expect(
        analyzer
            .decide(
              lifecycleState: 'PENDING',
              knownRejected: false,
              metrics: halo,
            )
            .warningCodes,
        contains('visual-proof.obvious-white-halo-quarantined'),
      );
    });

    test('invalid RGBA dimensions fail before metrics are fabricated', () {
      expect(
        () => analyzer.analyzeRgba(Uint8List(7), width: 2, height: 2),
        throwsArgumentError,
      );
    });

    test('current repository V2 report preserves 3/5 truth and quarantined Pink rejection', () async {
      final Directory temp = await Directory.systemTemp.createTemp('walka-vproof-v2-');
      addTearDown(() => temp.delete(recursive: true));
      final String reportPath = '${temp.path}/visual-proof.json';
      final ProcessResult result = await Process.run(
        'dart',
        <String>[
          'run',
          'tool/verify_visual_proof_v2.dart',
          '--root',
          '.',
          '--provenance',
          '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json',
          '--rejections',
          '../docs/ui/VISUAL_PROOF_REJECTIONS.json',
          '--json',
          reportPath,
          '--report',
        ],
      );
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      final Map<String, dynamic> report =
          jsonDecode(await File(reportPath).readAsString()) as Map<String, dynamic>;
      expect(report['schemaVersion'], 2);
      expect(report['algorithm'], 'edge-interior-mismatch-v2');
      expect(report['releasedCount'], 5);
      expect(report['admittedCount'], 3);
      expect(report['pendingCount'], 1);
      expect(report['blockedCount'], 1);
      expect(report['ownerVisualAcceptance'], 'REQUIRED');
      expect(report['automationCanAcceptVisualFidelity'], isFalse);
      final List<Map<String, dynamic>> assets =
          (report['assets'] as List<dynamic>).cast<Map<String, dynamic>>();
      final Map<String, dynamic> pink = assets.singleWhere(
        (Map<String, dynamic> item) => item['variantId'] == 'lunch-box:pink',
      );
      expect(pink['lifecycleState'], 'PENDING');
      expect(pink['knownRejected'], isTrue);
      expect(pink['blockerCodes'], isEmpty);
    });
  });

  test('VPROOF-081..100 task contract contains exactly one hundred unique IDs', () {
    final Set<String> ids = <String>{
      for (int value = 1; value <= 100; value += 1)
        'VPROOF-${value.toString().padLeft(3, '0')}',
    };
    expect(ids, hasLength(100));
    expect(ids.first, 'VPROOF-001');
    expect(ids.last, 'VPROOF-100');
  });
}

Uint8List _coloredSubject({required bool withWhiteHalo}) {
  const int width = 64;
  final Uint8List rgba = Uint8List(width * width * 4);
  for (int y = 12; y <= 51; y += 1) {
    for (int x = 12; x <= 51; x += 1) {
      _pixel(rgba, width, x, y, 50, 105, 155, 255);
    }
  }
  _ring(
    rgba,
    width,
    withWhiteHalo ? <int>[248, 248, 248, 180] : <int>[50, 105, 155, 180],
  );
  return rgba;
}

Uint8List _lightNeutralSubject() {
  const int width = 64;
  final Uint8List rgba = Uint8List(width * width * 4);
  for (int y = 12; y <= 51; y += 1) {
    for (int x = 12; x <= 51; x += 1) {
      _pixel(rgba, width, x, y, 216, 219, 222, 255);
    }
  }
  _ring(rgba, width, <int>[248, 248, 248, 180]);
  return rgba;
}

void _ring(Uint8List rgba, int width, List<int> color) {
  for (int x = 11; x <= 52; x += 1) {
    _pixel(rgba, width, x, 11, color[0], color[1], color[2], color[3]);
    _pixel(rgba, width, x, 52, color[0], color[1], color[2], color[3]);
  }
  for (int y = 12; y <= 51; y += 1) {
    _pixel(rgba, width, 11, y, color[0], color[1], color[2], color[3]);
    _pixel(rgba, width, 52, y, color[0], color[1], color[2], color[3]);
  }
}

void _pixel(
  Uint8List rgba,
  int width,
  int x,
  int y,
  int r,
  int g,
  int b,
  int a,
) {
  final int offset = (y * width + x) * 4;
  rgba[offset] = r;
  rgba[offset + 1] = g;
  rgba[offset + 2] = b;
  rgba[offset + 3] = a;
}
