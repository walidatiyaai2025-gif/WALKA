import 'dart:io';

import 'src/pink_source_contract.dart';

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

  final Directory mobileRoot = Directory(root).absolute;
  if (!mobileRoot.existsSync()) {
    stderr.writeln('PINKSRC invalid root: ${mobileRoot.path}');
    exitCode = 64;
    return;
  }

  final PinkSourceContractReport result =
      PinkSourceContractAuditor(mobileRoot: mobileRoot).audit();

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
    for (final PinkSourceContractViolation violation in result.violations) {
      stdout.writeln('- BLOCKER ${violation.code}: ${violation.message}');
    }
  }

  if (enforce && !result.contractReady) {
    stderr.writeln(
      'PINKSRC enforcement failed: ${result.blockerCount} contract blocker(s).',
    );
    exitCode = 1;
  }
}

Never _usage(String message) {
  stderr.writeln(message);
  stderr.writeln(
    'Usage: dart run tool/verify_pink_source_contract.dart '
    '[--root <mobile-root>] [--json <path>] [--report] [--enforce]',
  );
  exit(64);
}

void _help() {
  stdout.writeln(
    'Validate the fail-closed WALKA Pink source/extraction contract.\n'
    '--root <path>   Mobile project root (default: .)\n'
    '--json <path>   Write deterministic JSON report atomically\n'
    '--report        Print human-readable summary\n'
    '--enforce       Exit 1 on contract drift or premature Pink admission.\n'
    'A successful audit means the source boundary is locked, not that Pink '
    'production media has passed visual QA.',
  );
}
