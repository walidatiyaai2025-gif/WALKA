import 'dart:io';

import 'src/vsurf_audit.dart';

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
      case '--json':
        if (i + 1 >= args.length) _usage('Missing value after --json');
        jsonPath = args[++i];
      case '--report':
        report = true;
      case '--enforce':
        enforce = true;
      case '--help':
      case '-h':
        _printHelp();
        return;
      default:
        _usage('Unknown argument: ${args[i]}');
    }
  }

  final Directory mobileRoot = Directory(root).absolute;
  if (!mobileRoot.existsSync()) {
    stderr.writeln('VSURF invalid root: ${mobileRoot.path}');
    exitCode = 64;
    return;
  }

  final VsurfReport result = VsurfAuditor(mobileRoot: mobileRoot).audit();
  if (jsonPath != null) {
    final File output = File(jsonPath);
    output.parent.createSync(recursive: true);
    final File temporary = File('${output.path}.tmp');
    temporary.writeAsStringSync('${result.prettyJson()}\n');
    temporary.renameSync(output.path);
  }

  if (report || jsonPath == null) {
    stdout.writeln(result.summary());
    for (final VsurfViolation violation in result.violations) {
      stdout.writeln(
        '- ${violation.severity.name.toUpperCase()} ${violation.code}'
        '${violation.slotId == null ? '' : ' [${violation.slotId}]'}: '
        '${violation.message}',
      );
    }
  }

  if (enforce && !result.integrationReady) {
    stderr.writeln(
      'VSURF enforcement failed: ${result.blockerCount} owner-visible integration blocker(s).',
    );
    exitCode = 1;
  }
}

Never _usage(String message) {
  stderr.writeln(message);
  stderr.writeln(
    'Usage: dart run tool/verify_owner_visible_media_surfaces.dart '
    '[--root <mobile-root>] [--json <path>] [--report] [--enforce]',
  );
  exit(64);
}

void _printHelp() {
  stdout.writeln(
    'Audit owner-visible WALKA product-media integration.\n'
    '--root <path>   Mobile project root (default: .)\n'
    '--json <path>   Write deterministic JSON report atomically\n'
    '--report        Print human-readable summary\n'
    '--enforce       Exit 1 only for integration blockers; global 5/5 media '\
    'readiness remains governed by verify_production_assets.',
  );
}
