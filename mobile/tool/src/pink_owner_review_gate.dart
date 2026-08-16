import 'dart:convert';
import 'dart:io';

class PinkOwnerReviewViolation {
  const PinkOwnerReviewViolation(this.code, this.message);

  final String code;
  final String message;

  Map<String, String> toJson() => <String, String>{
        'code': code,
        'message': message,
      };
}

class PinkOwnerReviewReport {
  const PinkOwnerReviewReport({
    required this.violations,
    required this.reviewCandidateSha256,
    required this.receiptCandidateSha256,
    required this.ownerStatus,
    required this.ownerAccepted,
    required this.provenanceState,
    required this.runtimeState,
    required this.canonicalExportPresent,
  });

  final List<PinkOwnerReviewViolation> violations;
  final String? reviewCandidateSha256;
  final String? receiptCandidateSha256;
  final String ownerStatus;
  final bool ownerAccepted;
  final String provenanceState;
  final String runtimeState;
  final bool canonicalExportPresent;

  int get blockerCount => violations.length;
  bool get gateReady => blockerCount == 0;

  String get state {
    if (!gateReady) return 'BLOCKED';
    if (!ownerAccepted) return 'AWAITING_OWNER_ACCEPTANCE';
    if (provenanceState == 'ADMITTED' &&
        runtimeState == 'admitted' &&
        canonicalExportPresent) {
      return 'OWNER_ACCEPTED_ADMISSION_RECONCILED';
    }
    return 'OWNER_ACCEPTED_AWAITING_ADMISSION';
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': 1,
        'state': state,
        'gateReady': gateReady,
        'variantId': PinkOwnerReviewGateAuditor.variantId,
        'reviewCandidateSha256': reviewCandidateSha256,
        'receiptCandidateSha256': receiptCandidateSha256,
        'ownerStatus': ownerStatus,
        'ownerAccepted': ownerAccepted,
        'provenanceState': provenanceState,
        'runtimeState': runtimeState,
        'canonicalExportPresent': canonicalExportPresent,
        'blockerCount': blockerCount,
        'violations': violations
            .map((PinkOwnerReviewViolation violation) => violation.toJson())
            .toList(growable: false),
      };

  String prettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String summary() =>
      'PINK OWNER REVIEW $state | owner $ownerStatus | provenance '
      '$provenanceState | runtime $runtimeState | export '
      '$canonicalExportPresent | blockers $blockerCount';
}

class PinkOwnerReviewGateAuditor {
  PinkOwnerReviewGateAuditor({required this.mobileRoot});

  final Directory mobileRoot;

  static const String variantId = 'lunch-box:pink';
  static const String sourceId = 'SRC-LUNCH-PINK-001';
  static const String candidateSha256 =
      '755ead90e98b51f2fd732c267c01671ffa776d59624565b7521bd4c4ac3f1776';
  static const String receiptPath =
      'docs/ui/PINK_OWNER_VISUAL_ACCEPTANCE.json';
  static const List<String> requiredReviewStages = <String>[
    'surfaceWhite',
    'surfaceIvory',
    'surfaceNavy',
    'downscale96',
    'downscale160',
    'downscale240',
    'downscale384',
    'geometryPreserved',
    'bakedUiExcluded',
    'referenceVsCandidate',
  ];

