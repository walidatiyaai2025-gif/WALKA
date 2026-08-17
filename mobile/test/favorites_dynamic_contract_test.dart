import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/content/domain/walka_storefront_copy_content.dart';

const String _informationJson =
    '{"account":{"eyebrow":"WALKA","title":"Account","body":"Current information."},'
    '"story":{"eyebrow":"WALKA","title":"Story","body":"Current story."},'
    '"faq":{"eyebrow":"HELP","title":"FAQ","intro":"Current help.","items":[{"question":"Q","answer":"A"}]},'
    '"contact":{"eyebrow":"SUPPORT","title":"Contact","intro":"Current routes.","links":[{"title":"Web","body":"Official site.","label":"OPEN","url":"https://example.com"}]},'
    '"amazon_store":{"eyebrow":"SHOP","title":"Store","body":"Official store.","label":"OPEN","url":"https://example.com/store"},'
    '"social":{"eyebrow":"SOCIAL","title":"Social","intro":"Official social.","links":[{"title":"Social","body":"Official account.","label":"OPEN","url":"https://example.com/social"}]},'
    '"privacy":{"eyebrow":"LEGAL","title":"Privacy","intro":"Current privacy.","sections":[{"title":"Data","body":"Current policy."}]},'
    '"terms":{"eyebrow":"LEGAL","title":"Terms","intro":"Current terms.","sections":[{"title":"Use","body":"Current terms."}]}}';

void main() {
  test('storefront copy carries governed Favorites and dynamic information', () {
    final WalkaStorefrontCopyPayload payload =
        WalkaStorefrontCopyPayload.fromApiJson(_apiEnvelope());

    expect(payload.revision, 9);
    expect(payload.content.favoritesHeading, 'Saved things');
    expect(payload.content.favoritesRemoveLabel, 'Unsave');
    expect(payload.content.pdpFavoriteAddLabel, 'Keep it');
    expect(payload.content.pdpFavoriteRemoveLabel, 'Stop keeping it');
    expect(payload.content.informationJson, _informationJson);
  });

  test('old Storefront copy cache without dynamic information fails closed', () {
    final Map<String, dynamic> cache = <String, dynamic>{
      'cache_schema': 1,
      'revision': 8,
      'published_at': '2026-08-16T12:00:00Z',
      'fetched_at': '2026-08-16T12:01:00Z',
      'payload': <String, dynamic>{
        'categories_heading': 'Categories',
        'categories_body': 'Browse.',
        'pdp_unavailable': 'Unavailable.',
        'pdp_colors_label': 'Colors',
        'pdp_features_label': 'Features',
        'pdp_details_label': 'Details',
        'pdp_buy_label': 'Buy',
        'pdp_asin_label': 'ASIN',
      },
    };

    expect(
      () => WalkaStorefrontCopySnapshot.fromCacheJson(cache),
      throwsFormatException,
    );
  });

  test('schema-2 Storefront copy cache round-trips revision and information', () {
    final WalkaStorefrontCopyPayload payload =
        WalkaStorefrontCopyPayload.fromApiJson(_apiEnvelope());
    final WalkaStorefrontCopySnapshot remote = WalkaStorefrontCopySnapshot(
      content: payload.content,
      revision: payload.revision,
      publishedAt: payload.publishedAt,
      fetchedAt: DateTime.utc(2026, 8, 16, 12, 2),
      source: WalkaContentSource.remote,
    );

    final WalkaStorefrontCopySnapshot cached =
        WalkaStorefrontCopySnapshot.fromCacheJson(remote.toCacheJson());

    expect(cached.revision, remote.revision);
    expect(cached.source, WalkaContentSource.cache);
    expect(cached.content.toJson(), remote.content.toJson());
    expect(cached.content.informationJson, _informationJson);
  });
}

Map<String, dynamic> _apiEnvelope() => <String, dynamic>{
      'data': <String, dynamic>{
        'key': 'storefront.copy',
        'type': 'storefront.copy',
        'schema_version': 1,
        'revision': 9,
        'published_at': '2026-08-16T12:00:00Z',
        'payload': <String, dynamic>{
          'categories_heading': 'Collections',
          'categories_body': 'Browse what is live now.',
          'favorites_heading': 'Saved things',
          'favorites_body': 'Your current saved catalog variants.',
          'favorites_empty_title': 'Nothing saved',
          'favorites_empty_body': 'Open a product and save a current variant.',
          'favorites_explore_label': 'Browse now',
          'favorites_remove_label': 'Unsave',
          'pdp_unavailable': 'Unavailable.',
          'pdp_colors_label': 'Finishes',
          'pdp_features_label': 'Highlights',
          'pdp_details_label': 'Specifications',
          'pdp_buy_label': 'Continue to Amazon',
          'pdp_asin_label': 'ASIN',
          'pdp_favorite_add_label': 'Keep it',
          'pdp_favorite_remove_label': 'Stop keeping it',
          'information_json': _informationJson,
        },
      },
      'meta': <String, dynamic>{'api_version': 'v1'},
    };
