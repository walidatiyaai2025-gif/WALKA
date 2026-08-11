import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/vfin_release_snapshot.dart';

void main() {
  test('repository snapshot counts exactly five production variants', () {
    final VfinReleaseSnapshot snapshot = vfinSnapshotFromFile(
      '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json',
    );
    expect(snapshot.variantStates, hasLength(5));
    expect(snapshot.admitted + snapshot.pending + snapshot.blocked, 5);
  });

  test('mechanical 5/5 does not fabricate owner visual acceptance', () {
    final Map<String, dynamic> synthetic = <String, dynamic>{
      'variants': <Map<String, dynamic>>[
        for (int index = 0; index < 5; index += 1)
          <String, dynamic>{
            'variantId': 'variant-$index',
            'lifecycleState': 'ADMITTED',
          },
      ],
    };
    final VfinReleaseSnapshot snapshot = vfinSnapshotFromProvenance(synthetic);
    expect(snapshot.productionMediaReady, isTrue);

    final Map<String, dynamic> report = jsonDecode(vfinStableJson(snapshot))
        as Map<String, dynamic>;
    final Map<String, dynamic> visual =
        report['ownerVisualAcceptance'] as Map<String, dynamic>;
    expect(visual['state'], 'REQUIRES_OWNER_REVIEW');
    final Map<String, dynamic> surfaces =
        visual['surfaces'] as Map<String, dynamic>;
    expect(surfaces.keys.toSet(), vfinOwnerVisibleSurfaces.toSet());
    expect(surfaces.values.toSet(), <String>{'REQUIRES_OWNER_REVIEW'});
  });

  test('pending or blocked production media keeps mechanical release blocked', () {
    final Map<String, dynamic> source = jsonDecode(
      File('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final VfinReleaseSnapshot snapshot = vfinSnapshotFromProvenance(source);
    if (snapshot.pending > 0 || snapshot.blocked > 0) {
      expect(snapshot.productionMediaReady, isFalse);
    }
  });

  test('unknown lifecycle state is rejected instead of guessed', () {
    expect(
      () => vfinSnapshotFromProvenance(<String, dynamic>{
        'variants': <Map<String, dynamic>>[
          <String, dynamic>{'variantId': 'a', 'lifecycleState': 'ADMITTED'},
          <String, dynamic>{'variantId': 'b', 'lifecycleState': 'ADMITTED'},
          <String, dynamic>{'variantId': 'c', 'lifecycleState': 'ADMITTED'},
          <String, dynamic>{'variantId': 'd', 'lifecycleState': 'ADMITTED'},
          <String, dynamic>{'variantId': 'e', 'lifecycleState': 'UNKNOWN'},
        ],
      }),
      throwsFormatException,
    );
  });
}
