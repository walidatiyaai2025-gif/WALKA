import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/content/domain/walka_search_presentation_content.dart';

Map<String, dynamic> _payload({
  List<String>? variants,
  List<Map<String, dynamic>>? filters,
}) => <String, dynamic>{
      'heading': 'Find your WALKA fit',
      'supporting_copy': 'Search the current Dashboard catalog.',
      'placeholder': 'Search current products',
      'empty_title': 'No matches',
      'empty_body': 'Try another search.',
      'featured_variant_ids': variants ?? <String>['desk-kit:emerald', 'travel-mug:sand'],
      'filter_labels': filters ??
          <Map<String, dynamic>>[
            <String, dynamic>{'id': 'all', 'label': 'Everything'},
            <String, dynamic>{'id': 'workspace', 'label': 'Workspace'},
            <String, dynamic>{'id': 'travel', 'label': 'Travel'},
          ],
    };

void main() {
  test('bundled Search presentation contains no compiled catalog identities', () {
    final WalkaSearchPresentationContent content =
        WalkaSearchPresentationContent.bundled;

    expect(content.featuredVariantIds, isEmpty);
    expect(content.filterLabels, isEmpty);
    expect(content.heading, isEmpty);
  });

  test('API payload accepts arbitrary safe merchandising order', () {
    final WalkaSearchPresentationPayload payload =
        WalkaSearchPresentationPayload.fromApiJson(<String, dynamic>{
      'data': <String, dynamic>{
        'key': 'search.presentation',
        'type': 'search.presentation',
        'schema_version': 1,
        'revision': 7,
        'published_at': '2026-08-13T04:00:00Z',
        'payload': _payload(
          variants: <String>['travel-mug:sand', 'desk-kit:emerald'],
        ),
      },
      'meta': <String, dynamic>{'api_version': 'v1'},
    });

    expect(payload.revision, 7);
    expect(payload.content.heading, 'Find your WALKA fit');
    expect(payload.content.featuredVariantIds,
        <String>['travel-mug:sand', 'desk-kit:emerald']);
    expect(payload.content.filterLabel('workspace'), 'Workspace');
    expect(payload.content.filterLabel('unknown', 'Legacy fallback'), 'Legacy fallback');
  });

  test('duplicate arbitrary variant IDs fail closed', () {
    expect(
      () => WalkaSearchPresentationContent.fromJson(
        _payload(
          variants: <String>['desk-kit:emerald', 'desk-kit:emerald'],
        ),
      ),
      throwsFormatException,
    );
  });

  test('arbitrary safe filter identities are accepted but duplicates fail closed', () {
    final WalkaSearchPresentationContent content =
        WalkaSearchPresentationContent.fromJson(
      _payload(
        filters: <Map<String, dynamic>>[
          <String, dynamic>{'id': 'all', 'label': 'All'},
          <String, dynamic>{'id': 'new-category', 'label': 'New'},
        ],
      ),
    );
    expect(content.filterLabel('new-category'), 'New');

    expect(
      () => WalkaSearchPresentationContent.fromJson(
        _payload(
          filters: <Map<String, dynamic>>[
            <String, dynamic>{'id': 'all', 'label': 'All'},
            <String, dynamic>{'id': 'travel', 'label': 'Travel'},
            <String, dynamic>{'id': 'travel', 'label': 'Again'},
          ],
        ),
      ),
      throwsFormatException,
    );
  });

  test('All filter remains the only structural filter requirement', () {
    expect(
      () => WalkaSearchPresentationContent.fromJson(
        _payload(
          filters: <Map<String, dynamic>>[
            <String, dynamic>{'id': 'workspace', 'label': 'Workspace'},
          ],
        ),
      ),
      throwsFormatException,
    );
  });
}
