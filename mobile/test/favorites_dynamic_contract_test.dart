import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/content/domain/walka_storefront_copy_content.dart';

void main() {
  test('storefront copy v1 carries governed Favorites and PDP favorite labels', () {
    final WalkaStorefrontCopyPayload payload =
        WalkaStorefrontCopyPayload.fromApiJson(_apiEnvelope());

    expect(payload.revision, 9);
    expect(payload.content.favoritesHeading, 'Saved things');
    expect(payload.content.favoritesRemoveLabel, 'Unsave');
    expect(payload.content.pdpFavoriteAddLabel, 'Keep it');
    expect(payload.content.pdpFavoriteRemoveLabel, 'Stop keeping it');
  });

  test('old Storefront copy cache without Favorites fields fails closed', () {
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

  test('new Favorites copy cache round-trips without changing revision identity', () {
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
        },
      },
      'meta': <String, dynamic>{'api_version': 'v1'},
    };
