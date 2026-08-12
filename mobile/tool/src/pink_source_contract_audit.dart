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
    required this.variantId,
    required this.sourceFilename,
    required this.sourceSha256,
    required this.visualQaState,
    required this.provenanceState,
    required this.runtimeState,
    required this.canonicalExportPresent,
  });

  final List<PinkSourceContractViolation> violations;
  final String variantId;
  final String sourceFilename;
  final String sourceSha256;
  final String visualQaState;
  final String provenanceState;
  final String runtimeState;
  final bool canonicalExportPresent;

  int get blockerCount => violations.length;
  bool get contractReady => blockerCount == 0;
  bool get productionAdmitted =>
      provenanceState == 'ADMITTED' &&
      runtimeState == 'admitted' &&
      canonicalExportPresent &&
      visualQaState == 'PASS';

  Map<String, Object> toJson() => <String, Object>{
        'schemaVersion': 1,
        'state': contractReady ? 'LOCKED_PENDING_VISUAL_QA' : 'BLOCKED',
        'contractReady': contractReady,
        'productionAdmitted': productionAdmitted,
        'variantId': variantId,
        'sourceFilename': sourceFilename,
        'sourceSha256': sourceSha256,
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
      'PINKSRC ${contractReady ? 'LOCKED_PENDING_VISUAL_QA' : 'BLOCKED'} | '
      'source $sourceFilename | provenance $provenanceState | '
      'runtime $runtimeState | export $canonicalExportPresent | '
      'visual QA $visualQaState | blockers $blockerCount';
}

class PinkSourceContractAuditor {
  PinkSourceContractAuditor({required this.mobileRoot});

  final Directory mobileRoot;

