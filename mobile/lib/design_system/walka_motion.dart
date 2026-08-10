import 'package:flutter/material.dart';

/// Shared motion contract for owner-visible WALKA surfaces.
///
/// WALKA motion is intentionally short and restrained. Any device or
/// accessibility request that disables animations collapses WALKA-owned motion
/// to zero duration while preserving the exact same interaction behavior.
abstract final class WalkaMotion {
  static const Duration fast = Duration(milliseconds: 110);
  static const Duration standard = Duration(milliseconds: 180);
  static const Duration emphasis = Duration(milliseconds: 240);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve emphasizedCurve = Curves.easeInOutCubic;

  static bool reduceMotion(BuildContext context) {
    final MediaQueryData? media = MediaQuery.maybeOf(context);
    if (media == null) return false;
    return media.disableAnimations || media.accessibleNavigation;
  }

  static Duration duration(
    BuildContext context,
    Duration requested,
  ) {
    return reduceMotion(context) ? Duration.zero : requested;
  }
}

/// Transform-only press feedback that never changes layout metrics and never
/// owns the gesture. The wrapped Material/InkWell remains responsible for tap,
/// focus, hover and semantics behavior.
class WalkaPressFeedback extends StatefulWidget {
  const WalkaPressFeedback({
    required this.child,
    super.key,
    this.pressedScale = 0.992,
  });

  final Widget child;
  final double pressedScale;

  @override
  State<WalkaPressFeedback> createState() => _WalkaPressFeedbackState();
}

class _WalkaPressFeedbackState extends State<WalkaPressFeedback> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: WalkaMotion.duration(context, WalkaMotion.fast),
        curve: WalkaMotion.standardCurve,
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
