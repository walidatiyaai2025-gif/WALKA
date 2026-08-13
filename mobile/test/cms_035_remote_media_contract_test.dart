import 'package:flutter_test/flutter_test.dart';
import 'package:walka/core/api/walka_api_client.dart';
import 'package:walka/features/media/domain/walka_remote_media.dart';

void main() {
  const String lowercaseUlid = '01arz3ndektsv4rrffq69g5fav';
  const String sha =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  test('lowercase backend ULID remains valid and is preserved in delivery path', () {
    final WalkaRemoteMediaItem item = WalkaRemoteMediaItem.fromJson(
      <String, dynamic>{
        'media_id': lowercaseUlid,
        'position': 1,
        'semantic_label': 'WALKA verified product image',
        'canonical': <String, dynamic>{
          'mime': 'image/png',
          'bytes': 1024,
          'width': 1200,
          'height': 1200,
          'sha256': sha,
        },
      },
    );
    const WalkaApiSettings settings = WalkaApiSettings(
      baseUrl: 'https://api.walkastore.com',
    );

    expect(item.mediaId, lowercaseUlid);
    expect(
      settings.canonicalMediaEndpoint(item.mediaId).toString(),
      'https://api.walkastore.com/api/v1/media/assets/$lowercaseUlid/canonical',
    );
  });

  test('canonical endpoint rejects path injection instead of accepting a URL', () {
    const WalkaApiSettings settings = WalkaApiSettings(
      baseUrl: 'https://api.walkastore.com',
    );

    expect(
      () => settings.canonicalMediaEndpoint('../$lowercaseUlid'),
      throwsFormatException,
    );
  });
}
