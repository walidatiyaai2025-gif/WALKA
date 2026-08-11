import 'dart:convert';
import 'dart:io';

import 'src/production_asset_validator.dart';

Future<void> main(List<String> args) async {
  late final PavCliOptions options;
  try {
    options = PavCliOptions.parse(args);
  } on PavCliUsageException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(PavCliOptions.usage);
    exitCode = 2;
    return;
  }

  final ProductionAssetValidator validator = const ProductionAssetValidator();
  final report = await validator.validate(
    rootPath: options.rootPath,
    manifestPath: options.manifestPath,
    mode: options.enforce ? 'enforce' : 'report',
    strictWarnings: options.strictWarnings,
  );

  final String encoded = const JsonEncoder.withIndent('  ').convert(report.toJson());
  await writeReportAtomically(options.jsonPath, '$encoded\n');

  stdout.writeln('WALKA production product asset admission gate');
  stdout.writeln('Mode: ${options.enforce ? 'ENFORCE' : 'REPORT'}');
  stdout.writeln('State: ${report.state}');
  stdout.writeln('Ready: ${report.ready ? 'YES' : 'NO'}');
  stdout.writeln('Valid: ${report.readyCount}/${report.requiredCount}');
  stdout.writeln('Blockers: ${report.blockerCount}');
  stdout.writeln('Warnings: ${report.warningCount}');
  stdout.writeln('Strict warnings: ${options.strictWarnings ? 'YES' : 'NO'}');
  stdout.writeln('Manifest: ${options.manifestPath}');
  stdout.writeln('Report: ${options.jsonPath}');
  for (final asset in report.assets) {
    stdout.writeln(asset.summary);
  }
  for (final diagnostic in report.crossDiagnostics) {
    stdout.writeln(
      '- cross/${diagnostic.severity.name}: ${diagnostic.code} — ${diagnostic.message}',
    );
  }

  if (options.enforce && !report.ready) {
    stderr.writeln(
      'FAIL: stable owner-visible APK publication is blocked until every '
      'released product variant has an APPROVED source, a confirmed canonical '
      'export and a valid production PNG that passes admission checks.',
    );
    exitCode = 1;
  }
}

Future<void> writeReportAtomically(String path, String content) async {
  final File target = File(path);
  await target.parent.create(recursive: true);
  final File temporary = File('$path.tmp');
  await temporary.writeAsString(content, flush: true);
  if (await target.exists()) {
    await target.delete();
  }
  await temporary.rename(target.path);
}

class PavCliOptions {
  const PavCliOptions({
    required this.enforce,
    required this.jsonPath,
    required this.rootPath,
    required this.manifestPath,
    required this.strictWarnings,
  });

  final bool enforce;
  final String jsonPath;
  final String rootPath;
  final String manifestPath;
  final bool strictWarnings;

  static const String usage =
      'Usage: dart run tool/verify_production_assets.dart '
      '[--report|--enforce] [--json <path>] [--root <path>] '
      '[--manifest <path>] [--strict-warnings]';

  static PavCliOptions parse(List<String> args) {
    bool enforce = false;
    bool strictWarnings = false;
    String jsonPath = 'production-asset-readiness.json';
    String rootPath = '.';
    String manifestPath = '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json';

    for (int index = 0; index < args.length; index += 1) {
      final String arg = args[index];
      switch (arg) {
        case '--report':
          enforce = false;
          break;
        case '--enforce':
          enforce = true;
          break;
        case '--strict-warnings':
          strictWarnings = true;
          break;
        case '--json':
          jsonPath = _nextValue(args, ++index, '--json');
          break;
        case '--root':
          rootPath = _nextValue(args, ++index, '--root');
          break;
        case '--manifest':
          manifestPath = _nextValue(args, ++index, '--manifest');
          break;
        case '--help':
        case '-h':
          throw const PavCliUsageException(PavCliOptions.usage);
        default:
          throw PavCliUsageException('Unknown argument: $arg');
      }
    }

    return PavCliOptions(
      enforce: enforce,
      jsonPath: jsonPath,
      rootPath: rootPath,
      manifestPath: manifestPath,
      strictWarnings: strictWarnings,
    );
  }

  static String _nextValue(List<String> args, int index, String option) {
    if (index >= args.length || args[index].startsWith('--')) {
      throw PavCliUsageException('Missing path after $option.');
    }
    return args[index];
  }
}

class PavCliUsageException implements Exception {
  const PavCliUsageException(this.message);

  final String message;

  @override
  String toString() => message;
}
