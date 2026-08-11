import 'dart:convert';
import 'dart:io';

const List<String> vfinOwnerVisibleSurfaces = <String>[
  'home',
  'discovery',
  'productDetail',
  'favorites',
  'about',
];

class VfinReleaseSnapshot {
  const VfinReleaseSnapshot({
    required this.admitted,
    required this.pending,
    required this.blocked,
    required this.variantStates,
  });

  final int admitted;
  final int pending;
  final int blocked;
  final Map<String, String> variantStates;

  bool get productionMediaReady => admitted == 5 && pending == 0 && blocked == 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'schemaVersion': 1,
        'productionMedia': <String, dynamic>{
          'state': productionMediaReady ? 'READY' : 'BLOCKED',
          'admitted': admitted,
          'pending': pending,
          'blocked': blocked,
          'variants': variantStates,
        },
        'ownerVisualAcceptance': <String, dynamic>{
          'state': 'REQUIRES_OWNER_REVIEW',
          'surfaces': <String, String>{
            for (final String surface in vfinOwnerVisibleSurfaces)
              surface: 'REQUIRES_OWNER_REVIEW',
          },
        },
      };
}

VfinReleaseSnapshot vfinSnapshotFromProvenance(Map<String, dynamic> root) {
  final Object? rawRows = root['variants'];
  if (rawRows is! List) {
    throw const FormatException('Production provenance must expose variants.');
  }

  final Map<String, String> states = <String, String>{};
  int admitted = 0;
  int pending = 0;
  int blocked = 0;

  for (final dynamic raw in rawRows) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Every provenance variant must be an object.');
    }
    final String id = raw['variantId'] as String;
    final String state = raw['lifecycleState'] as String;
    if (states.containsKey(id)) {
      throw FormatException('Duplicate production variant: $id');
    }
    states[id] = state;
    switch (state) {
      case 'ADMITTED':
        admitted += 1;
      case 'PENDING':
        pending += 1;
      case 'BLOCKED':
        blocked += 1;
      default:
        throw FormatException('Unknown lifecycle state $state for $id');
    }
  }

  if (states.length != 5) {
    throw FormatException('Expected exactly five released variants; found ${states.length}.');
  }

  return VfinReleaseSnapshot(
    admitted: admitted,
    pending: pending,
    blocked: blocked,
    variantStates: Map<String, String>.unmodifiable(states),
  );
}

VfinReleaseSnapshot vfinSnapshotFromFile(String path) {
  final Map<String, dynamic> root =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return vfinSnapshotFromProvenance(root);
}

String vfinStableJson(VfinReleaseSnapshot snapshot) =>
    const JsonEncoder.withIndent('  ').convert(snapshot.toJson());
