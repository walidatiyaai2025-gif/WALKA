import 'dart:convert';
import 'dart:io';

class PinkSourceContractViolation {
  const PinkSourceContractViolation(this.code, this.message);

  final String code;
  final String message;

  Map<String, String> toJson() => <String, String>{
        'code': code,
        'message': message,
      };
}

class PinkSourceContractReport {
  const PinkSourceContractReport({
    required this.violations,
    required this.visualQaState,
    required this.provenanceState,
    required this.runtimeState,
    required this.canonicalExportPresent,
    required this.canonicalSha256,
  });

  final List<PinkSourceContractViolation> violations;
  final String visualQaState;
  final String provenanceState;
  final String runtimeState;
  final bool canonicalExportPresent;
  final String? canonicalSha256;

  int get blockerCount => violations.length;
  bool get contractReady => blockerCount == 0;
  bool get productionAdmitted =>
      contractReady &&
      visualQaState == 'PASS' &&
      provenanceState == 'ADMITTED' &&
      runtimeState == 'admitted' &&
      canonicalExportPresent &&
      canonicalSha256 != null;

  String get state {
    if (!contractReady) return 'BLOCKED';
    return productionAdmitted ? 'LOCKED_ADMITTED' : 'LOCKED_PENDING_VISUAL_QA';
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': 2,
        'state': state,
        'contractReady': contractReady,
        'productionAdmitted': productionAdmitted,
        'variantId': 'lunch-box:pink',
        'sourceFilename': '1000389975.jpg',
        'sourceSha256':
            '11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5',
        'canonicalSha256': canonicalSha256,
        'visualQaState': visualQaState,
        'provenanceState': provenanceState,
        'runtimeState': runtimeState,
        'canonicalExportPresent': canonicalExportPresent,
        'blockerCount': blockerCount,
        'violations': violations
            .map((PinkSourceContractViolation violation) => violation.toJson())
            .toList(),
      };

  String prettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String summary() =>
      'PINKSRC $state | provenance $provenanceState | runtime $runtimeState | '
      'export $canonicalExportPresent | visual QA $visualQaState | '
      'blockers $blockerCount';
}

class PinkSourceContractAuditor {
  PinkSourceContractAuditor({required this.mobileRoot});

  final Directory mobileRoot;