  PinkOwnerReviewReport audit() {
    final List<PinkOwnerReviewViolation> violations =
        <PinkOwnerReviewViolation>[];
    final Directory repo = mobileRoot.parent;

    final Map<String, dynamic> contract = _readJson(
      File('${repo.path}/docs/ui/PINK_SOURCE_EXTRACTION_CONTRACT.json'),
      'CONTRACT',
      violations,
    );
    final Map<String, dynamic> receipt = _readJson(
      File('${repo.path}/$receiptPath'),
      'OWNER-RECEIPT',
      violations,
    );
    final Map<String, dynamic> sourceAdmission = _readJson(
      File('${repo.path}/docs/ui/PRODUCTION_SOURCE_ADMISSION.json'),
      'SOURCE-ADMISSION',
      violations,
    );
    final Map<String, dynamic> provenance = _readJson(
      File('${repo.path}/docs/ui/PRODUCTION_ASSET_PROVENANCE.json'),
      'PROVENANCE',
      violations,
    );

    final Map<String, dynamic> candidate = _map(contract['reviewCandidate']);
    final String? candidateSha = candidate['sha256'] as String?;
    _expect(contract['variantId'] == variantId, 'CONTRACT-VARIANT',
        'Pink contract variant ID drifted.', violations);
    _expect(candidate['issue'] == 328, 'CANDIDATE-ISSUE',
        'Review candidate must remain tied to issue #328.', violations);
    _expect(
      candidate['state'] == 'MECHANICALLY_CLEAN_AWAITING_OWNER_REVIEW',
      'CANDIDATE-STATE',
      'Review candidate state must not imply production admission.',
      violations,
    );
    _expect(candidateSha == candidateSha256, 'CANDIDATE-SHA',
        'Review candidate SHA-256 drifted.', violations);
    _expect(_sha(candidateSha), 'CANDIDATE-SHA-FORMAT',
        'Review candidate SHA-256 format is invalid.', violations);
    _expect(candidate['byteSize'] == 683551, 'CANDIDATE-BYTES',
        'Review candidate byte size drifted.', violations);
    _expect(candidate['width'] == 1024 && candidate['height'] == 1024,
        'CANDIDATE-DIMENSIONS', 'Review candidate must remain 1024x1024.',
        violations);
    _expect(candidate['pixelFormat'] == '8-bit RGBA', 'CANDIDATE-FORMAT',
        'Review candidate must remain 8-bit RGBA.', violations);
    _expect(candidate['colorProfile'] == 'sRGB', 'CANDIDATE-SRGB',
        'Review candidate must remain sRGB.', violations);
    _expect(
      _ints(candidate['alphaBoundingBox']).equals(<int>[51, 128, 973, 895]),
      'CANDIDATE-BBOX',
      'Review candidate alpha bounding box drifted.',
      violations,
    );
    _expect(candidate['minimumTransparentSafeMarginPx'] == 51,
        'CANDIDATE-MARGIN', 'Review candidate safe margin drifted.', violations);
    _expect(candidate['sourceDerivedFromApprovedPanel'] == true,
        'CANDIDATE-SOURCE', 'Candidate must be approved-panel-derived.',
        violations);
    _expect(candidate['marketplacePixelsOutsidePanelExcluded'] == true,
        'CANDIDATE-MARKETPLACE',
        'Marketplace pixels outside the approved panel must stay excluded.',
        violations);
    _expect(candidate['automationCanAcceptFinalVisualFidelity'] == false,
        'AUTOMATION-BOUNDARY',
        'Automation must never be allowed to accept final visual fidelity.',
        violations);
    _expect(candidate['ownerAcceptanceReceipt'] == receiptPath,
        'RECEIPT-PATH', 'Owner acceptance receipt path drifted.', violations);

    final Map<String, dynamic> vproof = _map(candidate['vproof']);
    _expect(vproof['disposition'] == 'NO_OBVIOUS_HALO', 'VPROOF-DISPOSITION',
        'Review candidate mechanical VPROOF disposition drifted.', violations);
    _expect(vproof['partialAlphaEdgeCount'] == 14876, 'VPROOF-EDGE-COUNT',
        'Review candidate VPROOF edge count drifted.', violations);
    _expect(vproof['mismatchNearWhitePartialEdgeCount'] == 35,
        'VPROOF-MISMATCH-COUNT',
        'Review candidate VPROOF mismatch count drifted.', violations);

    final String? receiptSha = receipt['candidateSha256'] as String?;
    final String ownerStatus = '${receipt['status']}';
    final bool ownerAccepted = receipt['ownerAccepted'] == true;
    _expect(receipt['schemaVersion'] == 1, 'RECEIPT-SCHEMA',
        'Owner receipt schemaVersion must remain 1.', violations);
    _expect(receipt['variantId'] == variantId, 'RECEIPT-VARIANT',
        'Owner receipt variant ID drifted.', violations);
    _expect(receiptSha == candidateSha, 'RECEIPT-SHA',
        'Owner receipt must bind to the exact review candidate SHA.', violations);
    _expect(ownerStatus == 'PENDING' || ownerStatus == 'ACCEPTED',
        'RECEIPT-STATUS', 'Owner receipt status must be PENDING or ACCEPTED.',
        violations);
    _expect(ownerAccepted == (ownerStatus == 'ACCEPTED'),
        'RECEIPT-BOOLEAN',
        'ownerAccepted must exactly match the explicit receipt status.',
        violations);
    _expect(receipt['stablePublicationAuthorized'] == false,
        'GLOBAL-RELEASE-BOUNDARY',
        'Pink acceptance alone must never authorize stable publication.',
        violations);

    final List<String> stages = _strings(receipt['requiredReviewStages']);
    _expect(
      stages.length == requiredReviewStages.length &&
          stages.toSet().containsAll(requiredReviewStages),
      'REVIEW-STAGES',
      'Owner review stage set is incomplete.',
      violations,
    );
    final Map<String, dynamic> review = _map(receipt['review']);
    for (final String stage in requiredReviewStages) {
      final String value = '${review[stage]}';
      if (ownerAccepted) {
        _expect(value == 'PASS', 'REVIEW-$stage',
            '$stage must be PASS after explicit owner acceptance.', violations);
      } else {
        _expect(value == 'PENDING', 'REVIEW-$stage',
            '$stage must remain PENDING before owner acceptance.', violations);
      }
    }

    if (ownerAccepted) {
      final Object? actor = receipt['decisionActor'];
      final Object? decidedAt = receipt['decidedAt'];
      _expect(actor is String && actor.trim().isNotEmpty, 'DECISION-ACTOR',
          'Accepted owner receipt requires an explicit decision actor.',
          violations);
      _expect(
        decidedAt is String && DateTime.tryParse(decidedAt) != null,
        'DECISION-TIME',
        'Accepted owner receipt requires an ISO-8601 decision timestamp.',
        violations,
      );
    } else {
      _expect(receipt['decisionActor'] == null, 'PENDING-ACTOR',
          'Pending owner receipt must not claim a decision actor.', violations);
      _expect(receipt['decidedAt'] == null, 'PENDING-TIME',
          'Pending owner receipt must not claim a decision timestamp.', violations);
    }

    final Map<String, dynamic>? sourceRow = _row(sourceAdmission, variantId);
    final Map<String, dynamic>? provenanceRow = _row(provenance, variantId);
    _expect(sourceRow != null, 'SOURCE-ROW',
        'Pink source-admission row is missing.', violations);
    _expect(provenanceRow != null, 'PROVENANCE-ROW',
        'Pink provenance row is missing.', violations);

    String provenanceState = 'UNKNOWN';
    bool sourceExportPresent = false;
    if (sourceRow != null) {
      _expect(sourceRow['sourceId'] == sourceId, 'SOURCE-ID',
          'Pink source ID drifted.', violations);
      _expect(sourceRow['sourceState'] == 'APPROVED', 'SOURCE-STATE',
          'Pink source must remain APPROVED.', violations);
      sourceExportPresent = sourceRow['canonicalExportPresent'] == true;
    }

    if (provenanceRow != null) {
      provenanceState = '${provenanceRow['lifecycleState']}';
    }

    final _RuntimeState runtime = _runtimeState(violations);
    final bool allPending = provenanceState == 'PENDING' &&
        !sourceExportPresent &&
        runtime.state == 'pending' &&
        !runtime.exportPresent;
    final bool allAdmitted = provenanceState == 'ADMITTED' &&
        sourceExportPresent &&
        runtime.state == 'admitted' &&
        runtime.exportPresent;

    if (!ownerAccepted) {
      _expect(allPending, 'PREMATURE-ADMISSION',
          'Pink must remain fully quarantined until explicit owner acceptance.',
          violations);
      if (provenanceRow != null) {
        _expect(provenanceRow['sha256'] == null, 'PREMATURE-FINGERPRINT',
            'Pending Pink must not claim an admitted SHA-256.', violations);
      }
    } else {
      _expect(allPending || allAdmitted, 'PARTIAL-ADMISSION',
          'After owner acceptance Pink must be either fully pending or fully admitted; partial promotion is forbidden.',
          violations);
      if (allAdmitted && provenanceRow != null) {
        _expect(provenanceRow['sha256'] == candidateSha256, 'ADMITTED-SHA',
            'Admitted Pink SHA must match the explicitly accepted candidate.',
            violations);
        _expect(provenanceRow['byteSize'] == 683551, 'ADMITTED-BYTES',
            'Admitted Pink byte size must match the accepted candidate.',
            violations);
        _expect(provenanceRow['width'] == 1024 && provenanceRow['height'] == 1024,
            'ADMITTED-DIMENSIONS',
            'Admitted Pink dimensions must match the accepted candidate.',
            violations);
        _expect(
          _ints(provenanceRow['alphaBoundingBox'])
              .equals(<int>[51, 128, 973, 895]),
          'ADMITTED-BBOX',
          'Admitted Pink alpha bbox must match the accepted candidate.',
          violations,
        );
        _expect(provenanceRow['nearestTransparentSafeMargin'] == 51,
            'ADMITTED-MARGIN',
            'Admitted Pink safe margin must match the accepted candidate.',
            violations);
      }
    }

    return PinkOwnerReviewReport(
      violations: violations,
      reviewCandidateSha256: candidateSha,
      receiptCandidateSha256: receiptSha,
      ownerStatus: ownerStatus,
      ownerAccepted: ownerAccepted,
      provenanceState: provenanceState,
      runtimeState: runtime.state,
      canonicalExportPresent: sourceExportPresent && runtime.exportPresent,
    );
  }

