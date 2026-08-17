import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/content/domain/walka_pdp_layout_content.dart';

void main() {
  test('PDP layout preserves order and optional visibility', () {
    final WalkaPdpLayoutContent content = WalkaPdpLayoutContent.fromJson(
      <String, dynamic>{
        'sections': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'identity', 'visible': true},
          <String, dynamic>{'id': 'gallery', 'visible': true},
          <String, dynamic>{'id': 'variants', 'visible': true},
          <String, dynamic>{'id': 'editorial', 'visible': false},
          <String, dynamic>{'id': 'facts', 'visible': true},
          <String, dynamic>{'id': 'usage', 'visible': false},
          <String, dynamic>{'id': 'specifications', 'visible': true},
          <String, dynamic>{'id': 'amazon_trust', 'visible': true},
        ],
      },
    );

    expect(content.sections.first.id, WalkaPdpSectionId.identity);
    expect(
      content.visibleSections.map((section) => section.id),
      isNot(contains(WalkaPdpSectionId.editorial)),
    );
  });

  test('protected PDP sections fail closed when hidden', () {
    final Map<String, dynamic> payload = WalkaPdpLayoutContent.bundled.toJson();
    final List<dynamic> sections = payload['sections']! as List<dynamic>;
    (sections.firstWhere((dynamic item) => (item as Map)['id'] == 'gallery') as Map)['visible'] = false;

    expect(
      () => WalkaPdpLayoutContent.fromJson(payload),
      throwsFormatException,
    );
  });

  test('API payload rejects wrong identity', () {
    expect(
      () => WalkaPdpLayoutPayload.fromApiJson(<String, dynamic>{
        'data': <String, dynamic>{
          'key': 'wrong.key',
          'type': 'pdp.layout',
          'schema_version': 1,
          'revision': 1,
          'published_at': '2026-08-17T00:00:00Z',
          'payload': WalkaPdpLayoutContent.bundled.toJson(),
        },
        'meta': <String, dynamic>{'api_version': 'v1'},
      }),
      throwsFormatException,
    );
  });
}
