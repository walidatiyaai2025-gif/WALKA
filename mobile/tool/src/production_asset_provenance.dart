import 'dart:convert';
import 'dart:io';

const List<String> pimgReleasedVariantIds = <String>[
  'drawer-organizer:white',
  'drawer-organizer:gray',
  'lunch-box:blue',
  'lunch-box:pink',
  'lunch-box:green',
];

const Map<String, String> pimgCanonicalPaths = <String, String>{
  'drawer-organizer:white': 'assets/products/drawer/white.png',
  'drawer-organizer:gray': 'assets/products/drawer/gray.png',
  'lunch-box:blue': 'assets/products/lunch/blue.png',
  'lunch-box:pink': 'assets/products/lunch/pink.png',
  'lunch-box:green': 'assets/products/lunch/green.png',
};

const Set<String> pimgLifecycleStates = <String>{'PENDING', 'ADMITTED', 'BLOCKED'};
const Set<String> pimgQaStates = <String>{'PENDING', 'PASS', 'BLOCKED'};
const List<String> pimgMandatoryQaChecks = <String>[
  'surfaceWhite',
  'surfaceIvory',
  'surfaceNavy',
  'downscale96',
  'downscale160',
  'downscale240',
  'downscale384',
  'geometryPreserved',
  'bakedUiExcluded',
];

class PimgProvenanceDiagnostic {
  const PimgProvenanceDiagnostic(this.code, this.message);

  final String code;
  final String message;

  Map<String, Object?> toJson() => <String, Object?>{
        'code': code,
        'message': message,
      };
}

class PimgProvenanceRow {
  const PimgProvenanceRow({
    required this.variantId,
    required this.sourceId,
    required this.sourceFilename,
    required this.sourceState,
    required this.canonicalPath,
    required this.lifecycleState,
    required this.sha256,
    required this.byteSize,
    required this.width,
    required this.height,
    required this.alphaBoundingBox,
    required this.nearestTransparentSafeMargin,
    required this.colorProfileExpectation,
    required this.qa,
  });

  final String variantId;
  final String sourceId;
  final String sourceFilename;
  final String sourceState;
  final String canonicalPath;
  final String lifecycleState;
  final String? sha256;
  final int? byteSize;
  final int? width;
  final int? height;
  final List<int>? alphaBoundingBox;
  final int? nearestTransparentSafeMargin;
  final String colorProfileExpectation;
  final Map<String, String> qa;

  bool get isAdmitted => lifecycleState == 'ADMITTED';
  bool get allMandatoryQaPassed =>
      pimgMandatoryQaChecks.every((String key) => qa[key] == 'PASS');

  Map<String, Object?> toJson() => <String, Object?>{
        'variantId': variantId,
        'sourceId': sourceId,
        'sourceFilename': sourceFilename,
        'sourceState': sourceState,
        'canonicalPath': canonicalPath,
        'lifecycleState': lifecycleState,
        'sha256': sha256,
        'byteSize': byteSize,
        'width': width,
        'height': height,
        'alphaBoundingBox': alphaBoundingBox,
        'nearestTransparentSafeMargin': nearestTransparentSafeMargin,
        'colorProfileExpectation': colorProfileExpectation,
        'qa': qa,
      };
}

class PimgProvenanceInspection {
  const PimgProvenanceInspection({
    required this.schemaVersion,
    required this.rows,
    required this.diagnostics,
  });

  final int? schemaVersion;
  final List<PimgProvenanceRow> rows;
  final List<PimgProvenanceDiagnostic> diagnostics;

  bool get valid => diagnostics.isEmpty;
  int get admittedCount => rows.where((PimgProvenanceRow row) => row.lifecycleState == 'ADMITTED').length;
  int get pendingCount => rows.where((PimgProvenanceRow row) => row.lifecycleState == 'PENDING').length;
  int get blockedCount => rows.where((PimgProvenanceRow row) => row.lifecycleState == 'BLOCKED').length;

  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': schemaVersion,
        'state': valid ? 'READY' : 'BLOCKED',
        'counts': <String, int>{
          'admitted': admittedCount,
          'pending': pendingCount,
          'blocked': blockedCount,
        },
        'variants': rows.map((PimgProvenanceRow row) => row.toJson()).toList(growable: false),
        'diagnostics': diagnostics
            .map((PimgProvenanceDiagnostic diagnostic) => diagnostic.toJson())
            .toList(growable: false),
      };
}

class PimgProductionAssetProvenanceReader {
  const PimgProductionAssetProvenanceReader();

