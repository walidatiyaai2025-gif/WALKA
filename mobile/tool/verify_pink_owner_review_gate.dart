import 'dart:io';

import 'src/pink_owner_review_gate.dart';

void main(List<String> args) {
  String root = '.';
  String? jsonPath;
  bool report = false;
  bool enforce = false;

  for (int i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--root':
        if (i + 1 >= args.length) _usage('Missing value after --root');
        root = args[++i];
        break;
      case '--json':
        if (i + 1 >= args.length) _usage('Missing value after --json');
        jsonPath = args[++i];
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
        _usage('Unknown argument: ${args[i]}');
    }
  }

  final Directory requestedRoot = Directory(root).absolute;
  if (!requestedRoot.existsSync()) {
    stderr.writeln('PINK OWNER REVIEW invalid root: ${requestedRoot.path}');
    exitCode = 64;
    return;
  }

  final Directory mobileRoot =
      Directory(requestedRoot.resolveSymbolicLinksSync());
  final PinkOwnerReviewReport result =
      PinkOwnerReviewGateAuditor(mobileRoot: mobileRoot).audit();

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
    for (final PinkOwnerReviewViolation violation in result.violations) {
      stdout.writeln('- BLOCKER ${violation.code}: ${violation.message}');
    }
  }

  if (enforce && !result.gateReady) {
    stderr.writeln(
      'Pink owner-review enforcement failed: '
      '${result.blockerCount} blocker(s).',
    );
    exitCode = 1;
  }
}

Never _usage(String message) {
  stderr.writeln(message);
  stderr.writeln(
    'Usage: dart run tool/verify_pink_owner_review_gate.dart '
    '[--root <mobile-root>] [--json <path>] [--report] [--enforce]',
  );
  exit(64);
}

void _help() {
  stdout.writeln(
    'Validate the WALKA Pink owner visual-acceptance boundary.\n'
    '--root <path>   Mobile project root (default: .)\n'
    '--json <path>   Write deterministic JSON report atomically\n'
    '--report        Print human-readable summary\n'
    '--enforce       Exit 1 on candidate/receipt/admission inconsistency.\n'
    'Automation can validate a review candidate, but production admission is '
    'forbidden until an explicit owner ACCEPTED receipt binds to the exact '
    'candidate SHA.',
  );
}
