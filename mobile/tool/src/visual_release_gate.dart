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
    required this.currentReleaseInputDigest,
    required this.acceptedReleaseInputDigest,
    required this.acceptedSourceCommit,
    required this.acceptedApkSha256,
    required this.acceptedWorkflowRunId,
    required this.acceptedArtifactId,
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
  final String? currentReleaseInputDigest;
  final String? acceptedReleaseInputDigest;
  final String? acceptedSourceCommit;
  final String? acceptedApkSha256;
  final int? acceptedWorkflowRunId;
  final int? acceptedArtifactId;
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
        'schemaVersion': 2,
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
          'currentReleaseInputDigest': currentReleaseInputDigest,
          'acceptedReleaseInputDigest': acceptedReleaseInputDigest,
          'acceptedSourceCommit': acceptedSourceCommit,
          'acceptedApkSha256': acceptedApkSha256,
          'acceptedWorkflowRunId': acceptedWorkflowRunId,
          'acceptedArtifactId': acceptedArtifactId,
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
    this.currentReleaseInputDigest,
  });

  final Directory mobileRoot;
  final File productionReport;
  final String? currentVisualInputDigest;
  final String? currentReleaseInputDigest;

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
  static const List<String> releaseDigestScope = <String>[
    'mobile/lib',
    'mobile/assets',
    'mobile/pubspec.yaml',
    'mobile/pubspec.lock',
    'mobile/tool/apply_android_branding.sh',
    'docs/ui/RELEASE_TOOLCHAIN_CONTRACT.json',
    '.github/workflows/flutter-preview.yml',
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
    final Map<String, dynamic> toolchain = _readJson(
      File('${repo.path}/docs/ui/RELEASE_TOOLCHAIN_CONTRACT.json'),
      'TOOLCHAIN',
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

    _validateToolchain(toolchain, repo, violations);

    _expect(acceptance['schemaVersion'] == 2, 'ACCEPTANCE-SCHEMA',
        'Final visual acceptance schemaVersion must remain 2.', violations);
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
    final List<String> visualScope = _strings(acceptance['visualInputDigestScope']);
    _expect(_sameStringList(visualScope, visualDigestScope), 'VISUAL-DIGEST-SCOPE',
        'Visual input digest scope drifted.', violations);
    final List<String> releaseScope = _strings(acceptance['releaseInputDigestScope']);
    _expect(_sameStringList(releaseScope, releaseDigestScope),
        'RELEASE-DIGEST-SCOPE', 'Release input digest scope drifted.', violations);

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
    final String? acceptedVisualDigest =
        acceptance['acceptedVisualInputDigest'] as String?;
    final String? acceptedReleaseDigest =
        acceptance['acceptedReleaseInputDigest'] as String?;
    final String? acceptedSourceCommit = acceptance['acceptedSourceCommit'] as String?;
    final String? acceptedApkSha = acceptance['acceptedApkSha256'] as String?;
    final int? acceptedWorkflowRunId = acceptance['acceptedWorkflowRunId'] as int?;
    final int? acceptedArtifactId = acceptance['acceptedArtifactId'] as int?;

    if (ownerAccepted) {
      for (final String group in requiredScreenGroups) {
        _expect(screenStates[group] == 'PASS', 'OWNER-PASS-$group',
            '$group must be PASS for final owner acceptance.', violations);
      }
      _expect(_sha256(acceptedVisualDigest), 'ACCEPTED-VISUAL-DIGEST',
          'Final acceptance requires a 64-hex visual input digest.', violations);
      _expect(_sha256(acceptedReleaseDigest), 'ACCEPTED-RELEASE-DIGEST',
          'Final acceptance requires a 64-hex release input digest.', violations);
      _expect(_gitSha(acceptedSourceCommit), 'ACCEPTED-SOURCE-COMMIT',
          'Final acceptance requires a 40-hex reviewed source commit.',
          violations);
      _expect(_sha256(acceptedApkSha), 'ACCEPTED-APK-SHA',
          'Final acceptance requires the reviewed APK SHA-256.', violations);
      _expect(acceptedWorkflowRunId != null && acceptedWorkflowRunId > 0,
          'ACCEPTED-WORKFLOW-RUN',
          'Final acceptance requires the reviewed workflow run ID.', violations);
      _expect(acceptedArtifactId != null && acceptedArtifactId > 0,
          'ACCEPTED-ARTIFACT',
          'Final acceptance requires the reviewed APK artifact ID.', violations);
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
      _expect(acceptedVisualDigest == null, 'PENDING-VISUAL-DIGEST',
          'Non-accepted receipt must not claim an accepted visual digest.',
          violations);
      _expect(acceptedReleaseDigest == null, 'PENDING-RELEASE-DIGEST',
          'Non-accepted receipt must not claim an accepted release digest.',
          violations);
      _expect(acceptedSourceCommit == null, 'PENDING-SOURCE-COMMIT',
          'Non-accepted receipt must not claim an accepted source commit.',
          violations);
      _expect(acceptedApkSha == null, 'PENDING-APK-SHA',
          'Non-accepted receipt must not claim an accepted APK SHA.', violations);
      _expect(acceptedWorkflowRunId == null, 'PENDING-WORKFLOW-RUN',
          'Non-accepted receipt must not claim a workflow run.', violations);
      _expect(acceptedArtifactId == null, 'PENDING-ARTIFACT',
          'Non-accepted receipt must not claim an APK artifact.', violations);
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
      } else if (currentVisualInputDigest != acceptedVisualDigest) {
        releaseBlockers.add('accepted-visual-input-digest-stale');
      }
      if (!_sha256(currentReleaseInputDigest)) {
        releaseBlockers.add('current-release-input-digest-unavailable');
      } else if (currentReleaseInputDigest != acceptedReleaseDigest) {
        releaseBlockers.add('accepted-release-input-digest-stale');
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
      acceptedVisualInputDigest: acceptedVisualDigest,
      currentReleaseInputDigest: currentReleaseInputDigest,
      acceptedReleaseInputDigest: acceptedReleaseDigest,
      acceptedSourceCommit: acceptedSourceCommit,
      acceptedApkSha256: acceptedApkSha,
      acceptedWorkflowRunId: acceptedWorkflowRunId,
      acceptedArtifactId: acceptedArtifactId,
      stablePublicationAuthorized: stableAuthorized,
    );
  }

  void _validateToolchain(
    Map<String, dynamic> toolchain,
    Directory repo,
    List<VisualReleaseViolation> violations,
  ) {
    _expect(toolchain['schemaVersion'] == 1, 'TOOLCHAIN-SCHEMA',
        'Release toolchain schemaVersion must remain 1.', violations);
    _expect(toolchain['visualBlockerIssue'] == 230, 'TOOLCHAIN-ISSUE',
        'Release toolchain contract must remain tied to blocker #230.',
        violations);
    final Map<String, dynamic> flutter = _map(toolchain['flutter']);
    _expect(flutter['channel'] == 'stable', 'TOOLCHAIN-FLUTTER-CHANNEL',
        'Release Flutter channel must remain stable.', violations);
    _expect(flutter['version'] == '3.47.0', 'TOOLCHAIN-FLUTTER-VERSION',
        'Release Flutter version must remain pinned to 3.47.0.', violations);
    _expect(
        flutter['frameworkRevision'] ==
            '4cf24164269a5ebf0c16a028a00727d0e77bbb05',
        'TOOLCHAIN-FLUTTER-REVISION',
        'Release Flutter framework revision drifted.',
        violations);
    _expect(flutter['dartVersion'] == '3.13.0', 'TOOLCHAIN-DART-VERSION',
        'Release Dart version must remain 3.13.0.', violations);
    final Map<String, dynamic> java = _map(toolchain['java']);
    _expect(java['distribution'] == 'temurin', 'TOOLCHAIN-JAVA-DIST',
        'Release Java distribution must remain temurin.', violations);
    _expect(java['majorVersion'] == 17, 'TOOLCHAIN-JAVA-VERSION',
        'Release Java major version must remain 17.', violations);
    final Map<String, dynamic> dependencyLock =
        _map(toolchain['dependencyLock']);
    _expect(dependencyLock['path'] == 'mobile/pubspec.lock',
        'DEPENDENCY-LOCK-PATH', 'Dependency lock path drifted.', violations);
    _expect(dependencyLock['required'] == true, 'DEPENDENCY-LOCK-REQUIRED',
        'Dependency lock must remain required.', violations);
    _expect(dependencyLock['enforceLockfile'] == true,
        'DEPENDENCY-LOCK-ENFORCE',
        'Release dependency resolution must enforce the lockfile.', violations);
    _expect(File('${repo.path}/mobile/pubspec.lock').existsSync(),
        'DEPENDENCY-LOCK-MISSING',
        'mobile/pubspec.lock must be committed for release reproducibility.',
        violations);
    _expect(
        toolchain['androidBootstrap'] ==
            'flutter create --platforms=android --project-name walka .',
        'TOOLCHAIN-ANDROID-BOOTSTRAP',
        'Android bootstrap recipe drifted.',
        violations);
    _expect(toolchain['brandingScript'] == 'mobile/tool/apply_android_branding.sh',
        'TOOLCHAIN-BRANDING', 'Branding script contract drifted.', violations);
    _expect(toolchain['releaseBuildCommand'] == 'flutter build apk --release',
        'TOOLCHAIN-BUILD-COMMAND', 'Release build command drifted.', violations);
    _expect(
        _sameStringList(
            _strings(toolchain['releaseInputDigestScope']), releaseDigestScope),
        'TOOLCHAIN-RELEASE-SCOPE',
        'Toolchain release input digest scope drifted.',
        violations);
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
