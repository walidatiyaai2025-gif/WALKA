import 'dart:io';

import 'src/gray_owner_presentation_gate.dart';

void main(List<String> args) {
  String root = '.';
  String? jsonPath;
  bool report = false;
  bool enforce = false;

  for (int index = 0; index < args.length; index += 1) {
    switch (args[index]) {
      case '--root':
        if (index + 1 >= args.length) _usage('Missing value after --root');
        root = args[++index];
        break;
      case '--json':
        if (index + 1 >= args.length) _usage('Missing value after --json');
        jsonPath = args[++index];
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
    stderr.writeln('Gray owner decision invalid root: ${requestedRoot.path}');
    exitCode = 64;
    return;
  }
  final Directory mobileRoot =
      Directory(requestedRoot.resolveSymbolicLinksSync());
  final GrayOwnerDecisionReport result =
      GrayOwnerPresentationGateAuditor(mobileRoot: mobileRoot).audit();

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
    for (final GrayOwnerDecisionViolation violation in result.violations) {
      stdout.writeln('- BLOCKER ${violation.code}: ${violation.message}');
    }
  }

  if (enforce && !result.gateReady) {
    stderr.writeln(
      'Gray owner presentation enforcement failed: '
      '${result.blockerCount} contract blocker(s).',
    );
    exitCode = 1;
  }
}

Never _usage(String message) {
  stderr.writeln(message);
  stderr.writeln(
    'Usage: dart run tool/verify_gray_owner_presentation_gate.dart '
    '[--root <mobile-root>] [--json <path>] [--report] [--enforce]',
  );
  exit(64);
}

void _help() {
  stdout.writeln(
    'Validate the fail-closed Drawer Gray owner presentation/source decision.\n'
    '--root <path>   Mobile project root (default: .)\n'
    '--json <path>   Write deterministic JSON report atomically\n'
    '--report        Print human-readable summary\n'
    '--enforce       Exit 1 only on contract drift or premature/partial admission.\n'
    'A pending owner decision is valid and remains release-blocking.',
  );
}
