import 'dart:convert';
import 'dart:io';

import '../lib/design_system/components/media/walka_product_media_admission.dart';

Future<void> main(List<String> args) async {
  String sourcePath = '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json';
  String provenancePath = '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json';
  String rootPath = '.';
  String? jsonPath;

  for (int i = 0; i < args.length; i += 1) {
    switch (args[i]) {
      case '--source':
        sourcePath = _value(args, ++i, '--source');
      case '--provenance':
        provenancePath = _value(args, ++i, '--provenance');
      case '--root':
        rootPath = _value(args, ++i, '--root');
      case '--json':
        jsonPath = _value(args, ++i, '--json');
      default:
        stderr.writeln('Unknown option: ${args[i]}');
        exitCode = 64;
        return;
    }
  }

  final List<Map<String, Object?>> issues = <Map<String, Object?>>[];
  final Map<String, dynamic> source = await _readJson(sourcePath, issues, 'source');
  final Map<String, dynamic> provenance =
      await _readJson(provenancePath, issues, 'provenance');

  final Map<String, Map<String, dynamic>> sourceRows =
      _indexRows(source['variants'], issues, 'source');
  final Map<String, Map<String, dynamic>> provenanceRows =
      _indexRows(provenance['variants'], issues, 'provenance');

  final Set<String> expected =
      WalkaProductMediaAdmissionRegistry.releasedVariantIds.toSet();
  _checkVariantSet(sourceRows.keys.toSet(), expected, issues, 'source');
  _checkVariantSet(provenanceRows.keys.toSet(), expected, issues, 'provenance');

  int present = 0;
  int presentQuarantined = 0;
  int admittedPresent = 0;
  final List<Map<String, Object?>> variants = <Map<String, Object?>>[];

  for (final String variantId
      in WalkaProductMediaAdmissionRegistry.releasedVariantIds) {
    final WalkaProductMediaAdmissionEntry entry =
        WalkaProductMediaAdmissionRegistry.entries[variantId]!;
    final Map<String, dynamic>? sourceRow = sourceRows[variantId];
    final Map<String, dynamic>? provenanceRow = provenanceRows[variantId];
    final List<String> variantIssues = <String>[];

    if (sourceRow == null) {
      _issue(issues, variantIssues, variantId, 'source.row-missing');
    }
    if (provenanceRow == null) {
      _issue(issues, variantIssues, variantId, 'provenance.row-missing');
    }

    if (sourceRow != null) {
      _equal(sourceRow['canonicalPath'], entry.canonicalPath, issues,
          variantIssues, variantId, 'source.canonical-path-mismatch');
      _equal(sourceRow['sourceState'] == 'APPROVED', entry.sourceApproved,
          issues, variantIssues, variantId, 'source.approval-mismatch');
      _equal(sourceRow['canonicalExportPresent'], entry.canonicalExportPresent,
          issues, variantIssues, variantId, 'source.export-flag-mismatch');
    }

    if (provenanceRow != null) {
      _equal(provenanceRow['canonicalPath'], entry.canonicalPath, issues,
          variantIssues, variantId, 'provenance.canonical-path-mismatch');
      _equal(provenanceRow['sourceState'] == 'APPROVED', entry.sourceApproved,
          issues, variantIssues, variantId, 'provenance.approval-mismatch');
      final String expectedLifecycle = switch (entry.state) {
        WalkaProductMediaAdmissionState.pending => 'PENDING',
        WalkaProductMediaAdmissionState.admitted => 'ADMITTED',
        WalkaProductMediaAdmissionState.blocked => 'BLOCKED',
      };
      _equal(provenanceRow['lifecycleState'], expectedLifecycle, issues,
          variantIssues, variantId, 'provenance.lifecycle-mismatch');
    }

    if (entry.state == WalkaProductMediaAdmissionState.admitted) {
      if (!entry.sourceApproved) {
        _issue(issues, variantIssues, variantId, 'admission.source-not-approved');
      }
      if (!entry.canonicalExportPresent) {
        _issue(issues, variantIssues, variantId, 'admission.export-not-confirmed');
      }
      final Object? qa = provenanceRow?['qa'];
      if (qa is! Map || qa.values.any((Object? value) => value != 'PASS')) {
        _issue(issues, variantIssues, variantId, 'admission.visual-qa-not-pass');
      }
    }

    final File binary = File('$rootPath/${entry.canonicalPath}');
    final bool binaryPresent = await binary.exists();
    if (binaryPresent) present += 1;
    if (binaryPresent && !entry.eligibleForRuntime) presentQuarantined += 1;
    if (binaryPresent && entry.eligibleForRuntime) admittedPresent += 1;

    variants.add(<String, Object?>{
      'variantId': variantId,
      'canonicalPath': entry.canonicalPath,
      'state': entry.state.name.toUpperCase(),
      'eligibleForRuntime': entry.eligibleForRuntime,
      'sourceApproved': entry.sourceApproved,
      'canonicalExportPresent': entry.canonicalExportPresent,
      'binaryPresent': binaryPresent,
      'quarantineReason': entry.quarantineReason,
      'issues': variantIssues,
    });
  }

  final Map<String, Object?> report = <String, Object?>{
    'schemaVersion': 1,
    'consistent': issues.isEmpty,
    'registeredCount': expected.length,
    'admittedCount': WalkaProductMediaAdmissionRegistry.admittedCount,
    'pendingCount': WalkaProductMediaAdmissionRegistry.pendingCount,
    'blockedCount': WalkaProductMediaAdmissionRegistry.blockedCount,
    'binaryPresentCount': present,
    'presentButQuarantinedCount': presentQuarantined,
    'admittedBinaryPresentCount': admittedPresent,
    'variants': variants,
    'issues': issues,
  };

  if (jsonPath != null) {
    final File output = File(jsonPath);
    await output.parent.create(recursive: true);
    final File temp = File('${output.path}.tmp');
    await temp.writeAsString('${const JsonEncoder.withIndent('  ').convert(report)}\n',
        flush: true);
    await temp.rename(output.path);
  }

  stdout.writeln('WALKA runtime product media admission consistency');
  stdout.writeln('Consistent: ${issues.isEmpty ? 'YES' : 'NO'}');
  stdout.writeln('Registered: ${expected.length}');
  stdout.writeln('Admitted: ${WalkaProductMediaAdmissionRegistry.admittedCount}');
  stdout.writeln('Pending: ${WalkaProductMediaAdmissionRegistry.pendingCount}');
  stdout.writeln('Blocked: ${WalkaProductMediaAdmissionRegistry.blockedCount}');
  stdout.writeln('Binary present: $present');
  stdout.writeln('Present but quarantined: $presentQuarantined');
  for (final Map<String, Object?> variant in variants) {
    stdout.writeln(
      '- ${variant['variantId']}: ${variant['state']} '
      'present=${variant['binaryPresent']} runtime=${variant['eligibleForRuntime']} '
      'reason=${variant['quarantineReason']}',
    );
  }
  for (final Map<String, Object?> issue in issues) {
    stdout.writeln('- ERROR ${issue['variantId'] ?? 'global'}: ${issue['code']}');
  }

  if (issues.isNotEmpty) exitCode = 1;
}

