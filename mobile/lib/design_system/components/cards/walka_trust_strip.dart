import 'package:flutter/material.dart';

import '../../walka_theme.dart';

/// Responsive container for WALKA trust/benefit content.
///
/// The strip owns only presentation. Benefit wording remains with feature
/// composition so unsupported claims cannot leak into the design system.
class WalkaTrustStrip extends StatelessWidget {
  const WalkaTrustStrip({
    required this.children,
    super.key,
    this.semanticLabel,
    this.backgroundColor = WalkaColors.navy,
    this.padding = const EdgeInsets.all(WalkaSpacing.md),
    this.spacing = WalkaSpacing.sm,
    this.runSpacing = WalkaSpacing.sm,
    this.radius = WalkaRadius.md,
  }) : assert(children.length > 0);

  final List<Widget> children;
  final String? semanticLabel;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double runSpacing;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final Widget strip = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (!constraints.hasBoundedWidth) {
              return Wrap(
                spacing: spacing,
                runSpacing: runSpacing,
                children: children,
              );
            }

            final int maxColumns = constraints.maxWidth >= 720
                ? 4
                : constraints.maxWidth >= 360
                    ? 2
                    : 1;
            final int columns =
                children.length < maxColumns ? children.length : maxColumns;
            final double itemWidth = columns == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: runSpacing,
              children: children
                  .map(
                    (Widget child) => SizedBox(
                      width: itemWidth,
                      child: child,
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: WalkaColors.white),
        child: IconTheme(
          data: const IconThemeData(color: WalkaColors.gold),
          child: strip,
        ),
      ),
    );
  }
}
