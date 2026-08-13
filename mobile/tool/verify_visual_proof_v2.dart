import 'dart:convert';
import 'dart:io';

import 'src/pav_models.dart';
import 'src/png_asset_inspector.dart';
import 'src/visual_proof_v2.dart';

Future<void> main(List<String> args) async {
  final _Args parsed;
  try {
    parsed = _Args.parse(args);
  } on FormatException catch (error) {
    stderr.writeln('VPROOF usage error: ${error.message}');
    exitCode = 64;
    return;
  }

  final Directory root = Directory(parsed.root);
  final File provenanceFile = File(parsed.provenance);
  final File rejectionFile = File(parsed.rejections);
  if (!root.existsSync() ||
      !provenanceFile.existsSync() ||
      !rejectionFile.existsSync()) {
    stderr.writeln('VPROOF input missing: root/provenance/rejection ledger must exist.');
    exitCode = 66;
    return;
  }

  final Map<String, dynamic> provenance =
      jsonDecode(await provenanceFile.readAsString()) as Map<String, dynamic>;
  final Map<String, dynamic> rejectionLedger =
      jsonDecode(await rejectionFile.readAsString()) as Map<String, dynamic>;
  final List<dynamic> rawVariants =
      provenance['variants'] as List<dynamic>? ?? <dynamic>[];
  final List<Map<String, dynamic>> rejections =
      (rejectionLedger['rejections'] as List<dynamic>? ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .toList(growable: false);

  const PavPngInspector inspector = PavPngInspector();
  const VproofAnalyzerV2 analyzer = VproofAnalyzerV2();
  final List<Map<String, Object?>> assets = <Map<String, Object?>>[];
  int blockerCount = 0;
  int warningCount = 0;
  int admittedCount = 0;
  int pendingCount = 0;
  int blockedCount = 0;

  for (final Map<String, dynamic> variant
      in rawVariants.cast<Map<String, dynamic>>()) {
    final String variantId = variant['variantId'] as String? ?? 'unknown';
    final String lifecycle =
        (variant['lifecycleState'] as String? ?? 'PENDING').toUpperCase();
    if (lifecycle == 'ADMITTED') admittedCount += 1;
    if (lifecycle == 'PENDING') pendingCount += 1;
    if (lifecycle == 'BLOCKED') blockedCount += 1;

    final String canonicalPath = variant['canonicalPath'] as String? ?? '';
    final File assetFile = File('${root.path}/$canonicalPath');
    final List<String> structuralBlockers = <String>[];
    final List<String> structuralWarnings = <String>[];
    PavPngInspection? inspection;
    VproofV2Metrics? metrics;
    bool knownRejected = false;

    if (!assetFile.existsSync()) {
      _route(
        lifecycle,
        'visual-proof.asset-missing',
        structuralBlockers,
        structuralWarnings,
      );
    } else {
      inspection = inspector.inspect(await assetFile.readAsBytes());
      if (inspection.rgba == null ||
          inspection.width == null ||
          inspection.height == null) {
        _route(
          lifecycle,
          'visual-proof.asset-not-decodable-rgba',
          structuralBlockers,
          structuralWarnings,
        );
      } else {
        metrics = analyzer.analyzeInspection(
          inspection,
          nearWhiteSubject: variantId == 'drawer-organizer:white',
        );
        knownRejected = rejections.any(
          (Map<String, dynamic> record) => _matchesKnownRejection(
            record,
            variant: variant,
            inspection: inspection!,
          ),
        );
      }
      if (inspection.hasBlockers) {
        _route(
          lifecycle,
          'visual-proof.png-contract-blocked',
          structuralBlockers,
          structuralWarnings,
        );
      }
    }

    VproofV2Decision? decision;
    if (metrics != null) {
      decision = analyzer.decide(
        lifecycleState: lifecycle,
        knownRejected: knownRejected,
        metrics: metrics,
      );
    }
    final List<String> assetBlockers = <String>[
      ...structuralBlockers,
      ...?decision?.blockerCodes,
    ];
    final List<String> assetWarnings = <String>[
      ...structuralWarnings,
      ...?decision?.warningCodes,
    ];
    blockerCount += assetBlockers.length;
    warningCount += assetWarnings.length;

    assets.add(<String, Object?>{
      'variantId': variantId,
      'canonicalPath': canonicalPath,
      'lifecycleState': lifecycle,
      'binaryPresent': assetFile.existsSync(),
      'knownRejected': knownRejected,
      if (inspection != null) ...<String, Object?>{
        'bytes': inspection.bytes,
        'pavFingerprint': inspection.fingerprint,
        'pngBlockerCount': inspection.blockerCount,
        'pngWarningCount': inspection.warningCount,
        if (inspection.alphaMetrics?.bounds != null)
          'alphaBoundingBox': <int>[
            inspection.alphaMetrics!.bounds!.left,
            inspection.alphaMetrics!.bounds!.top,
            inspection.alphaMetrics!.bounds!.right,
            inspection.alphaMetrics!.bounds!.bottom,
          ],
      },
      if (metrics != null) 'proof': metrics.toJson(),
      'blockerCodes': assetBlockers,
      'warningCodes': assetWarnings,
      'ownerVisualAcceptance': 'REQUIRED',
      'automationCanAcceptVisualFidelity': false,
    });
  }

  final Map<String, Object?> report = <String, Object?>{
    'schemaVersion': 2,
    'algorithm': 'edge-interior-mismatch-v2',
    'mode': parsed.enforce ? 'ENFORCE' : 'REPORT',
    'state': blockerCount == 0 ? 'PASS' : 'BLOCKED',
    'blockerCount': blockerCount,
    'warningCount': warningCount,
    'admittedCount': admittedCount,
    'pendingCount': pendingCount,
    'blockedCount': blockedCount,
    'releasedCount': admittedCount + pendingCount + blockedCount,
    'ownerVisualAcceptance': 'REQUIRED',
    'automationCanAcceptVisualFidelity': false,
    'policy': <String, Object?>{
      'obviousContaminationMayBlockAdmission': true,
      'automatedMetricsMayApproveVisualFidelity': false,
      'knownRejectedBinaryMayBeAdmitted': false,
      'legitimateLightMaterialEdgesAreNotWhiteHalo': true,
    },
    'assets': assets,
  };

  final String encoded = '${const JsonEncoder.withIndent('  ').convert(report)}\n';
  if (parsed.jsonPath != null) {
    final File output = File(parsed.jsonPath!);
    await output.parent.create(recursive: true);
    final File temp = File('${output.path}.tmp');
    await temp.writeAsString(encoded, flush: true);
    if (output.existsSync()) await output.delete();
    await temp.rename(output.path);
  }
  if (parsed.report || parsed.jsonPath == null) stdout.write(encoded);

  if (parsed.enforce && blockerCount > 0) {
    stderr.writeln(
      'VPROOF FAIL: $blockerCount admitted-media visual-proof blocker(s).',
    );
    exitCode = 1;
  }
}

void _route(
  String lifecycle,
  String code,
  List<String> blockers,
  List<String> warnings,
) {
  if (lifecycle == 'ADMITTED') {
    blockers.add(code);
  } else {
    warnings.add(code);
  }
}

bool _matchesKnownRejection(
  Map<String, dynamic> record, {
  required Map<String, dynamic> variant,
  required PavPngInspection inspection,
}) {
  if (record['variantId'] != variant['variantId']) return false;
  final String? provenanceSha = variant['sha256'] as String?;
  final String? rejectedSha = record['sha256'] as String?;
  if (provenanceSha != null &&
      rejectedSha != null &&
      provenanceSha == rejectedSha) {
    return true;
  }
  if (record['byteSize'] != inspection.bytes ||
      record['width'] != inspection.width ||
      record['height'] != inspection.height) {
    return false;
  }
  final PavBounds? bounds = inspection.alphaMetrics?.bounds;
  final List<dynamic>? expected = record['alphaBoundingBox'] as List<dynamic>?;
  if (bounds == null || expected == null || expected.length != 4) return false;
  return bounds.left == expected[0] &&
      bounds.top == expected[1] &&
      bounds.right == expected[2] &&
      bounds.bottom == expected[3];
}

class _Args {
  const _Args({
    required this.root,
    required this.provenance,
    required this.rejections,
    required this.report,
    required this.enforce,
    this.jsonPath,
  });

  final String root;
  final String provenance;
  final String rejections;
  final bool report;
  final bool enforce;
  final String? jsonPath;

  static _Args parse(List<String> args) {
    String root = '.';
    String provenance = '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json';
    String rejections = '../docs/ui/VISUAL_PROOF_REJECTIONS.json';
    String? jsonPath;
    bool report = false;
    bool enforce = false;
    for (int index = 0; index < args.length; index += 1) {
      final String arg = args[index];
      String value(String flag) {
        if (index + 1 >= args.length) {
          throw FormatException('$flag requires a value.');
        }
        index += 1;
        return args[index];
      }

      switch (arg) {
        case '--root':
          root = value(arg);
        case '--provenance':
          provenance = value(arg);
        case '--rejections':
          rejections = value(arg);
        case '--json':
          jsonPath = value(arg);
        case '--report':
          report = true;
        case '--enforce':
          enforce = true;
        default:
          throw FormatException('Unknown option: $arg');
      }
    }
    return _Args(
      root: root,
      provenance: provenance,
      rejections: rejections,
      report: report,
      enforce: enforce,
      jsonPath: jsonPath,
    );
  }
}
