import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/content/domain/walka_search_presentation_content.dart';

void main() {
  test('bundled Search presentation preserves exact released identity sets', () {
    final WalkaSearchPresentationContent content =
        WalkaSearchPresentationContent.bundled;

    expect(content.featuredVariantIds, hasLength(5));
    expect(content.featuredVariantIds.toSet(),
        WalkaSearchPresentationContent.protectedVariantIds);
    expect(
      content.filterLabels.map((WalkaSearchFilterLabel item) => item.id).toSet(),
      WalkaSearchPresentationContent.protectedFilterIds,
    );
  });

  test('API payload accepts safe copy and deterministic merchandising order', () {
    final WalkaSearchPresentationPayload payload =
        WalkaSearchPresentationPayload.fromApiJson(<String, dynamic>{
      'data': <String, dynamic>{
        'key': 'search.presentation',
        'type': 'search.presentation',
        'schema_version': 1,
        'revision': 7,
        'published_at': '2026-08-13T04:00:00Z',
        'payload': <String, dynamic>{
          ...WalkaSearchPresentationContent.bundled.toJson(),
          'heading': 'Find your WALKA fit',
          'featured_variant_ids': <String>[
            'lunch-box:green',
            'drawer-organizer:gray',
            'lunch-box:blue',
            'drawer-organizer:white',
            'lunch-box:pink',
          ],
        },
      },
      'meta': <String, dynamic>{'api_version': 'v1'},
    });

    expect(payload.revision, 7);
    expect(payload.content.heading, 'Find your WALKA fit');
    expect(payload.content.featuredVariantIds.first, 'lunch-box:green');
    expect(payload.content.featuredVariantIds, hasLength(5));
  });

  test('missing or duplicate released variants fail closed', () {
    final Map<String, dynamic> base =
        WalkaSearchPresentationContent.bundled.toJson();

    expect(
      () => WalkaSearchPresentationContent.fromJson(<String, dynamic>{
        ...base,
        'featured_variant_ids': <String>[
          'drawer-organizer:white',
          'drawer-organizer:gray',
          'lunch-box:blue',
          'lunch-box:pink',
        ],
      }),
      throwsFormatException,
    );

    expect(
      () => WalkaSearchPresentationContent.fromJson(<String, dynamic>{
        ...base,
        'featured_variant_ids': <String>[
          'drawer-organizer:white',
          'drawer-organizer:gray',
          'lunch-box:blue',
          'lunch-box:pink',
          'lunch-box:pink',
        ],
      }),
      throwsFormatException,
    );
  });

  test('unknown filter identity fails closed', () {
    final Map<String, dynamic> base =
        WalkaSearchPresentationContent.bundled.toJson();
    expect(
      () => WalkaSearchPresentationContent.fromJson(<String, dynamic>{
        ...base,
        'filter_labels': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'all', 'label': 'All'},
          <String, dynamic>{'id': 'drawer-organization', 'label': 'Drawer'},
          <String, dynamic>{'id': 'unknown', 'label': 'Unknown'},
        ],
      }),
      throwsFormatException,
    );
  });
}
