import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'data/walka_remote_media_repository.dart';
import 'data/walka_verified_remote_media_loader.dart';
import 'domain/walka_remote_media.dart';

class WalkaRemoteMediaController extends ChangeNotifier {
  WalkaRemoteMediaController({
    required WalkaRemoteMediaRepository repository,
    required WalkaVerifiedRemoteMediaLoader binaryLoader,
  })  : _repository = repository,
        binaryLoader = binaryLoader;

  final WalkaRemoteMediaRepository _repository;
  final WalkaVerifiedRemoteMediaLoader binaryLoader;

  WalkaRemoteMediaSnapshot? _snapshot;
  bool _isLoading = false;

  WalkaRemoteMediaSnapshot? get snapshot => _snapshot;
  bool get isLoading => _isLoading;
  bool get hasRemoteMetadata => _snapshot != null &&
      _snapshot!.source != WalkaRemoteMediaSource.bundled;

  List<WalkaRemoteMediaItem> galleryForVariant(String variantId) =>
      _snapshot?.galleryForVariant(variantId) ?? const <WalkaRemoteMediaItem>[];

  WalkaRemoteMediaItem? firstForVariant(String variantId) =>
      _snapshot?.firstForVariant(variantId);

  WalkaRemoteMediaItem? firstForSlot(String slotKey) =>
      _snapshot?.firstForSlot(slotKey);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _snapshot = await _repository.load();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Uint8List> loadBytes(WalkaRemoteMediaItem item) =>
      binaryLoader.load(item);

  @override
  void dispose() {
    binaryLoader.close();
    super.dispose();
  }
}

class WalkaRemoteMediaScope extends InheritedNotifier<WalkaRemoteMediaController> {
  const WalkaRemoteMediaScope({
    required WalkaRemoteMediaController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static WalkaRemoteMediaController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WalkaRemoteMediaScope>()
        ?.notifier;
  }
}