  _RuntimeState _runtimeState(List<PinkOwnerReviewViolation> violations) {
    final File runtimeFile = File(
      '${mobileRoot.path}/lib/design_system/components/media/walka_product_media_admission.dart',
    );
    if (!runtimeFile.existsSync()) {
      violations.add(const PinkOwnerReviewViolation(
        'RUNTIME-FILE',
        'Runtime admission registry is missing.',
      ));
      return const _RuntimeState('UNKNOWN', false);
    }
    final String source = runtimeFile.readAsStringSync();
    const String startToken =
        "'lunch-box:pink': WalkaProductMediaAdmissionEntry(";
    const String endToken =
        "'lunch-box:green': WalkaProductMediaAdmissionEntry(";
    final int start = source.indexOf(startToken);
    final int end = start < 0 ? -1 : source.indexOf(endToken, start + 1);
    if (start < 0 || end < 0) {
      violations.add(const PinkOwnerReviewViolation(
        'RUNTIME-ROW',
        'Runtime Pink admission row is missing.',
      ));
      return const _RuntimeState('UNKNOWN', false);
    }
    final String block = source.substring(start, end);
    final String state = block.contains('WalkaProductMediaAdmissionState.admitted')
        ? 'admitted'
        : block.contains('WalkaProductMediaAdmissionState.pending')
            ? 'pending'
            : block.contains('WalkaProductMediaAdmissionState.blocked')
                ? 'blocked'
                : 'UNKNOWN';
    _expect(block.contains('sourceApproved: true'), 'RUNTIME-SOURCE',
        'Runtime Pink sourceApproved must remain true.', violations);
    _expect(
      block.contains("canonicalPath: 'assets/products/lunch/pink.png'"),
      'RUNTIME-PATH',
      'Runtime Pink canonical path drifted.',
      violations,
    );
    return _RuntimeState(
      state,
      block.contains('canonicalExportPresent: true'),
    );
  }

