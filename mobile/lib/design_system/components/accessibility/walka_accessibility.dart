import 'package:flutter/material.dart';

abstract final class WalkaA11y {
  static const double minimumTouchTarget = 48;

  static String joinLabels(Iterable<String?> parts) => parts
      .whereType<String>()
      .map((String value) => value.trim())
      .where((String value) => value.isNotEmpty)
      .join('. ');
}

/// Geometry/semantics wrapper only; gestures and feature state stay caller-owned.
class WalkaTouchTarget extends StatelessWidget {
  const WalkaTouchTarget({
    required this.child,
    super.key,
    this.semanticLabel,
    this.button = false,
    this.enabled = true,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final String? semanticLabel;
  final bool button;
  final bool enabled;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      button: button,
      enabled: enabled,
      excludeSemantics: semanticLabel != null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: WalkaA11y.minimumTouchTarget,
          minHeight: WalkaA11y.minimumTouchTarget,
        ),
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}