String _value(List<String> args, int index, String option) {
  if (index >= args.length) {
    throw ArgumentError('Missing value for $option');
  }
  return args[index];
}

Future<Map<String, dynamic>> _readJson(
  String path,
  List<Map<String, Object?>> issues,
  String kind,
) async {
  try {
    final Object? decoded = jsonDecode(await File(path).readAsString());
    if (decoded is Map<String, dynamic>) return decoded;
  } catch (_) {
    // Handled below using a stable issue code.
  }
  issues.add(<String, Object?>{'code': '$kind.invalid-json'});
  return <String, dynamic>{};
}

Map<String, Map<String, dynamic>> _indexRows(
  Object? raw,
  List<Map<String, Object?>> issues,
  String kind,
) {
  final Map<String, Map<String, dynamic>> rows =
      <String, Map<String, dynamic>>{};
  if (raw is! List) {
    issues.add(<String, Object?>{'code': '$kind.variants-invalid'});
    return rows;
  }
  for (final Object? item in raw) {
    if (item is! Map<String, dynamic> || item['variantId'] is! String) {
      issues.add(<String, Object?>{'code': '$kind.variant-invalid'});
      continue;
    }
    final String id = item['variantId'] as String;
    if (rows.containsKey(id)) {
      issues.add(<String, Object?>{
        'variantId': id,
        'code': '$kind.variant-duplicate',
      });
      continue;
    }
    rows[id] = item;
  }
  return rows;
}

void _checkVariantSet(
  Set<String> actual,
  Set<String> expected,
  List<Map<String, Object?>> issues,
  String kind,
) {
  if (actual.length != expected.length ||
      !actual.containsAll(expected) ||
      !expected.containsAll(actual)) {
    issues.add(<String, Object?>{'code': '$kind.variant-set-mismatch'});
  }
}

void _equal(
  Object? actual,
  Object? expected,
  List<Map<String, Object?>> issues,
  List<String> variantIssues,
  String variantId,
  String code,
) {
  if (actual != expected) _issue(issues, variantIssues, variantId, code);
}

void _issue(
  List<Map<String, Object?>> issues,
  List<String> variantIssues,
  String variantId,
  String code,
) {
  variantIssues.add(code);
  issues.add(<String, Object?>{'variantId': variantId, 'code': code});
}