  static const String _variantId = 'lunch-box:pink';
  static const String _sourceId = 'SRC-LUNCH-PINK-001';
  static const String _sourceFilename = '1000389975.jpg';
  static const String _sourceSha256 =
      '11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5';
  static const String _canonicalPath = 'assets/products/lunch/pink.png';
  static const List<String> _qa = <String>[
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
    final Directory repositoryRoot = mobileRoot.parent;
    final File contractFile = File(
      '${repositoryRoot.path}/docs/ui/PINK_SOURCE_EXTRACTION_CONTRACT.json',
    );
    final File sourceAdmissionFile = File(
      '${repositoryRoot.path}/docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
    );
    final File provenanceFile = File(
      '${repositoryRoot.path}/docs/ui/PRODUCTION_ASSET_PROVENANCE.json',
    );
    final File runtimeFile = File(
      '${mobileRoot.path}/lib/design_system/components/media/'
      'walka_product_media_admission.dart',
    );

    final Map<String, dynamic> contract =
        _readJson(contractFile, 'PINKSRC-CONTRACT-MISSING', violations);
    final Map<String, dynamic> sourceAdmission = _readJson(
      sourceAdmissionFile,
      'PINKSRC-SOURCE-ADMISSION-MISSING',
      violations,
    );
    final Map<String, dynamic> provenance = _readJson(
      provenanceFile,
      'PINKSRC-PROVENANCE-MISSING',
      violations,
    );

    final Map<String, dynamic> source = _map(contract['source']);
    final Map<String, dynamic> panel = _map(contract['approvedProductPanel']);
    final Map<String, dynamic> output = _map(contract['canonicalOutput']);
    final Map<String, dynamic> guard = _map(contract['admissionGuard']);
    final Map<String, dynamic> namespace = _map(contract['taskNamespace']);

    _expect(contract['schemaVersion'] == 1, 'PINKSRC-SCHEMA',
        'Contract schemaVersion must be 1.', violations);
    _expect(contract['variantId'] == _variantId, 'PINKSRC-VARIANT',
        'Contract must target $_variantId.', violations);
    _expect(namespace['prefix'] == 'PINKSRC', 'PINKSRC-NAMESPACE',
        'Task namespace prefix must be PINKSRC.', violations);
    _expect(namespace['first'] == 1 && namespace['last'] == 20,
        'PINKSRC-RANGE', 'Task range must be PINKSRC-001..020.', violations);
    _expect(namespace['expectedCount'] == 20, 'PINKSRC-COUNT',
        'Task namespace must contain exactly 20 tasks.', violations);

    _expect(source['sourceId'] == _sourceId, 'PINKSRC-SOURCE-ID',
        'Source ID drifted from $_sourceId.', violations);
    _expect(source['filename'] == _sourceFilename, 'PINKSRC-SOURCE-NAME',
        'Source filename drifted from $_sourceFilename.', violations);
    _expect(source['state'] == 'APPROVED', 'PINKSRC-SOURCE-STATE',
        'Pink source must remain APPROVED.', violations);
    _expect(source['sha256'] == _sourceSha256, 'PINKSRC-SOURCE-SHA',
        'Pink source fingerprint changed.', violations);
    _expect(
      RegExp(r'^[0-9a-f]{64}$').hasMatch('${source['sha256']}'),
      'PINKSRC-SHA-FORMAT',
      'Source SHA-256 must be exactly 64 lowercase hex characters.',
      violations,
    );
    _expect(source['byteSize'] == 189515, 'PINKSRC-SOURCE-BYTES',
        'Source byte size must remain 189515.', violations);
    _expect(source['width'] == 695 && source['height'] == 1536,
        'PINKSRC-SOURCE-DIMENSIONS', 'Source dimensions must remain 695x1536.',
        violations);

    final int x = _integer(panel['x']);
    final int y = _integer(panel['y']);
    final int width = _integer(panel['width']);
    final int height = _integer(panel['height']);
    _expect(x == 28 && y == 760 && width == 647 && height == 575,
        'PINKSRC-PANEL', 'Approved product-panel crop rectangle drifted.',
        violations);
    _expect(x >= 0 && y >= 0 && width > 0 && height > 0,
        'PINKSRC-PANEL-POSITIVE', 'Approved product-panel crop must be positive.',
        violations);
    _expect(x + width <= 695 && y + height <= 1536, 'PINKSRC-PANEL-BOUNDS',
        'Approved product-panel crop must remain inside source bounds.',
        violations);
    _expect(panel['marketplacePixelsOutsidePanelMustBeExcluded'] == true,
        'PINKSRC-MARKETPLACE-EXCLUSION',
        'Marketplace pixels outside the approved panel must be excluded.',
        violations);

    _expect(output['path'] == _canonicalPath, 'PINKSRC-CANONICAL-PATH',
        'Canonical Pink output path drifted.', violations);
    _expect(!'${output['path']}'.startsWith('Images/'), 'PINKSRC-PROTECTED-PATH',
        'Protected Images/ masters cannot be runtime canonical media.',
        violations);
    _expect(output['width'] == 1024 && output['height'] == 1024,
        'PINKSRC-OUTPUT-DIMENSIONS', 'Canonical output must be 1024x1024.',
        violations);
    _expect(output['pixelFormat'] == '8-bit RGBA', 'PINKSRC-PIXEL-FORMAT',
        'Canonical output must be 8-bit RGBA.', violations);
    _expect(output['colorProfile'] == 'sRGB', 'PINKSRC-COLOR-PROFILE',
        'Canonical output must use sRGB metadata.', violations);
    _expect(_integer(output['minimumTransparentSafeMarginPx']) >= 51,
        'PINKSRC-SAFE-MARGIN', 'Transparent safe margin must be at least 51 px.',
        violations);
    _expect(_integer(output['maximumByteSize']) == 1258291,
        'PINKSRC-BYTE-BUDGET', 'Canonical hard budget must remain 1.2 MiB.',
        violations);

    final List<String> qa = _stringList(contract['requiredVisualQa']);
    _expect(qa.length == _qa.length && qa.toSet().containsAll(_qa),
        'PINKSRC-QA-SET', 'Mandatory Pink visual QA set is incomplete.',
        violations);
    _expect(guard['currentVisualQaState'] == 'PENDING', 'PINKSRC-QA-STATE',
        'Pink visual QA must remain PENDING in this source-lock slice.',
        violations);
    _expect(guard['stablePublicationMustRemainFailClosed'] == true,
        'PINKSRC-STABLE-GATE', 'Stable publication must remain fail closed.',
        violations);

    final Map<String, dynamic>? sourceRow =
        _variantRow(sourceAdmission, _variantId);
    if (sourceRow == null) {
      violations.add(const PinkSourceContractViolation(
        'PINKSRC-SOURCE-ROW',
        'Pink source-admission row is missing.',
      ));
    } else {
      _expect(sourceRow['sourceId'] == _sourceId, 'PINKSRC-SOURCE-ROW-ID',
          'Source-admission source ID drifted.', violations);
      _expect(sourceRow['sourceFilename'] == _sourceFilename,
          'PINKSRC-SOURCE-ROW-NAME', 'Source-admission filename drifted.',
          violations);
      _expect(sourceRow['sourceState'] == 'APPROVED',
          'PINKSRC-SOURCE-ROW-STATE', 'Source-admission must remain APPROVED.',
          violations);
      _expect(sourceRow['canonicalPath'] == _canonicalPath,
          'PINKSRC-SOURCE-ROW-PATH', 'Source-admission canonical path drifted.',
          violations);
      _expect(sourceRow['canonicalExportPresent'] == false,
          'PINKSRC-PREMATURE-EXPORT',
          'Pink canonical export cannot be confirmed before complete visual QA.',
          violations);
    }

    String provenanceState = 'UNKNOWN';
    final Map<String, dynamic>? provenanceRow = _variantRow(provenance, _variantId);
    if (provenanceRow == null) {
      violations.add(const PinkSourceContractViolation(
        'PINKSRC-PROVENANCE-ROW',
        'Pink provenance row is missing.',
      ));
    } else {
      provenanceState = '${provenanceRow['lifecycleState']}';
      _expect(provenanceState == 'PENDING', 'PINKSRC-PROVENANCE-STATE',
          'Pink provenance must remain PENDING until visual QA passes.',
          violations);
      _expect(provenanceRow['sha256'] == null && provenanceRow['byteSize'] == null,
          'PINKSRC-PREMATURE-FINGERPRINT',
          'Pending Pink provenance cannot claim a canonical fingerprint.',
          violations);
      final Map<String, dynamic> qaState = _map(provenanceRow['qa']);
      for (final String check in _qa) {
        _expect(qaState[check] == 'PENDING', 'PINKSRC-QA-$check',
            '$check must remain PENDING until the real canonical cutout passes.',
            violations);
      }
    }

    String runtimeState = 'UNKNOWN';
    bool canonicalExportPresent = false;
    if (!runtimeFile.existsSync()) {
      violations.add(const PinkSourceContractViolation(
        'PINKSRC-RUNTIME-MISSING',
        'Runtime media-admission registry is missing.',
      ));
    } else {
      final String runtimeSource = runtimeFile.readAsStringSync();
      final RegExpMatch? match = RegExp(
        r"'lunch-box:pink': WalkaProductMediaAdmissionEntry\((.*?)\n    \),",
        dotAll: true,
      ).firstMatch(runtimeSource);
      if (match == null) {
        violations.add(const PinkSourceContractViolation(
          'PINKSRC-RUNTIME-ROW',
          'Runtime Pink admission row could not be located.',
        ));
      } else {
        final String block = match.group(1)!;
        runtimeState = block.contains(
                'state: WalkaProductMediaAdmissionState.pending')
            ? 'pending'
            : block.contains('state: WalkaProductMediaAdmissionState.admitted')
                ? 'admitted'
                : block.contains('state: WalkaProductMediaAdmissionState.blocked')
                    ? 'blocked'
                    : 'UNKNOWN';
        canonicalExportPresent =
            block.contains('canonicalExportPresent: true');
        _expect(block.contains("canonicalPath: '$_canonicalPath'"),
            'PINKSRC-RUNTIME-PATH', 'Runtime Pink canonical path drifted.',
            violations);
        _expect(block.contains('sourceApproved: true'),
            'PINKSRC-RUNTIME-SOURCE', 'Runtime Pink source must remain approved.',
            violations);
        _expect(runtimeState == 'pending', 'PINKSRC-RUNTIME-STATE',
            'Runtime Pink must remain pending until visual QA passes.',
            violations);
        _expect(!canonicalExportPresent, 'PINKSRC-RUNTIME-EXPORT',
            'Runtime Pink export cannot be confirmed in a pending source-lock slice.',
            violations);
      }
    }

    return PinkSourceContractReport(
      violations: violations,
      variantId: _variantId,
      sourceFilename: _sourceFilename,
      sourceSha256: _sourceSha256,
      visualQaState: '${guard['currentVisualQaState'] ?? 'UNKNOWN'}',
      provenanceState: provenanceState,
      runtimeState: runtimeState,
      canonicalExportPresent: canonicalExportPresent,
    );
  }

  Map<String, dynamic> _readJson(
    File file,
    String code,
    List<PinkSourceContractViolation> violations,
  ) {
    if (!file.existsSync()) {
      violations.add(PinkSourceContractViolation(code, '${file.path} is missing.'));
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } on Object catch (error) {
      violations.add(PinkSourceContractViolation(
        '$code-INVALID',
        'Could not parse ${file.path}: $error',
      ));
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic>? _variantRow(
    Map<String, dynamic> document,
    String variantId,
  ) {
    final Object? raw = document['variants'];
    if (raw is! List<dynamic>) return null;
    for (final dynamic row in raw) {
      if (row is Map<String, dynamic> && row['variantId'] == variantId) {
        return row;
      }
    }
    return null;
  }

  Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  List<String> _stringList(Object? value) => value is List<dynamic>
      ? value.whereType<String>().toList(growable: false)
      : <String>[];

  int _integer(Object? value) => value is int ? value : -1;

  void _expect(
    bool condition,
    String code,
    String message,
    List<PinkSourceContractViolation> violations,
  ) {
    if (!condition) {
      violations.add(PinkSourceContractViolation(code, message));
    }
  }
}
