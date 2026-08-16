import 'dart:convert';
import 'dart:io';

import 'gray_owner_presentation_gate.dart';
import 'pink_owner_review_gate.dart';

class VisualReleaseViolation {
  const VisualReleaseViolation(this.code, this.message);

  final String code;
  final String message;

  Map<String, String> toJson() => <String, String>{
        'code': code,
        'message': message,
      };
}

class VisualReleaseGateReport {
  const VisualReleaseGateReport({
    required this.violations,
    required this.releaseBlockers,
    required this.productionAssetsReady,
    required this.productionReadyCount,
    required this.productionRequiredCount,
    required this.pinkReport,
    required this.grayReport,
    required this.screenStates,
    required this.finalDecision,
    required this.ownerAccepted,
    required this.currentVisualInputDigest,
    required this.acceptedVisualInputDigest,
    required this.acceptedSourceCommit,
    required this.acceptedApkSha256,
    required this.stablePublicationAuthorized,
  });

  final List<VisualReleaseViolation> violations;
  final List<String> releaseBlockers;
  final bool productionAssetsReady;
  final int productionReadyCount;
  final int productionRequiredCount;
  final PinkOwnerReviewReport pinkReport;
  final GrayOwnerDecisionReport grayReport;
  final Map<String, String> screenStates;
  final String finalDecision;
  final bool ownerAccepted;
  final String? currentVisualInputDigest;
  final String? acceptedVisualInputDigest;
  final String? acceptedSourceCommit;
  final String? acceptedApkSha256;
  final bool stablePublicationAuthorized;

  int get contractBlockerCount =>
      violations.length + pinkReport.blockerCount + grayReport.blockerCount;
  bool get contractValid => contractBlockerCount == 0;
  bool get stableReleaseReady =>
      contractValid &&
      releaseBlockers.isEmpty &&
      productionAssetsReady &&
      pinkReport.ownerAccepted &&
      grayReport.ownerApproved &&
      ownerAccepted &&
      stablePublicationAuthorized;

  String get state {
    if (!contractValid) return 'INVALID';
    return stableReleaseReady ? 'READY' : 'BLOCKED';
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': 1,
        'state': state,
        'contractValid': contractValid,
        'stableReleaseReady': stableReleaseReady,
        'contractBlockerCount': contractBlockerCount,
        'releaseBlockerCount': releaseBlockers.length,
        'releaseBlockers': releaseBlockers,
        'productionAssets': <String, Object?>{
          'ready': productionAssetsReady,
          'readyCount': productionReadyCount,
          'requiredCount': productionRequiredCount,
        },
        'pinkOwnerGate': pinkReport.toJson(),
        'grayOwnerGate': grayReport.toJson(),
        'ownerScreenAcceptance': <String, Object?>{
          'screenStates': screenStates,
          'finalDecision': finalDecision,
          'ownerAccepted': ownerAccepted,
          'currentVisualInputDigest': currentVisualInputDigest,
          'acceptedVisualInputDigest': acceptedVisualInputDigest,
          'acceptedSourceCommit': acceptedSourceCommit,
          'acceptedApkSha256': acceptedApkSha256,
          'stablePublicationAuthorized': stablePublicationAuthorized,
        },
        'violations': violations
            .map((VisualReleaseViolation item) => item.toJson())
            .toList(growable: false),
      };

  String prettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String summary() =>
      'VISUAL RELEASE $state | production $productionReadyCount/'
      '$productionRequiredCount | pink ${pinkReport.state} | gray '
      '${grayReport.state} | owner $finalDecision | release blockers '
      '${releaseBlockers.length} | contract blockers $contractBlockerCount';
}

class VisualReleaseGateAuditor {
  VisualReleaseGateAuditor({
    required this.mobileRoot,
    required this.productionReport,
    this.currentVisualInputDigest,
  });

  final Directory mobileRoot;
  final File productionReport;
  final String? currentVisualInputDigest;

  static const List<String> requiredScreenGroups = <String>[
    'home',
    'discovery',
    'pdp',
    'favorites',
    'account_about',
  ];
  static const Set<String> allowedScreenStates = <String>{
    'PENDING',
    'PASS',
    'BLOCKED',
  };
  static const Set<String> allowedFinalDecisions = <String>{
    'PENDING',
    'ACCEPTED',
    'BLOCKED',
  };
  static const List<String> visualDigestScope = <String>[
    'mobile/lib',
    'mobile/assets',
    'mobile/pubspec.yaml',
  ];