  static const String variantId = 'lunch-box:pink';
  static const String sourceId = 'SRC-LUNCH-PINK-001';
  static const String sourceFilename = '1000389975.jpg';
  static const String sourceSha256 =
      '11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5';
  static const String canonicalPath = 'assets/products/lunch/pink.png';
  static const String admittedCanonicalSha256 =
      '84b1c5b44980c29bf22ff88cafc747454d4caf8612209daa84edfc2e3f3a11ae';
  static const int admittedCanonicalBytes = 748350;
  static const List<int> admittedAlphaBoundingBox = <int>[51, 161, 972, 862];
  static const List<String> mandatoryQa = <String>[
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

  PinkSourceContractReport audit() {
    final List<PinkSourceContractViolation> violations =
        <PinkSourceContractViolation>[];
    final Directory repo = mobileRoot.parent;
    final Map<String, dynamic> contract = _readJson(
      File('${repo.path}/docs/ui/PINK_SOURCE_EXTRACTION_CONTRACT.json'),
      'CONTRACT',
      violations,
    );
    final Map<String, dynamic> admission = _readJson(
      File('${repo.path}/docs/ui/PRODUCTION_SOURCE_ADMISSION.json'),
      'SOURCE-ADMISSION',
      violations,
    );
    final Map<String, dynamic> provenance = _readJson(
      File('${repo.path}/docs/ui/PRODUCTION_ASSET_PROVENANCE.json'),
      'PROVENANCE',
      violations,
    );

    final Map<String, dynamic> namespace = _map(contract['taskNamespace']);
    final Map<String, dynamic> source = _map(contract['source']);
    final Map<String, dynamic> panel = _map(contract['approvedProductPanel']);
    final Map<String, dynamic> output = _map(contract['canonicalOutput']);
    final Map<String, dynamic> guard = _map(contract['admissionGuard']);

    _expect(contract['schemaVersion'] == 2, 'SCHEMA',
        'schemaVersion must be 2 after admission reconciliation.', violations);
    _expect(contract['variantId'] == variantId, 'VARIANT',
        'Variant must be $variantId.', violations);
    _expect(namespace['prefix'] == 'PINKSRC', 'NAMESPACE',
        'Namespace must be PINKSRC.', violations);
    _expect(namespace['first'] == 1 && namespace['last'] == 20, 'TASK-RANGE',
        'Task range must be 001..020.', violations);
    _expect(namespace['expectedCount'] == 20, 'TASK-COUNT',
        'Exactly 20 tasks are required.', violations);

    _expect(source['sourceId'] == sourceId, 'SOURCE-ID', 'Source ID drifted.',
        violations);
    _expect(source['filename'] == sourceFilename, 'SOURCE-NAME',
        'Source filename drifted.', violations);
    _expect(source['state'] == 'APPROVED', 'SOURCE-STATE',
        'Source must remain APPROVED.', violations);
    _expect(source['sha256'] == sourceSha256, 'SOURCE-SHA',
        'Source SHA-256 drifted.', violations);
    _expect(RegExp(r'^[0-9a-f]{64}$').hasMatch('${source['sha256']}'),
        'SOURCE-SHA-FORMAT', 'Source SHA-256 format is invalid.', violations);
    _expect(source['byteSize'] == 189515, 'SOURCE-BYTES',
        'Source bytes must be 189515.', violations);
    _expect(source['width'] == 695 && source['height'] == 1536,
        'SOURCE-DIMENSIONS', 'Source dimensions must be 695x1536.', violations);

    final int x = _int(panel['x']);
    final int y = _int(panel['y']);
    final int width = _int(panel['width']);
    final int height = _int(panel['height']);
    _expect(x == 28 && y == 760 && width == 647 && height == 575, 'PANEL',
        'Approved product-panel rectangle drifted.', violations);
    _expect(x >= 0 && y >= 0 && width > 0 && height > 0, 'PANEL-POSITIVE',
        'Product-panel rectangle must be positive.', violations);
    _expect(x + width <= 695 && y + height <= 1536, 'PANEL-BOUNDS',
        'Product-panel rectangle exceeds source bounds.', violations);
    _expect(panel['marketplacePixelsOutsidePanelMustBeExcluded'] == true,
        'MARKETPLACE-EXCLUSION',
        'Marketplace pixels outside the panel must be excluded.', violations);

    _expect(output['path'] == canonicalPath, 'CANONICAL-PATH',
        'Canonical path drifted.', violations);
    _expect(!'${output['path']}'.startsWith('Images/'), 'PROTECTED-PATH',
        'Protected Images/ cannot be a canonical runtime path.', violations);
    _expect(output['width'] == 1024 && output['height'] == 1024,
        'OUTPUT-DIMENSIONS', 'Output must be 1024x1024.', violations);
    _expect(output['pixelFormat'] == '8-bit RGBA', 'PIXEL-FORMAT',
        'Output must be 8-bit RGBA.', violations);
    _expect(output['colorProfile'] == 'sRGB', 'COLOR-PROFILE',
        'Output must use sRGB.', violations);
    _expect(_int(output['minimumTransparentSafeMarginPx']) >= 51, 'SAFE-MARGIN',
        'Safe margin must be at least 51 px.', violations);
    _expect(_int(output['maximumByteSize']) == 1258291, 'BYTE-BUDGET',
        'Hard budget must remain 1.2 MiB.', violations);
    _expect(output['admittedSha256'] == admittedCanonicalSha256,
        'ADMITTED-SHA-CONTRACT', 'Admitted canonical SHA drifted.', violations);
    _expect(output['admittedByteSize'] == admittedCanonicalBytes,
        'ADMITTED-BYTES-CONTRACT', 'Admitted canonical byte size drifted.',
        violations);
    _expect(_ints(output['admittedAlphaBoundingBox'])
        .equals(admittedAlphaBoundingBox), 'ADMITTED-BBOX-CONTRACT',
        'Admitted alpha bounding box drifted.', violations);

    final List<String> qa = _strings(contract['requiredVisualQa']);
    _expect(qa.length == mandatoryQa.length && qa.toSet().containsAll(mandatoryQa),
        'QA-SET', 'Mandatory visual QA set is incomplete.', violations);
    _expect(guard['currentVisualQaState'] == 'PASS', 'QA-STATE-CONTRACT',
        'Current Pink visual QA contract must be PASS.', violations);
    _expect(guard['requiredCurrentProvenanceState'] == 'ADMITTED',
        'GUARD-PROVENANCE', 'Contract must require admitted provenance.',
        violations);
    _expect(guard['requiredCurrentRuntimeState'] == 'admitted', 'GUARD-RUNTIME',
        'Contract must require admitted runtime state.', violations);
    _expect(guard['requiredCanonicalExportPresent'] == true, 'GUARD-EXPORT',
        'Contract must require confirmed canonical export.', violations);
    _expect(guard['requiredRuntimeEligible'] == true, 'GUARD-ELIGIBLE',
        'Contract must require runtime eligibility.', violations);
    _expect(guard['stablePublicationMustRemainFailClosed'] == true, 'STABLE-GATE',
        'Global stable publication must remain fail closed.', violations);

    final Map<String, dynamic>? admissionRow = _row(admission, variantId);
    _expect(admissionRow != null, 'SOURCE-ROW',
        'Pink source-admission row is missing.', violations);
    if (admissionRow != null) {
      _expect(admissionRow['sourceId'] == sourceId, 'SOURCE-ROW-ID',
          'Source-admission ID drifted.', violations);
      _expect(admissionRow['sourceFilename'] == sourceFilename, 'SOURCE-ROW-NAME',
          'Source-admission filename drifted.', violations);
      _expect(admissionRow['sourceState'] == 'APPROVED', 'SOURCE-ROW-STATE',
          'Source-admission must remain APPROVED.', violations);
      _expect(admissionRow['canonicalPath'] == canonicalPath, 'SOURCE-ROW-PATH',
          'Source-admission canonical path drifted.', violations);
      _expect(admissionRow['canonicalExportPresent'] == true,
          'SOURCE-ROW-EXPORT',
          'Admitted Pink must have canonicalExportPresent true.', violations);
    }

    String provenanceState = 'UNKNOWN';
    String visualQaState = 'UNKNOWN';
    String? canonicalSha256;
    final Map<String, dynamic>? provenanceRow = _row(provenance, variantId);
    _expect(provenanceRow != null, 'PROVENANCE-ROW',
        'Pink provenance row is missing.', violations);
    if (provenanceRow != null) {
      provenanceState = '${provenanceRow['lifecycleState']}';
      _expect(provenanceState == 'ADMITTED', 'PROVENANCE-STATE',
          'Pink provenance must be ADMITTED after evidence-backed promotion.',
          violations);
      canonicalSha256 = provenanceRow['sha256'] as String?;
      _expect(canonicalSha256 == admittedCanonicalSha256, 'PROVENANCE-SHA',
          'Pink canonical SHA does not match the admitted contract.', violations);
      _expect(provenanceRow['byteSize'] == admittedCanonicalBytes,
          'PROVENANCE-BYTES',
          'Pink canonical byte size does not match the admitted contract.',
          violations);
      _expect(provenanceRow['width'] == 1024 && provenanceRow['height'] == 1024,
          'PROVENANCE-DIMENSIONS', 'Pink canonical dimensions must be 1024x1024.',
          violations);
      _expect(_ints(provenanceRow['alphaBoundingBox'])
          .equals(admittedAlphaBoundingBox), 'PROVENANCE-BBOX',
          'Pink alpha bounding box does not match the admitted contract.',
          violations);
      _expect(_int(provenanceRow['nearestTransparentSafeMargin']) >= 51,
          'PROVENANCE-MARGIN', 'Pink safe margin must remain at least 51 px.',
          violations);
      _expect(provenanceRow['colorProfileExpectation'] == 'sRGB',
          'PROVENANCE-COLOR', 'Pink provenance must require sRGB.', violations);
      final Map<String, dynamic> qaStates = _map(provenanceRow['qa']);
      visualQaState = mandatoryQa.every((String check) => qaStates[check] == 'PASS')
          ? 'PASS'
          : 'INCOMPLETE';
      for (final String check in mandatoryQa) {
        _expect(qaStates[check] == 'PASS', 'QA-$check',
            '$check must be PASS for admitted Pink media.', violations);
      }
    }

    final File runtimeFile = File(
      '${mobileRoot.path}/lib/design_system/components/media/walka_product_media_admission.dart',
    );
    String runtimeState = 'UNKNOWN';
    bool exportPresent = false;
    if (!runtimeFile.existsSync()) {
      violations.add(const PinkSourceContractViolation(
          'RUNTIME-FILE', 'Runtime admission registry is missing.'));
    } else {
      final String sourceText = runtimeFile.readAsStringSync();
      final String? block = _runtimeBlock(sourceText);
      if (block == null) {
        violations.add(const PinkSourceContractViolation(
            'RUNTIME-ROW', 'Runtime Pink row is missing.'));
      } else {
        runtimeState = block.contains('WalkaProductMediaAdmissionState.admitted')
            ? 'admitted'
            : block.contains('WalkaProductMediaAdmissionState.pending')
                ? 'pending'
                : block.contains('WalkaProductMediaAdmissionState.blocked')
                    ? 'blocked'
                    : 'UNKNOWN';
        exportPresent = block.contains('canonicalExportPresent: true');
        _expect(block.contains("canonicalPath: '$canonicalPath'"), 'RUNTIME-PATH',
            'Runtime canonical path drifted.', violations);
        _expect(block.contains('sourceApproved: true'), 'RUNTIME-SOURCE',
            'Runtime sourceApproved must remain true.', violations);
        _expect(runtimeState == 'admitted', 'RUNTIME-STATE',
            'Runtime Pink must be admitted only after complete evidence.',
            violations);
        _expect(exportPresent, 'RUNTIME-EXPORT',
            'Runtime Pink must confirm canonical export presence.', violations);
      }
    }

    return PinkSourceContractReport(
      violations: violations,
      visualQaState: visualQaState,
      provenanceState: provenanceState,
      runtimeState: runtimeState,
      canonicalExportPresent: exportPresent,
      canonicalSha256: canonicalSha256,
    );
  }

  String? _runtimeBlock(String sourceText) {
    const String startToken = "'lunch-box:pink': WalkaProductMediaAdmissionEntry(";
    const String endToken = "'lunch-box:green': WalkaProductMediaAdmissionEntry(";
    final int start = sourceText.indexOf(startToken);
    if (start < 0) return null;
    final int end = sourceText.indexOf(endToken, start + startToken.length);
    if (end < 0) return null;
    return sourceText.substring(start, end);
  }

  Map<String, dynamic> _readJson(
    File file,
    String code,
    List<PinkSourceContractViolation> violations,
  ) {
    if (!file.existsSync()) {
      violations.add(PinkSourceContractViolation(
          '$code-MISSING', '${file.path} is missing.'));
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } on Object catch (error) {
      violations.add(PinkSourceContractViolation(
          '$code-INVALID', 'Could not parse ${file.path}: $error'));
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic>? _row(Map<String, dynamic> document, String id) {
    final Object? value = document['variants'];
    if (value is! List<dynamic>) return null;
    for (final dynamic row in value) {
      if (row is Map<String, dynamic> && row['variantId'] == id) return row;
    }
    return null;
  }

  Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  List<String> _strings(Object? value) => value is List<dynamic>
      ? value.whereType<String>().toList(growable: false)
      : <String>[];

  _IntList _ints(Object? value) => _IntList(value is List<dynamic>
      ? value.whereType<int>().toList(growable: false)
      : <int>[]);

  int _int(Object? value) => value is int ? value : -1;

  void _expect(
    bool condition,
    String code,
    String message,
    List<PinkSourceContractViolation> violations,
  ) {
    if (!condition) violations.add(PinkSourceContractViolation(code, message));
  }
}

class _IntList {
  const _IntList(this.values);

  final List<int> values;

  bool equals(List<int> other) {
    if (values.length != other.length) return false;
    for (int i = 0; i < values.length; i++) {
      if (values[i] != other[i]) return false;
    }
    return true;
  }
}
