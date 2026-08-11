import 'dart:io';

import 'src/production_asset_provenance.dart';

Future<void> main(List<String> args) async {
  String root = Directory.current.path;
  String provenance = '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json';
  String sourceAdmission = '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json';
  String? output;

  for (int index = 0; index < args.length; index += 1) {
    final String arg = args[index];
    if (arg == '--root' && index + 1 < args.length) {
      root = args[++index];
    } else if (arg == '--provenance' && index + 1 < args.length) {
      provenance = args[++index];
    } else if (arg == '--source-admission' && index + 1 < args.length) {
      sourceAdmission = args[++index];
    } else if (arg == '--output' && index + 1 < args.length) {
      output = args[++index];
    } else {
      stderr.writeln('Usage: dart tool/verify_production_provenance.dart [--root path] [--provenance path] [--source-admission path] [--output path]');
      exitCode = 64;
      return;
    }
  }

  final PimgProvenanceInspection inspection =
      await const PimgProductionAssetProvenanceReader().inspect(
    provenancePath: provenance,
    sourceAdmissionPath: sourceAdmission,
    mobileRoot: root,
  );
  final String report = pimgStableJson(inspection);
  stdout.writeln(report);
  if (output != null) {
    final File file = File(output);
    await file.parent.create(recursive: true);
    await file.writeAsString('$report\n', flush: true);
  }
  if (!inspection.valid) exitCode = 2;
}
