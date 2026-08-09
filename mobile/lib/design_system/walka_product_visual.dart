import 'package:flutter/material.dart';

import 'walka_theme.dart';

enum WalkaProductVisualKind { drawerOrganizer, lunchBox }

/// Lightweight, asset-free product presentation used by premium storefront
/// surfaces. The visual intentionally communicates the real product family
/// instead of falling back to generic Material icons while keeping the app
/// fast and deterministic in offline/preview builds.
class WalkaProductVisual extends StatelessWidget {
  const WalkaProductVisual({
    required this.kind,
    required this.primaryColor,
    this.backgroundColor = Colors.transparent,
    this.compact = false,
    this.semanticLabel,
    super.key,
  });

  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color backgroundColor;
  final bool compact;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final String label = semanticLabel ?? switch (kind) {
      WalkaProductVisualKind.drawerOrganizer => 'WALKA drawer organizer',
      WalkaProductVisualKind.lunchBox => 'WALKA stainless steel lunch box',
    };

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _WalkaProductPainter(
              kind: kind,
              primaryColor: primaryColor,
              backgroundColor: backgroundColor,
              compact: compact,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _WalkaProductPainter extends CustomPainter {
  const _WalkaProductPainter({
    required this.kind,
    required this.primaryColor,
    required this.backgroundColor,
    required this.compact,
  });

  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color backgroundColor;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    _paintAtmosphere(canvas, size);
    switch (kind) {
      case WalkaProductVisualKind.drawerOrganizer:
        _paintDrawer(canvas, size);
      case WalkaProductVisualKind.lunchBox:
        _paintLunchBox(canvas, size);
    }
  }

  void _paintAtmosphere(Canvas canvas, Size size) {
    if (backgroundColor == Colors.transparent) return;

    final Rect bounds = Offset.zero & size;
    final Paint paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.18, -0.18),
        radius: 0.95,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.42),
          backgroundColor.withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const <double>[0, 0.56, 1],
      ).createShader(bounds);
    canvas.drawRect(bounds, paint);
  }

  void _paintDrawer(Canvas canvas, Size size) {
    final double radius = size.shortestSide * (compact ? 0.065 : 0.08);
    final Rect outer = Rect.fromLTWH(
      size.width * 0.07,
      size.height * 0.24,
      size.width * 0.86,
      size.height * 0.54,
    );
    final RRect outerRRect = RRect.fromRectAndRadius(
      outer,
      Radius.circular(radius),
    );
    final Path shadow = Path()..addRRect(outerRRect);
    canvas.drawShadow(
      shadow,
      Colors.black.withValues(alpha: 0.28),
      compact ? 6 : 12,
      false,
    );

    canvas.drawRRect(
      outerRRect,
      Paint()..color = primaryColor,
    );
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = compact ? 1.4 : 2
        ..color = Colors.white.withValues(alpha: 0.88),
    );

    final Rect inner = outer.deflate(outer.width * 0.045);
    final double gap = inner.width * 0.023;
    final double cellWidth = (inner.width - gap * 3) / 4;
    final double cellHeight = (inner.height - gap) / 2;
    final Color divider = WalkaColors.navy.withValues(alpha: 0.16);
    final Color compartmentFill = Colors.white.withValues(alpha: 0.46);

    for (int row = 0; row < 2; row += 1) {
      for (int column = 0; column < 4; column += 1) {
        final Rect cell = Rect.fromLTWH(
          inner.left + column * (cellWidth + gap),
          inner.top + row * (cellHeight + gap),
          cellWidth,
          cellHeight,
        );
        final RRect cellRRect = RRect.fromRectAndRadius(
          cell,
          Radius.circular(radius * 0.42),
        );
        canvas.drawRRect(cellRRect, Paint()..color = compartmentFill);
        canvas.drawRRect(
          cellRRect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = compact ? 0.8 : 1.1
            ..color = divider,
        );
      }
    }

    final Rect brandBar = Rect.fromLTWH(
      outer.left + outer.width * 0.38,
      outer.bottom - outer.height * 0.055,
      outer.width * 0.24,
      compact ? 2 : 3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(brandBar, const Radius.circular(99)),
      Paint()..color = WalkaColors.gold.withValues(alpha: 0.92),
    );
  }

  void _paintLunchBox(Canvas canvas, Size size) {
    final double radius = size.shortestSide * (compact ? 0.07 : 0.085);
    final Rect body = Rect.fromLTWH(
      size.width * 0.09,
      size.height * 0.20,
      size.width * 0.82,
      size.height * 0.60,
    );
    final RRect bodyRRect = RRect.fromRectAndRadius(
      body,
      Radius.circular(radius),
    );
    final Path shadow = Path()..addRRect(bodyRRect);
    canvas.drawShadow(
      shadow,
      Colors.black.withValues(alpha: 0.28),
      compact ? 6 : 12,
      false,
    );
    canvas.drawRRect(bodyRRect, Paint()..color = primaryColor);

    final Rect tray = body.deflate(body.width * 0.075);
    final RRect trayRRect = RRect.fromRectAndRadius(
      tray,
      Radius.circular(radius * 0.66),
    );
    canvas.drawRRect(
      trayRRect,
      Paint()..color = const Color(0xFFF4F5F3),
    );
    canvas.drawRRect(
      trayRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = compact ? 1.2 : 1.8
        ..color = const Color(0xFFCBD2D5),
    );

    final double gap = tray.width * 0.025;
    final double leftWidth = tray.width * 0.56;
    final double rightWidth = tray.width - leftWidth - gap;
    final Rect large = Rect.fromLTWH(
      tray.left,
      tray.top,
      leftWidth,
      tray.height,
    );
    final double rightCellHeight = (tray.height - gap) / 2;
    final Rect topRight = Rect.fromLTWH(
      large.right + gap,
      tray.top,
      rightWidth,
      rightCellHeight,
    );
    final Rect bottomRight = Rect.fromLTWH(
      large.right + gap,
      topRight.bottom + gap,
      rightWidth,
      rightCellHeight,
    );

    for (final Rect compartment in <Rect>[large, topRight, bottomRight]) {
      final RRect cell = RRect.fromRectAndRadius(
        compartment.deflate(gap * 0.22),
        Radius.circular(radius * 0.38),
      );
      canvas.drawRRect(
        cell,
        Paint()..color = Colors.white.withValues(alpha: 0.72),
      );
      canvas.drawRRect(
        cell,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = compact ? 0.8 : 1.1
          ..color = const Color(0xFFB9C2C7),
      );
    }

    final Offset cupCenter = Offset(
      large.left + large.width * 0.76,
      large.top + large.height * 0.31,
    );
    canvas.drawCircle(
      cupCenter,
      large.width * 0.105,
      Paint()..color = const Color(0xFFD9DDDE),
    );
    canvas.drawCircle(
      cupCenter,
      large.width * 0.105,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = compact ? 1 : 1.5
        ..color = const Color(0xFFAAB4B9),
    );

    final Paint latchPaint = Paint()..color = WalkaColors.navy.withValues(alpha: 0.32);
    final double latchWidth = body.width * 0.11;
    final double latchHeight = compact ? 3 : 4;
    for (final double x in <double>[body.left + body.width * 0.22, body.right - body.width * 0.33]) {
      final Rect latch = Rect.fromLTWH(
        x,
        body.bottom + size.height * 0.012,
        latchWidth,
        latchHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(latch, const Radius.circular(99)),
        latchPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WalkaProductPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.compact != compact;
  }
}
