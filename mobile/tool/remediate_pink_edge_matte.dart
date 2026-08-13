import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'src/pink_edge_matte.dart';
import 'src/png_asset_inspector.dart';
import 'src/png_rgba_encoder.dart';
import 'src/visual_proof_v2.dart';

Future<void> main(List<String> args) async {
  final _Args parsed;
  try {
    parsed = _Args.parse(args);
  } on FormatException catch (error) {
    stderr.writeln('PINK-REMEDIATE usage error: ${error.message}');
    exitCode = 64;
    return;
  }

  final String normalizedOutput = parsed.output.replaceAll('\\', '/');
  if (normalizedOutput.contains('/assets/products/') ||
      normalizedOutput.startsWith('assets/products/')) {
    stderr.writeln(
      'PINK-REMEDIATE refuses to write directly into canonical product assets.',
    );
    exitCode = 64;
    return;
  }

  final File input = File(parsed.input);
  if (!input.existsSync()) {
    stderr.writeln('PINK-REMEDIATE input does not exist: ${input.path}');
    exitCode = 66;
    return;
  }

  final Uint8List sourceBytes = await input.readAsBytes();
  const PavPngInspector inspector = PavPngInspector();
  final PavPngInspection sourceInspection = inspector.inspect(sourceBytes);
  final Uint8List? sourceRgba = sourceInspection.rgba;
  final int? width = sourceInspection.width;
  final int? height = sourceInspection.height;
  if (sourceRgba == null || width == null || height == null) {
    stderr.writeln('PINK-REMEDIATE requires a decodable 8-bit RGBA PNG.');
    exitCode = 65;
    return;
  }

  const PinkEdgeMatteRemediator remediator = PinkEdgeMatteRemediator();
  final PinkEdgeMatteResult result = remediator.transform(
    sourceRgba,
    width: width,
    height: height,
  );
  _assertAlphaIdentical(sourceRgba, result.rgba);

  final Uint8List candidateBytes = PavRgbaPngEncoder.encode(
    width: width,
    height: height,
    rgba: result.rgba,
  );
  final PavPngInspection candidateInspection = inspector.inspect(candidateBytes);
  if (candidateInspection.rgba == null ||
      candidateInspection.width != width ||
      candidateInspection.height != height) {
    throw StateError('Encoded review candidate failed RGBA round-trip validation.');
  }
  _assertBoundsIdentical(sourceInspection, candidateInspection);

  const VproofAnalyzerV2 analyzer = VproofAnalyzerV2();
  final VproofV2Metrics before = analyzer.analyzeInspection(sourceInspection);
  final VproofV2Metrics after = analyzer.analyzeInspection(candidateInspection);
  if (result.changedPixelCount == 0) {
    throw StateError('No eligible white-matte edge pixels were remediated.');
  }
  if (before.mismatchNearWhitePartialEdgeCount > 0 &&
      after.mismatchNearWhitePartialEdgeCount >=
          before.mismatchNearWhitePartialEdgeCount) {
    throw StateError(
      'Review candidate did not reduce VPROOF near-white mismatch pixels.',
    );
  }

  final File output = File(parsed.output);
  await output.parent.create(recursive: true);
  await output.writeAsBytes(candidateBytes, flush: true);

  final Map<String, Object?> receipt = <String, Object?>{
    'schemaVersion': 1,
    'variantId': 'lunch-box:pink',
    'mode': 'REVIEW_CANDIDATE_ONLY',
    'sourcePath': input.path,
    'outputPath': output.path,
    'sourceBytes': sourceBytes.length,
    'candidateBytes': candidateBytes.length,
    'width': width,
    'height': height,
    'sourcePavFingerprint': sourceInspection.fingerprint,
    'candidatePavFingerprint': candidateInspection.fingerprint,
    'transform': result.toJson(),
    'vproofBefore': before.toJson(),
    'vproofAfter': after.toJson(),
    'alphaBoundingBoxPreserved': true,
    'alphaPlanePreserved': true,
    'canonicalAssetModified': false,
    'runtimeAdmissionChanged': false,
    'ownerVisualAcceptance': 'REQUIRED',
    'automationCanAcceptVisualFidelity': false,
  };
  final File receiptFile = File(parsed.receipt);
  await receiptFile.parent.create(recursive: true);
  await receiptFile.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(receipt)}\n',
    flush: true,
  );

  stdout.writeln(
    'PINK-REMEDIATE candidate written: ${output.path} '
    '(${result.changedPixelCount} edge pixels changed; '
    '${before.mismatchNearWhitePartialEdgeCount} -> '
    '${after.mismatchNearWhitePartialEdgeCount} VPROOF mismatches).',
  );
  stdout.writeln('Owner visual acceptance remains REQUIRED.');
}

void _assertAlphaIdentical(Uint8List before, Uint8List after) {
  if (before.length != after.length) {
    throw StateError('RGBA length changed during remediation.');
  }
  for (int offset = 3; offset < before.length; offset += 4) {
    if (before[offset] != after[offset]) {
      throw StateError('Alpha byte changed at pixel ${offset ~/ 4}.');
    }
  }
}

void _assertBoundsIdentical(
  PavPngInspection before,
  PavPngInspection after,
) {
  final PavBounds? a = before.alphaMetrics?.bounds;
  final PavBounds? b = after.alphaMetrics?.bounds;
  if (a == null || b == null ||
      a.left != b.left ||
      a.top != b.top ||
      a.right != b.right ||
      a.bottom != b.bottom) {
    throw StateError('Visible alpha bounds changed during remediation.');
  }
}

class _Args {
  const _Args({
    required this.input,
    required this.output,
    required this.receipt,
  });

  final String input;
  final String output;
  final String receipt;

  static _Args parse(List<String> args) {
    String input = 'assets/products/lunch/pink.png';
    String output = 'build/pink-remediation/pink-edge-cleaned.png';
    String receipt = 'build/pink-remediation/receipt.json';
    for (int index = 0; index < args.length; index += 1) {
      final String arg = args[index];
      String takeValue() {
        if (index + 1 >= args.length) {
          throw FormatException('Missing value after $arg.');
        }
        index += 1;
        return args[index];
      }

      switch (arg) {
        case '--input':
          input = takeValue();
        case '--output':
          output = takeValue();
        case '--receipt':
          receipt = takeValue();
        default:
          throw FormatException('Unknown argument: $arg');
      }
    }
    if (File(input).absolute.path == File(output).absolute.path) {
      throw const FormatException('Input and output paths must differ.');
    }
    return _Args(input: input, output: output, receipt: receipt);
  }
}
