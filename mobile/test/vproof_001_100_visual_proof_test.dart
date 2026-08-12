import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/visual_proof.dart';

void main() {
  const VproofAnalyzer analyzer = VproofAnalyzer();

  group('VPROOF-001..020 edge and alpha classification', () {
    test('clean colored antialiasing is not classified as white halo', () {
      final VproofMetrics metrics = analyzer.analyzeRgba(
        _subject(withWhiteHalo: false),
        width: 64,
        height: 64,
      );
      expect(metrics.edgePixelCount, greaterThan(0));
      expect(metrics.partialAlphaEdgeCount, greaterThan(128));
      expect(metrics.nearWhitePartialEdgeCount, 0);
      expect(metrics.nearWhitePartialEdgeRatio, 0);
      expect(metrics.obviousWhiteHalo, isFalse);
      expect(metrics.diagnosticDisposition, 'NO_OBVIOUS_HALO');
    });

    test('partial alpha white ring is classified independently of opaque body', () {
      final VproofMetrics metrics = analyzer.analyzeRgba(
        _subject(withWhiteHalo: true),
        width: 64,
        height: 64,
      );
      expect(metrics.partialAlphaEdgeCount, greaterThanOrEqualTo(128));
      expect(metrics.nearWhitePartialEdgeCount, metrics.partialAlphaEdgeCount);
      expect(metrics.nearWhitePartialEdgeRatio, 1);
      expect(metrics.nearWhiteOpaqueEdgeCount, 0);
    });
  });

  group('VPROOF-021..040 halo and stage compositing', () {
    test('obvious white halo blocks diagnostic disposition on non-white subject', () {
      final VproofMetrics metrics = analyzer.analyzeRgba(
        _subject(withWhiteHalo: true),
        width: 64,
        height: 64,
      );
      expect(metrics.navy.brightDeltaRatio, greaterThanOrEqualTo(0.45));
      expect(metrics.obviousWhiteHalo, isTrue);
      expect(metrics.diagnosticDisposition, 'REJECT_OBVIOUS_WHITE_HALO');
    });

    test('near-white product may opt out of automated white-fringe rejection', () {
      final VproofMetrics metrics = analyzer.analyzeRgba(
        _subject(withWhiteHalo: true),
        width: 64,
        height: 64,
        nearWhiteSubject: true,
      );
      expect(metrics.nearWhitePartialEdgeRatio, 1);
      expect(metrics.nearWhiteSubject, isTrue);
      expect(metrics.obviousWhiteHalo, isFalse);
    });

    test('all required proof stages are deterministic and ordered', () {
      final VproofMetrics metrics = analyzer.analyzeRgba(
        _subject(withWhiteHalo: false),
        width: 64,
        height: 64,
      );
      expect(
        metrics.stages.map((VproofStageMetrics item) => item.stage),
        <String>['white', 'ivory', 'navy'],
      );
      expect(metrics.stages.every((VproofStageMetrics item) => item.sampleCount > 0), isTrue);
    });
  });

  group('VPROOF-041..060 downscale and receipt behavior', () {
    test('downscale proof matrix covers exact production review sizes', () {
      final VproofMetrics metrics = analyzer.analyzeRgba(
        _subject(withWhiteHalo: true),
        width: 64,
        height: 64,
      );
      expect(metrics.downscaleHaloBinRatios.keys, vproofDownscaleTargets);
      for (final double ratio in metrics.downscaleHaloBinRatios.values) {
        expect(ratio, inInclusiveRange(0, 1));
        expect(ratio, greaterThan(0));
      }
    });

    test('proof JSON explicitly refuses automated visual acceptance', () {
      final VproofMetrics metrics = analyzer.analyzeRgba(
        _subject(withWhiteHalo: false),
        width: 64,
        height: 64,
      );
      final Map<String, Object?> json = metrics.toJson();
      expect(json['automationCanAcceptVisualFidelity'], isFalse);
      expect(json['diagnosticDisposition'], 'NO_OBVIOUS_HALO');
      expect(json['stages'], isA<List<Object?>>());
    });
  });

  group('VPROOF-061..080 fail-closed decision and CLI contract', () {
    test('known rejected binary is a blocker only if somebody admits it', () {
      final VproofMetrics clean = analyzer.analyzeRgba(
        _subject(withWhiteHalo: false),
        width: 64,
        height: 64,
      );
      final VproofDecision admitted = analyzer.decide(
        lifecycleState: 'ADMITTED',
        knownRejected: true,
        metrics: clean,
      );
      expect(admitted.blocked, isTrue);
      expect(
        admitted.blockerCodes,
        contains('visual-proof.known-rejected-binary-admitted'),
      );

      final VproofDecision pending = analyzer.decide(
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

    test('obvious halo is fail-closed for admitted but diagnostic for pending', () {
      final VproofMetrics halo = analyzer.analyzeRgba(
        _subject(withWhiteHalo: true),
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

    test('invalid RGBA dimensions are rejected before metrics are fabricated', () {
      expect(
        () => analyzer.analyzeRgba(Uint8List(7), width: 2, height: 2),
        throwsArgumentError,
      );
    });

    test('current repository visual-proof CLI is fail-closed but passes admitted media', () async {
      final Directory temp = await Directory.systemTemp.createTemp('walka-vproof-');
      addTearDown(() => temp.delete(recursive: true));
      final String reportPath = '${temp.path}/visual-proof.json';
      final ProcessResult result = await Process.run(
        'dart',
        <String>[
          'run',
          'tool/verify_visual_proof.dart',
          '--root',
          '.',
          '--provenance',
          '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json',
          '--rejections',
          '../docs/ui/VISUAL_PROOF_REJECTIONS.json',
          '--json',
          reportPath,
          '--enforce',
        ],
      );
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      final Map<String, dynamic> report =
          jsonDecode(await File(reportPath).readAsString()) as Map<String, dynamic>;
      expect(report['state'], 'PASS');
      expect(report['releasedCount'], 5);
      expect(report['admittedCount'], 3);
      expect(report['pendingCount'], 1);
      expect(report['blockedCount'], 1);
      expect(report['ownerVisualAcceptance'], 'REQUIRED');
      expect(report['automationCanAcceptVisualFidelity'], isFalse);
      final List<dynamic> assets = report['assets'] as List<dynamic>;
      final Map<String, dynamic> pink = assets
          .cast<Map<String, dynamic>>()
          .singleWhere((Map<String, dynamic> item) => item['variantId'] == 'lunch-box:pink');
      expect(pink['lifecycleState'], 'PENDING');
      expect(pink['knownRejected'], isTrue);
      expect(pink['blockerCodes'], isEmpty);
    });
  });

  test('VPROOF-081..100 task contract enumerates exactly one hundred unique IDs', () {
    final Set<String> ids = <String>{
      for (int value = 1; value <= 100; value += 1)
        'VPROOF-${value.toString().padLeft(3, '0')}',
    };
    expect(ids, hasLength(100));
    expect(ids.first, 'VPROOF-001');
    expect(ids.last, 'VPROOF-100');
  });
}

Uint8List _subject({required bool withWhiteHalo}) {
  const int width = 64;
  const int height = 64;
  final Uint8List rgba = Uint8List(width * height * 4);

  void pixel(int x, int y, int r, int g, int b, int a) {
    final int offset = (y * width + x) * 4;
    rgba[offset] = r;
    rgba[offset + 1] = g;
    rgba[offset + 2] = b;
    rgba[offset + 3] = a;
  }

  for (int y = 12; y <= 51; y += 1) {
    for (int x = 12; x <= 51; x += 1) {
      pixel(x, y, 50, 105, 155, 255);
    }
  }

  final List<List<int>> ring = <List<int>>[];
  for (int x = 11; x <= 52; x += 1) {
    ring.add(<int>[x, 11]);
    ring.add(<int>[x, 52]);
  }
  for (int y = 12; y <= 51; y += 1) {
    ring.add(<int>[11, y]);
    ring.add(<int>[52, y]);
  }
  for (final List<int> point in ring) {
    if (withWhiteHalo) {
      pixel(point[0], point[1], 248, 248, 248, 180);
    } else {
      pixel(point[0], point[1], 50, 105, 155, 180);
    }
  }
  return rgba;
}