  VisualReleaseGateReport audit() {
    final List<VisualReleaseViolation> violations = <VisualReleaseViolation>[];
    final List<String> releaseBlockers = <String>[];
    final Directory repo = mobileRoot.parent;

    final Map<String, dynamic> production = _readJson(
      productionReport,
      'PRODUCTION-REPORT',
      violations,
    );
    final Map<String, dynamic> acceptance = _readJson(
      File('${repo.path}/docs/ui/VISUAL_RELEASE_OWNER_ACCEPTANCE.json'),
      'OWNER-ACCEPTANCE',
      violations,
    );

    final PinkOwnerReviewReport pinkReport =
        PinkOwnerReviewGateAuditor(mobileRoot: mobileRoot).audit();
    final GrayOwnerDecisionReport grayReport =
        GrayOwnerPresentationGateAuditor(mobileRoot: mobileRoot).audit();

    _expect(production['schemaVersion'] == 2, 'PRODUCTION-SCHEMA',
        'Production asset readiness report schemaVersion must be 2.',
        violations);
    final bool productionReady = production['ready'] == true;
    final int productionReadyCount = _int(production['readyCount']);
    final int productionRequiredCount = _int(production['requiredCount']);
    _expect(productionRequiredCount == 5, 'PRODUCTION-REQUIRED-COUNT',
        'Production readiness must cover exactly five released variants.',
        violations);
    _expect(productionReadyCount >= 0 && productionReadyCount <= 5,
        'PRODUCTION-READY-COUNT',
        'Production readyCount must be between 0 and 5.', violations);
    _expect(productionReady == (productionReadyCount == 5),
        'PRODUCTION-READY-CONSISTENCY',
        'Production ready flag must agree with five-of-five readiness.',
        violations);

    _expect(acceptance['schemaVersion'] == 1, 'ACCEPTANCE-SCHEMA',
        'Final visual acceptance schemaVersion must remain 1.', violations);
    _expect(acceptance['visualBlockerIssue'] == 230, 'ACCEPTANCE-ISSUE',
        'Final visual acceptance must remain tied to blocker #230.', violations);

    final List<String> requiredGroups = _strings(acceptance['requiredScreenGroups']);
    _expect(_sameStringSet(requiredGroups, requiredScreenGroups),
        'SCREEN-GROUPS', 'Required owner screen group set drifted.', violations);
    final List<String> allowedStates = _strings(acceptance['allowedScreenStates']);
    _expect(_sameStringSet(allowedStates, allowedScreenStates.toList()),
        'SCREEN-STATES', 'Allowed screen-state set drifted.', violations);
    final List<String> allowedDecisions =
        _strings(acceptance['allowedFinalDecisions']);
    _expect(_sameStringSet(allowedDecisions, allowedFinalDecisions.toList()),
        'FINAL-DECISIONS', 'Allowed final-decision set drifted.', violations);
    final List<String> digestScope = _strings(acceptance['visualInputDigestScope']);
    _expect(_sameStringList(digestScope, visualDigestScope), 'DIGEST-SCOPE',
        'Visual input digest scope drifted.', violations);

    final Map<String, dynamic> rawScreenStates = _map(acceptance['screenGroups']);
    _expect(rawScreenStates.keys.toSet().length == requiredScreenGroups.length &&
        rawScreenStates.keys.toSet().containsAll(requiredScreenGroups),
        'SCREEN-MAP',
        'Owner screen acceptance map must contain exactly the required groups.',
        violations);
    final Map<String, String> screenStates = <String, String>{};
    for (final String group in requiredScreenGroups) {
      final String state = '${rawScreenStates[group]}';
      screenStates[group] = state;
      _expect(allowedScreenStates.contains(state), 'SCREEN-$group',
          '$group has an invalid owner acceptance state.', violations);
    }

    final String finalDecision = '${acceptance['finalDecision']}';
    final bool ownerAccepted = acceptance['ownerAccepted'] == true;
    final bool finalAccepted = finalDecision == 'ACCEPTED';
    _expect(allowedFinalDecisions.contains(finalDecision), 'FINAL-DECISION',
        'Final owner decision is invalid.', violations);
    _expect(ownerAccepted == finalAccepted, 'OWNER-BOOLEAN',
        'ownerAccepted must exactly match finalDecision=ACCEPTED.', violations);

    final bool stableAuthorized =
        acceptance['stablePublicationAuthorized'] == true;
    final String? acceptedDigest = acceptance['acceptedVisualInputDigest'] as String?;
    final String? acceptedSourceCommit = acceptance['acceptedSourceCommit'] as String?;
    final String? acceptedApkSha = acceptance['acceptedApkSha256'] as String?;

    if (ownerAccepted) {
      for (final String group in requiredScreenGroups) {
        _expect(screenStates[group] == 'PASS', 'OWNER-PASS-$group',
            '$group must be PASS for final owner acceptance.', violations);
      }
      _expect(_sha256(acceptedDigest), 'ACCEPTED-DIGEST',
          'Final acceptance requires a 64-hex visual input digest.', violations);
      _expect(_gitSha(acceptedSourceCommit), 'ACCEPTED-SOURCE-COMMIT',
          'Final acceptance requires a 40-hex reviewed source commit.',
          violations);
      _expect(_sha256(acceptedApkSha), 'ACCEPTED-APK-SHA',
          'Final acceptance requires the reviewed APK SHA-256.', violations);
      final Object? actor = acceptance['decisionActor'];
      final Object? decidedAt = acceptance['decidedAt'];
      _expect(actor is String && actor.trim().isNotEmpty, 'DECISION-ACTOR',
          'Final acceptance requires an explicit decision actor.', violations);
      _expect(decidedAt is String && DateTime.tryParse(decidedAt) != null,
          'DECISION-TIME',
          'Final acceptance requires an ISO-8601 decision timestamp.',
          violations);
      _expect(stableAuthorized, 'STABLE-AUTH',
          'Final accepted receipt must explicitly authorize stable publication.',
          violations);
    } else {
      _expect(!stableAuthorized, 'PREMATURE-STABLE-AUTH',
          'Stable publication cannot be authorized before final owner acceptance.',
          violations);
      _expect(acceptedDigest == null, 'PENDING-DIGEST',
          'Non-accepted receipt must not claim an accepted visual digest.',
          violations);
      _expect(acceptedSourceCommit == null, 'PENDING-SOURCE-COMMIT',
          'Non-accepted receipt must not claim an accepted source commit.',
          violations);
      _expect(acceptedApkSha == null, 'PENDING-APK-SHA',
          'Non-accepted receipt must not claim an accepted APK SHA.', violations);
      _expect(acceptance['decisionActor'] == null, 'PENDING-ACTOR',
          'Non-accepted receipt must not claim a decision actor.', violations);
      _expect(acceptance['decidedAt'] == null, 'PENDING-TIME',
          'Non-accepted receipt must not claim a decision timestamp.', violations);
    }

    if (!productionReady) releaseBlockers.add('production-assets-not-ready');
    if (!pinkReport.ownerAccepted) {
      releaseBlockers.add('pink-owner-visual-acceptance-pending');
    }
    if (!grayReport.ownerApproved) {
      releaseBlockers.add('gray-owner-presentation-decision-pending');
    }
    if (!ownerAccepted) {
      releaseBlockers.add('final-owner-screen-acceptance-pending');
    }
    if (ownerAccepted) {
      if (!_sha256(currentVisualInputDigest)) {
        releaseBlockers.add('current-visual-input-digest-unavailable');
      } else if (currentVisualInputDigest != acceptedDigest) {
        releaseBlockers.add('accepted-visual-input-digest-stale');
      }
    }

    return VisualReleaseGateReport(
      violations: violations,
      releaseBlockers: releaseBlockers,
      productionAssetsReady: productionReady,
      productionReadyCount: productionReadyCount,
      productionRequiredCount: productionRequiredCount,
      pinkReport: pinkReport,
      grayReport: grayReport,
      screenStates: screenStates,
      finalDecision: finalDecision,
      ownerAccepted: ownerAccepted,
      currentVisualInputDigest: currentVisualInputDigest,
      acceptedVisualInputDigest: acceptedDigest,
      acceptedSourceCommit: acceptedSourceCommit,
      acceptedApkSha256: acceptedApkSha,
      stablePublicationAuthorized: stableAuthorized,
    );
  }

  Map<String, dynamic> _readJson(
    File file,
    String code,
    List<VisualReleaseViolation> violations,
  ) {
    if (!file.existsSync()) {
      violations.add(VisualReleaseViolation(
        '$code-MISSING',
        '${file.path} is missing.',
      ));
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } on Object catch (error) {
      violations.add(VisualReleaseViolation(
        '$code-INVALID',
        'Could not parse ${file.path}: $error',
      ));
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  List<String> _strings(Object? value) => value is List<dynamic>
      ? value.whereType<String>().toList(growable: false)
      : <String>[];

  int _int(Object? value) => value is int ? value : -1;

  bool _sha256(Object? value) =>
      value is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(value);

  bool _gitSha(Object? value) =>
      value is String && RegExp(r'^[0-9a-f]{40}$').hasMatch(value);

  bool _sameStringSet(List<String> left, List<String> right) =>
      left.length == right.length && left.toSet().containsAll(right);

  bool _sameStringList(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (int index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }

  void _expect(
    bool condition,
    String code,
    String message,
    List<VisualReleaseViolation> violations,
  ) {
    if (!condition) violations.add(VisualReleaseViolation(code, message));
  }
}
