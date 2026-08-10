import 'package:flutter/material.dart';

/// MediaQuery-driven shell safe area with no platform-name branching.
class WalkaSafeAreaChrome extends StatelessWidget {
  const WalkaSafeAreaChrome({
    required this.child,
    super.key,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.backgroundColor,
    this.minimum = EdgeInsets.zero,
  });

  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final Color? backgroundColor;
  final EdgeInsets minimum;

  @override
  Widget build(BuildContext context) {
    Widget result = SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum,
      child: child,
    );
    if (backgroundColor != null) {
      result = ColoredBox(color: backgroundColor!, child: result);
    }
    return result;
  }
}
