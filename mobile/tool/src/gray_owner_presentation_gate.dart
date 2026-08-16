import 'dart:convert';
import 'dart:io';

class GrayOwnerDecisionViolation {
  const GrayOwnerDecisionViolation(this.code, this.message);

  final String code;
  final String message;

  Map<String, String> toJson() => <String, String>{
        'code': code,
        'message': message,
      };
}

class GrayOwnerDecisionReport {
  const GrayOwnerDecisionReport({
    required this.violations,
    required this.decision,
    required this.ownerApproved,
    required this.sourceState,
    required this.provenanceState,
    required this.runtimeState,
    required this.canonicalExportPresent,
  });

  final List<GrayOwnerDecisionViolation> violations;
  final String decision;
  final bool ownerApproved;
  final String sourceState;
  final String provenanceState;
  final String runtimeState;
  final bool canonicalExportPresent;

  int get blockerCount => violations.length;
  bool get gateReady => blockerCount == 0;
  bool get fullyAdmitted =>
      sourceState == 'APPROVED' &&
      provenanceState == 'ADMITTED' &&
      runtimeState == 'admitted' &&
      canonicalExportPresent;

  String get state {
    if (!gateReady) return 'BLOCKED';
    if (!ownerApproved) return 'AWAITING_OWNER_DECISION';
    return fullyAdmitted
        ? 'OWNER_APPROVED_ADMISSION_RECONCILED'
        : 'OWNER_APPROVED_AWAITING_ADMISSION';
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': 1,
        'state': state,
        'gateReady': gateReady,
        'variantId': GrayOwnerPresentationGateAuditor.variantId,
        'decision': decision,
        'ownerApproved': ownerApproved,
        'sourceState': sourceState,
        'provenanceState': provenanceState,
        'runtimeState': runtimeState,
        'canonicalExportPresent': canonicalExportPresent,
        'fullyAdmitted': fullyAdmitted,
        'blockerCount': blockerCount,
        'violations': violations
            .map((GrayOwnerDecisionViolation item) => item.toJson())
            .toList(growable: false),
      };

  String prettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String summary() =>
      'GRAY OWNER DECISION $state | decision $decision | source $sourceState | '
      'provenance $provenanceState | runtime $runtimeState | export '
      '$canonicalExportPresent | blockers $blockerCount';
}

class GrayOwnerPresentationGateAuditor {
  GrayOwnerPresentationGateAuditor({required this.mobileRoot});

  final Directory mobileRoot;

  static const String variantId = 'drawer-organizer:gray';
  static const String currentSourceFilename = 'IMG-20250919-WA0035.jpg';
  static const String receiptPath = 'docs/ui/GRAY_OWNER_PRESENTATION_DECISION.json';
  static const Set<String> allowedDecisions = <String>{
    'PENDING',
    'APPROVED_EXPANDED_SOURCE',
    'APPROVED_COLLAPSED_PRESENTATION',
  };

