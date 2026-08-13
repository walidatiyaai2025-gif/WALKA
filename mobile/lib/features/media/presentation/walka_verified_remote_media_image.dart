import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../domain/walka_remote_media.dart';
import '../walka_remote_media_state.dart';

class WalkaVerifiedRemoteMediaImage extends StatefulWidget {
  const WalkaVerifiedRemoteMediaImage({
    required this.item,
    required this.fallback,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticContext,
    this.cacheWidth,
    this.cacheHeight,
    super.key,
  });

  final WalkaRemoteMediaItem item;
  final Widget fallback;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final String? semanticContext;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  State<WalkaVerifiedRemoteMediaImage> createState() =>
      _WalkaVerifiedRemoteMediaImageState();
}

class _WalkaVerifiedRemoteMediaImageState
    extends State<WalkaVerifiedRemoteMediaImage> {
  Future<Uint8List>? _future;
  WalkaRemoteMediaController? _controller;
  String? _identity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshFutureIfNeeded();
  }

  @override
  void didUpdateWidget(covariant WalkaVerifiedRemoteMediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshFutureIfNeeded();
  }

  void _refreshFutureIfNeeded() {
    final WalkaRemoteMediaController? controller =
        WalkaRemoteMediaScope.maybeOf(context);
    final String identity = '${widget.item.mediaId}:${widget.item.sha256}';
    if (identical(controller, _controller) && identity == _identity) return;
    _controller = controller;
    _identity = identity;
    _future = controller?.loadBytes(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final Future<Uint8List>? future = _future;
    if (future == null) return widget.fallback;

    return FutureBuilder<Uint8List>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return widget.fallback;
        }
        final Uint8List bytes = snapshot.requireData;
        final String semanticLabel = <String>[
          widget.item.semanticLabel,
          if (widget.semanticContext?.trim().isNotEmpty ?? false)
            widget.semanticContext!.trim(),
        ].join('. ');

        return Image.memory(
          bytes,
          fit: widget.fit,
          alignment: widget.alignment,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          cacheWidth: widget.cacheWidth,
          cacheHeight: widget.cacheHeight,
          semanticLabel: semanticLabel,
          errorBuilder: (_, __, ___) => widget.fallback,
        );
      },
    );
  }
}