  Map<String, dynamic> _readJson(
    File file,
    String code,
    List<PinkOwnerReviewViolation> violations,
  ) {
    if (!file.existsSync()) {
      violations.add(PinkOwnerReviewViolation(
        '$code-MISSING',
        '${file.path} is missing.',
      ));
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } on Object catch (error) {
      violations.add(PinkOwnerReviewViolation(
        '$code-INVALID',
        'Could not parse ${file.path}: $error',
      ));
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic>? _row(Map<String, dynamic> document, String id) {
    final Object? rows = document['variants'];
    if (rows is! List<dynamic>) return null;
    for (final dynamic row in rows) {
      if (row is Map<String, dynamic> && row['variantId'] == id) return row;
    }
    return null;
  }

  Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  List<String> _strings(Object? value) => value is List<dynamic>
      ? value.whereType<String>().toList(growable: false)
      : <String>[];

  _IntList _ints(Object? value) => _IntList(
        value is List<dynamic>
            ? value.whereType<int>().toList(growable: false)
            : <int>[],
      );

  bool _sha(Object? value) =>
      value is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(value);

  void _expect(
    bool condition,
    String code,
    String message,
    List<PinkOwnerReviewViolation> violations,
  ) {
    if (!condition) violations.add(PinkOwnerReviewViolation(code, message));
  }
}

class _RuntimeState {
  const _RuntimeState(this.state, this.exportPresent);

  final String state;
  final bool exportPresent;
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
