import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/content/domain/walka_related_products_content.dart';

void main() {
  test('related products accept arbitrary dynamic catalog IDs', () {
    final WalkaRelatedProductsContent content =
        WalkaRelatedProductsContent.fromJson(<String, dynamic>{
      'relationships': <Map<String, dynamic>>[
        <String, dynamic>{
          'product_id': 'bento-pro',
          'related_product_ids': <String>['desk-organizer', 'travel-mug'],
          'url': 'https://example.com/ignored',
        },
        <String, dynamic>{
          'product_id': 'travel-mug',
          'related_product_ids': <String>['bento-pro'],
        },
      ],
    });

    expect(
      content.relatedIdsFor('bento-pro'),
      <String>['desk-organizer', 'travel-mug'],
    );
    expect(content.toJson().toString(), isNot(contains('example.com')));
  });

  test('self, duplicate and oversized recommendations fail closed', () {
    expect(
      () => WalkaRelatedProductsContent.fromJson(<String, dynamic>{
        'relationships': <Map<String, dynamic>>[
          <String, dynamic>{
            'product_id': 'alpha',
            'related_product_ids': <String>['alpha'],
          },
        ],
      }),
      throwsFormatException,
    );

    expect(
      () => WalkaRelatedProductsContent.fromJson(<String, dynamic>{
        'relationships': <Map<String, dynamic>>[
          <String, dynamic>{
            'product_id': 'alpha',
            'related_product_ids': <String>['beta', 'beta'],
          },
        ],
      }),
      throwsFormatException,
    );

    expect(
      () => WalkaRelatedProductsContent.fromJson(<String, dynamic>{
        'relationships': <Map<String, dynamic>>[
          <String, dynamic>{
            'product_id': 'alpha',
            'related_product_ids': <String>[
              'beta',
              'gamma',
              'delta',
              'epsilon',
              'zeta',
            ],
          },
        ],
      }),
      throwsFormatException,
    );
  });

  test('API payload carries IDs only and validates identity', () {
    final WalkaRelatedProductsPayload payload =
        WalkaRelatedProductsPayload.fromApiJson(<String, dynamic>{
      'data': <String, dynamic>{
        'key': 'pdp.related_products',
        'type': 'pdp.related_products',
        'schema_version': 1,
        'revision': 7,
        'published_at': '2026-08-17T00:00:00Z',
        'payload': <String, dynamic>{
          'relationships': <Map<String, dynamic>>[
            <String, dynamic>{
              'product_id': 'alpha',
              'related_product_ids': <String>['beta'],
            },
          ],
        },
      },
      'meta': <String, dynamic>{'api_version': 'v1'},
    });

    expect(payload.revision, 7);
    expect(payload.content.relatedIdsFor('alpha'), <String>['beta']);
  });
}