  Future<PimgProvenanceInspection> inspect({
    required String provenancePath,
    required String sourceAdmissionPath,
    required String mobileRoot,
  }) async {
    final List<PimgProvenanceDiagnostic> diagnostics = <PimgProvenanceDiagnostic>[];
    final Map<String, dynamic>? provenance = await _readObject(provenancePath, diagnostics, 'provenance');
    final Map<String, dynamic>? sourceAdmission =
        await _readObject(sourceAdmissionPath, diagnostics, 'source-admission');
    if (provenance == null || sourceAdmission == null) {
      return PimgProvenanceInspection(
        schemaVersion: null,
        rows: const <PimgProvenanceRow>[],
        diagnostics: diagnostics,
      );
    }

    final int? schemaVersion = provenance['schemaVersion'] is int
        ? provenance['schemaVersion'] as int
        : null;
    if (schemaVersion != 1) {
      diagnostics.add(const PimgProvenanceDiagnostic(
        'provenance.schema-version-invalid',
        'Production asset provenance schemaVersion must be 1.',
      ));
    }

    final List<dynamic> rawRows = provenance['variants'] is List<dynamic>
        ? provenance['variants'] as List<dynamic>
        : const <dynamic>[];
    if (rawRows.length != pimgReleasedVariantIds.length) {
      diagnostics.add(const PimgProvenanceDiagnostic(
        'provenance.variant-count-invalid',
        'Production asset provenance must contain exactly five released variants.',
      ));
    }

    final List<PimgProvenanceRow> rows = <PimgProvenanceRow>[];
    for (int index = 0; index < rawRows.length; index += 1) {
      final Object? raw = rawRows[index];
      if (raw is! Map<String, dynamic>) {
        diagnostics.add(PimgProvenanceDiagnostic(
          'provenance.row-invalid',
          'Variant row $index must be a JSON object.',
        ));
        continue;
      }
      final PimgProvenanceRow? row = _parseRow(raw, index, diagnostics);
      if (row != null) rows.add(row);
    }

    _validateRows(
      rows: rows,
      sourceAdmission: sourceAdmission,
      mobileRoot: mobileRoot,
      diagnostics: diagnostics,
    );

    return PimgProvenanceInspection(
      schemaVersion: schemaVersion,
      rows: rows,
      diagnostics: diagnostics,
    );
  }

