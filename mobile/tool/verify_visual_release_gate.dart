import 'dart:io';

import 'src/visual_release_gate.dart';

void main(List<String> args) {
  String root = '.';
  String productionReportPath = 'production-asset-readiness.json';
  String? jsonPath;
  String? visualInputDigest;
  String? releaseInputDigest;
  bool report = false;
  bool enforce = false;

  for (int index = 0; index < args.length; index += 1) {
    switch (args[index]) {
      case '--root':
        if (index + 1 >= args.length) _usage('Missing value after --root');
        root = args[++index];
        break;
      case '--production-report':
        if (index + 1 >= args.length) {
          _usage('Missing value after --production-report');
        }
        productionReportPath = args[++index];
        break;
      case '--json':
        if (index + 1 >= args.length) _usage('Missing value after --json');
        jsonPath = args[++index];
        break;
      case '--visual-input-digest':
        if (index + 1 >= args.length) {
          _usage('Missing value after --visual-input-digest');
        }
        visualInputDigest = args[++index];
        break;
      case '--release-input-digest':
        if (index + 1 >= args.length) {
          _usage('Missing value after --release-input-digest');
        }
        releaseInputDigest = args[++index];
        break;
      case '--report':
        report = true;
        break;
      case '--enforce':
        enforce = true;
        break;
      case '--help':
      case '-h':
        _help();
        return;
      default:
        _usage('Unknown argument: ${args[index]}');
    }
  }

  final Directory requestedRoot = Directory(root).absolute;
  if (!requestedRoot.existsSync()) {
    stderr.writeln('Visual release gate invalid root: ${requestedRoot.path}');
    exitCode = 64;
    return;
  }
  final Directory mobileRoot =
      Directory(requestedRoot.resolveSymbolicLinksSync());
  final File productionReport = File(productionReportPath).isAbsolute
      ? File(productionReportPath)
      : File('${mobileRoot.path}/$productionReportPath');

  final VisualReleaseGateReport result = VisualReleaseGateAuditor(
    mobileRoot: mobileRoot,
    productionReport: productionReport,
    currentVisualInputDigest: visualInputDigest,
    currentReleaseInputDigest: releaseInputDigest,
  ).audit();

  if (result.pinkReport.ownerAccepted &&
      result.pinkReport.state != 'OWNER_ACCEPTED_ADMISSION_RECONCILED' &&
      !result.releaseBlockers.contains('pink-admission-not-reconciled')) {
    result.releaseBlockers.add('pink-admission-not-reconciled');
  }
  if (result.grayReport.ownerApproved &&
      !result.grayReport.fullyAdmitted &&
      !result.releaseBlockers.contains('gray-admission-not-reconciled')) {
    result.releaseBlockers.add('gray-admission-not-reconciled');
  }

  if (jsonPath != null) {
    final File output = File(jsonPath);
    output.parent.createSync(recursive: true);
    final File temporary = File('${output.path}.tmp');
    temporary.writeAsStringSync('${result.prettyJson()}\n');
    if (output.existsSync()) output.deleteSync();
    temporary.renameSync(output.path);
  }

  if (report || jsonPath == null) {
    stdout.writeln(result.summary());
    for (final String blocker in result.releaseBlockers) {
      stdout.writeln('- RELEASE BLOCKER $blocker');
    }
    for (final VisualReleaseViolation violation in result.violations) {
      stdout.writeln('- CONTRACT BLOCKER ${violation.code}: ${violation.message}');
    }
  }

  if (enforce && !result.stableReleaseReady) {
    stderr.writeln(
      'Stable owner-visible publication blocked: '
      '${result.releaseBlockers.length} release blocker(s), '
      '${result.contractBlockerCount} contract blocker(s).',
    );
    exitCode = 1;
  }
}

Never _usage(String message) {
  stderr.writeln(message);
  stderr.writeln(
    'Usage: dart run tool/verify_visual_release_gate.dart '
    '[--root <mobile-root>] [--production-report <path>] '
    '[--visual-input-digest <sha256>] [--release-input-digest <sha256>] '
    '[--json <path>] [--report] [--enforce]',
  );
  exit(64);
}

void _help() {
  stdout.writeln(
    'Validate the combined WALKA visual-release owner gate.\n'
    '--root <path>                  Mobile project root (default: .)\n'
    '--production-report <path>     PAV JSON report path\n'
    '--visual-input-digest <sha>    Digest for mobile/lib + assets + pubspec\n'
    '--release-input-digest <sha>   Digest for app + lock + branding + toolchain + release workflow\n'
    '--json <path>                  Write deterministic JSON report\n'
    '--report                       Print human-readable summary\n'
    '--enforce                      Exit 1 unless stable publication is fully authorized.\n'
    'Report mode treats truthful PENDING/BLOCKED owner decisions as valid contracts.',
  );
}