  GrayOwnerDecisionReport audit() {
    final List<GrayOwnerDecisionViolation> violations =
        <GrayOwnerDecisionViolation>[];
    final Directory repo = mobileRoot.parent;

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

    final String decision = '${receipt['decision']}';
    final bool ownerApproved = receipt['ownerApproved'] == true;
    final bool decisionApproved = decision != 'PENDING';

    _expect(receipt['schemaVersion'] == 1, 'RECEIPT-SCHEMA',
        'Gray owner decision schemaVersion must remain 1.', violations);
    _expect(receipt['variantId'] == variantId, 'RECEIPT-VARIANT',
        'Gray owner decision variant ID drifted.', violations);
    _expect(receipt['assetIssue'] == 201, 'RECEIPT-ASSET-ISSUE',
        'Gray decision must remain tied to asset issue #201.', violations);
    _expect(receipt['visualBlockerIssue'] == 230, 'RECEIPT-BLOCKER-ISSUE',
        'Gray decision must remain tied to visual blocker #230.', violations);
    _expect(allowedDecisions.contains(decision), 'RECEIPT-DECISION',
        'Gray decision is not an allowed state.', violations);
    _expect(ownerApproved == decisionApproved, 'RECEIPT-BOOLEAN',
        'ownerApproved must exactly match an explicit approved decision.',
        violations);
    _expect(receipt['admissionAuthorized'] == ownerApproved,
        'RECEIPT-ADMISSION-AUTH',
        'admissionAuthorized must exactly match explicit owner approval.',
        violations);
    _expect(receipt['stablePublicationAuthorized'] == false,
        'GLOBAL-RELEASE-BOUNDARY',
        'Gray presentation approval alone must never authorize stable publication.',
        violations);

    final Map<String, dynamic> currentSource = _map(receipt['currentOwnerSource']);
    _expect(currentSource['filename'] == currentSourceFilename,
        'CURRENT-SOURCE-NAME', 'Current Gray owner source filename drifted.',
        violations);
    _expect(currentSource['presentation'] == 'COLLAPSED',
        'CURRENT-SOURCE-PRESENTATION',
        'Current Gray owner source must remain classified as COLLAPSED.',
        violations);
    _expect(currentSource['sourceState'] == 'BLOCKED_FOR_EXPANDED_PARITY',
        'CURRENT-SOURCE-STATE',
        'Current Gray source must remain blocked for expanded parity until owner decision.',
        violations);

    if (ownerApproved) {
      final Object? filename = receipt['approvedSourceFilename'];
      final Object? sha = receipt['approvedSourceSha256'];
      final Object? actor = receipt['decisionActor'];
      final Object? decidedAt = receipt['decidedAt'];
      _expect(filename is String && filename.trim().isNotEmpty,
          'APPROVED-SOURCE-NAME',
          'Approved Gray decision requires the exact approved source filename.',
          violations);
      _expect(_sha(sha), 'APPROVED-SOURCE-SHA',
          'Approved Gray decision requires a 64-hex source SHA-256.', violations);
      _expect(actor is String && actor.trim().isNotEmpty, 'DECISION-ACTOR',
          'Approved Gray decision requires an explicit decision actor.',
          violations);
      _expect(decidedAt is String && DateTime.tryParse(decidedAt) != null,
          'DECISION-TIME',
          'Approved Gray decision requires an ISO-8601 decision timestamp.',
          violations);
      if (decision == 'APPROVED_COLLAPSED_PRESENTATION') {
        _expect(filename == currentSourceFilename, 'COLLAPSED-SOURCE-NAME',
            'Collapsed-presentation approval must bind to the current real Gray source.',
            violations);
      }
    } else {
      _expect(receipt['approvedSourceFilename'] == null,
          'PENDING-APPROVED-SOURCE',
          'Pending Gray decision must not claim an approved source filename.',
          violations);
      _expect(receipt['approvedSourceSha256'] == null, 'PENDING-SOURCE-SHA',
          'Pending Gray decision must not claim an approved source SHA-256.',
          violations);
      _expect(receipt['decisionActor'] == null, 'PENDING-ACTOR',
          'Pending Gray decision must not claim a decision actor.', violations);
      _expect(receipt['decidedAt'] == null, 'PENDING-TIME',
          'Pending Gray decision must not claim a decision timestamp.', violations);
    }

    final Map<String, dynamic>? sourceRow = _row(sourceAdmission, variantId);
    final Map<String, dynamic>? provenanceRow = _row(provenance, variantId);
    _expect(sourceRow != null, 'SOURCE-ROW',
        'Gray source-admission row is missing.', violations);
    _expect(provenanceRow != null, 'PROVENANCE-ROW',
        'Gray provenance row is missing.', violations);

    String sourceState = 'UNKNOWN';
    String provenanceState = 'UNKNOWN';
    bool sourceExportPresent = false;
    if (sourceRow != null) {
      sourceState = '${sourceRow['sourceState']}';
      sourceExportPresent = sourceRow['canonicalExportPresent'] == true;
      _expect(sourceRow['canonicalPath'] == 'assets/products/drawer/gray.png',
          'SOURCE-PATH', 'Gray canonical source path drifted.', violations);
      if (ownerApproved && sourceState == 'APPROVED') {
        _expect(sourceRow['sourceFilename'] == receipt['approvedSourceFilename'],
            'SOURCE-FILENAME-MATCH',
            'Admitted Gray source filename must match the owner-approved receipt.',
            violations);
      }
    }
    if (provenanceRow != null) {
      provenanceState = '${provenanceRow['lifecycleState']}';
      _expect(provenanceRow['canonicalPath'] == 'assets/products/drawer/gray.png',
          'PROVENANCE-PATH', 'Gray provenance canonical path drifted.',
          violations);
    }

    final _GrayRuntimeState runtime = _runtimeState(violations);
    final bool fullyBlocked = sourceState == 'BLOCKED' &&
        !sourceExportPresent &&
        provenanceState == 'BLOCKED' &&
        runtime.state == 'blocked' &&
        !runtime.exportPresent &&
        !runtime.sourceApproved;
    final bool fullyAdmitted = sourceState == 'APPROVED' &&
        sourceExportPresent &&
        provenanceState == 'ADMITTED' &&
        runtime.state == 'admitted' &&
        runtime.exportPresent &&
        runtime.sourceApproved;

    if (!ownerApproved) {
      _expect(fullyBlocked, 'PREMATURE-ADMISSION',
          'Gray must remain fully blocked until explicit owner presentation/source approval.',
          violations);
    } else {
      _expect(fullyBlocked || fullyAdmitted, 'PARTIAL-ADMISSION',
          'After Gray owner approval the asset must be either fully blocked-awaiting-admission or fully admitted; partial promotion is forbidden.',
          violations);
    }

    return GrayOwnerDecisionReport(
      violations: violations,
      decision: decision,
      ownerApproved: ownerApproved,
      sourceState: sourceState,
      provenanceState: provenanceState,
      runtimeState: runtime.state,
      canonicalExportPresent: sourceExportPresent && runtime.exportPresent,
    );
  }