  Future<Map<String, dynamic>?> _readObject(
    String path,
    List<PimgProvenanceDiagnostic> diagnostics,
    String label,
  ) async {
    final File file = File(path);
    if (!await file.exists()) {
      diagnostics.add(PimgProvenanceDiagnostic('$label.missing', '$label file not found at $path.'));
      return null;
    }
    try {
      final Object? decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) return decoded;
    } on Object catch (error) {
      diagnostics.add(PimgProvenanceDiagnostic('$label.invalid-json', 'Unable to parse $label JSON: $error'));
      return null;
    }
    diagnostics.add(PimgProvenanceDiagnostic('$label.root-invalid', '$label root must be an object.'));
    return null;
  }

  PimgProvenanceRow? _parseRow(
    Map<String, dynamic> raw,
    int index,
    List<PimgProvenanceDiagnostic> diagnostics,
  ) {
    String? stringField(String key) {
      final Object? value = raw[key];
      return value is String && value.trim().isNotEmpty ? value : null;
    }

    final String? variantId = stringField('variantId');
    final String? sourceId = stringField('sourceId');
    final String? sourceFilename = stringField('sourceFilename');
    final String? sourceState = stringField('sourceState');
    final String? canonicalPath = stringField('canonicalPath');
    final String? lifecycleState = stringField('lifecycleState');
    final String? colorProfileExpectation = stringField('colorProfileExpectation');
    if (<Object?>[
      variantId,
      sourceId,
      sourceFilename,
      sourceState,
      canonicalPath,
      lifecycleState,
      colorProfileExpectation,
    ].any((Object? value) => value == null)) {
      diagnostics.add(PimgProvenanceDiagnostic(
        'provenance.required-field-missing',
        'Variant row $index is missing required provenance fields.',
      ));
      return null;
    }

    final Map<String, String> qa = <String, String>{};
    final Object? rawQa = raw['qa'];
    if (rawQa is Map<String, dynamic>) {
      for (final MapEntry<String, dynamic> entry in rawQa.entries) {
        if (entry.value is String) qa[entry.key] = entry.value as String;
      }
    }

    List<int>? alphaBoundingBox;
    final Object? rawBox = raw['alphaBoundingBox'];
    if (rawBox is List<dynamic> && rawBox.length == 4 && rawBox.every((dynamic value) => value is int)) {
      alphaBoundingBox = rawBox.cast<int>();
    }

    return PimgProvenanceRow(
      variantId: variantId!,
      sourceId: sourceId!,
      sourceFilename: sourceFilename!,
      sourceState: sourceState!,
      canonicalPath: canonicalPath!,
      lifecycleState: lifecycleState!,
      sha256: raw['sha256'] is String ? raw['sha256'] as String : null,
      byteSize: raw['byteSize'] is int ? raw['byteSize'] as int : null,
      width: raw['width'] is int ? raw['width'] as int : null,
      height: raw['height'] is int ? raw['height'] as int : null,
      alphaBoundingBox: alphaBoundingBox,
      nearestTransparentSafeMargin: raw['nearestTransparentSafeMargin'] is int
          ? raw['nearestTransparentSafeMargin'] as int
          : null,
      colorProfileExpectation: colorProfileExpectation!,
      qa: qa,
    );
  }

  void _validateRows({
    required List<PimgProvenanceRow> rows,
    required Map<String, dynamic> sourceAdmission,
    required String mobileRoot,
    required List<PimgProvenanceDiagnostic> diagnostics,
  }) {
    final List<String> ids = rows.map((PimgProvenanceRow row) => row.variantId).toList();
    if (ids.length != ids.toSet().length) {
      diagnostics.add(const PimgProvenanceDiagnostic(
        'provenance.variant-id-duplicate',
        'Production asset provenance variant IDs must be unique.',
      ));
    }
    if (ids.length == pimgReleasedVariantIds.length &&
        !_listEquals(ids, pimgReleasedVariantIds)) {
      diagnostics.add(const PimgProvenanceDiagnostic(
        'provenance.variant-order-invalid',
        'Production asset provenance must preserve released variant order.',
      ));
    }

    final List<String> paths = rows.map((PimgProvenanceRow row) => row.canonicalPath).toList();
    if (paths.length != paths.toSet().length) {
      diagnostics.add(const PimgProvenanceDiagnostic(
        'provenance.canonical-path-duplicate',
        'Canonical production asset paths must be unique.',
      ));
    }

    final Map<String, Map<String, dynamic>> sourceByVariant = <String, Map<String, dynamic>>{};
    final Object? rawSourceRows = sourceAdmission['variants'];
    if (rawSourceRows is List<dynamic>) {
      for (final Object? entry in rawSourceRows) {
        if (entry is Map<String, dynamic> && entry['variantId'] is String) {
          sourceByVariant[entry['variantId'] as String] = entry;
        }
      }
    }

    for (final PimgProvenanceRow row in rows) {
      if (!pimgLifecycleStates.contains(row.lifecycleState)) {
        diagnostics.add(PimgProvenanceDiagnostic(
          'provenance.lifecycle-state-invalid',
          '${row.variantId} uses unsupported lifecycle state ${row.lifecycleState}.',
        ));
      }
      final String? expectedPath = pimgCanonicalPaths[row.variantId];
      if (expectedPath == null || row.canonicalPath != expectedPath) {
        diagnostics.add(PimgProvenanceDiagnostic(
          'provenance.canonical-path-mismatch',
          '${row.variantId} canonical path does not match the runtime production contract.',
        ));
      }
      if (row.sourceFilename.replaceAll('\\', '/').startsWith('Images/')) {
        diagnostics.add(PimgProvenanceDiagnostic(
          'provenance.protected-source-path',
          '${row.variantId} cannot use protected Images/ as a runtime source.',
        ));
      }
      final Map<String, dynamic>? source = sourceByVariant[row.variantId];
      if (source == null ||
          source['sourceId'] != row.sourceId ||
          source['sourceFilename'] != row.sourceFilename ||
          source['sourceState'] != row.sourceState ||
          source['canonicalPath'] != row.canonicalPath) {
        diagnostics.add(PimgProvenanceDiagnostic(
          'provenance.source-admission-mismatch',
          '${row.variantId} provenance must match PRODUCTION_SOURCE_ADMISSION exactly.',
        ));
      }
      for (final String key in pimgMandatoryQaChecks) {
        final String? value = row.qa[key];
        if (value == null || !pimgQaStates.contains(value)) {
          diagnostics.add(PimgProvenanceDiagnostic(
            'provenance.qa-state-invalid',
            '${row.variantId} requires QA state $key as PENDING, PASS or BLOCKED.',
          ));
        }
      }
      if (row.lifecycleState == 'ADMITTED') {
        final bool metadataComplete = row.sha256 != null &&
            row.sha256!.length == 64 &&
            row.byteSize != null &&
            row.byteSize! > 0 &&
            row.width != null &&
            row.height != null &&
            row.alphaBoundingBox != null &&
            row.nearestTransparentSafeMargin != null;
        if (!metadataComplete) {
          diagnostics.add(PimgProvenanceDiagnostic(
            'provenance.admitted-fingerprint-missing',
            '${row.variantId} cannot be ADMITTED without deterministic binary metadata.',
          ));
        }
        if (row.sourceState != 'APPROVED') {
          diagnostics.add(PimgProvenanceDiagnostic(
            'provenance.admitted-source-not-approved',
            '${row.variantId} cannot be ADMITTED unless the source state is APPROVED.',
          ));
        }
        if (!row.allMandatoryQaPassed) {
          diagnostics.add(PimgProvenanceDiagnostic(
            'provenance.admitted-qa-incomplete',
            '${row.variantId} cannot be ADMITTED until every mandatory visual QA state is PASS.',
          ));
        }
        final File canonical = File('$mobileRoot/${row.canonicalPath}');
        if (!canonical.existsSync()) {
          diagnostics.add(PimgProvenanceDiagnostic(
            'provenance.admitted-file-missing',
            '${row.variantId} is ADMITTED but the canonical binary is missing.',
          ));
        }
      }
    }
  }

  bool _listEquals(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (int index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}

String pimgStableJson(PimgProvenanceInspection inspection) =>
    const JsonEncoder.withIndent('  ').convert(inspection.toJson());
