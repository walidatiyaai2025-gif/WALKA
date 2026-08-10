import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../walka_theme.dart';

abstract final class WalkaResponsiveGridMetrics {
  static int columnsForWidth({
    required double width,
    required double minItemWidth,
    required double gap,
    int maxColumns = 4,
  }) {
    if (width <= 0 || !width.isFinite) return 1;
    final int calculated = ((width + gap) / (minItemWidth + gap)).floor();
    return math.max(1, math.min(maxColumns, calculated));
  }
}

/// Non-scrolling responsive grid primitive for composition inside page scrolls.
class WalkaResponsiveGrid extends StatelessWidget {
  const WalkaResponsiveGrid({
    required this.children,
    super.key,
    this.minItemWidth = 220,
    this.maxColumns = 4,
    this.gap = WalkaSpacing.md,
    this.runGap,
  })  : assert(minItemWidth > 0),
        assert(maxColumns > 0),
        assert(gap >= 0);

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double gap;
  final double? runGap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final int columns = WalkaResponsiveGridMetrics.columnsForWidth(
          width: width,
          minItemWidth: minItemWidth,
          gap: gap,
          maxColumns: maxColumns,
        );
        final double itemWidth = math.max(
          0,
          (width - (columns - 1) * gap) / columns,
        );

        return Wrap(
          spacing: gap,
          runSpacing: runGap ?? gap,
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
    );
  }
}