  _GrayRuntimeState _runtimeState(
    List<GrayOwnerDecisionViolation> violations,
  ) {
    final File runtimeFile = File(
      '${mobileRoot.path}/lib/design_system/components/media/walka_product_media_admission.dart',
    );
    if (!runtimeFile.existsSync()) {
      violations.add(const GrayOwnerDecisionViolation(
        'RUNTIME-FILE',
        'Runtime admission registry is missing.',
      ));
      return const _GrayRuntimeState('UNKNOWN', false, false);
    }
    final String source = runtimeFile.readAsStringSync();
    const String startToken =
        "'drawer-organizer:gray': WalkaProductMediaAdmissionEntry(";
    const String endToken =
        "'lunch-box:blue': WalkaProductMediaAdmissionEntry(";
    final int start = source.indexOf(startToken);
    final int end = start < 0
        ? -1
        : source.indexOf(endToken, start + startToken.length);
    if (start < 0 || end < 0) {
      violations.add(const GrayOwnerDecisionViolation(
        'RUNTIME-ROW',
        'Runtime Gray admission row is missing.',
      ));
      return const _GrayRuntimeState('UNKNOWN', false, false);
    }
    final String block = source.substring(start, end);
    final String state =
        block.contains('WalkaProductMediaAdmissionState.admitted')
            ? 'admitted'
            : block.contains('WalkaProductMediaAdmissionState.blocked')
                ? 'blocked'
                : block.contains('WalkaProductMediaAdmissionState.pending')
                    ? 'pending'
                    : 'UNKNOWN';
    return _GrayRuntimeState(
      state,
      block.contains('canonicalExportPresent: true'),
      block.contains('sourceApproved: true'),
    );
  }

  Map<String, dynamic> _readJson(
    File file,
    String code,
    List<GrayOwnerDecisionViolation> violations,
  ) {
    if (!file.existsSync()) {
      violations.add(GrayOwnerDecisionViolation(
        '$code-MISSING',
        '${file.path} is missing.',
      ));
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } on Object catch (error) {
      violations.add(GrayOwnerDecisionViolation(
        '$code-INVALID',
        'Could not parse ${file.path}: $error',
      ));
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

  bool _sha(Object? value) =>
      value is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(value);

  void _expect(
    bool condition,
    String code,
    String message,
    List<GrayOwnerDecisionViolation> violations,
  ) {
    if (!condition) violations.add(GrayOwnerDecisionViolation(code, message));
  }
}

class _GrayRuntimeState {
  const _GrayRuntimeState(this.state, this.exportPresent, this.sourceApproved);

  final String state;
  final bool exportPresent;
  final bool sourceApproved;
}
