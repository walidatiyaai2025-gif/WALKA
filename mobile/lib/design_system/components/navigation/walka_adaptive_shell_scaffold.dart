import 'package:flutter/material.dart';

import '../../walka_platform_adaptive.dart';
import 'walka_mobile_shell_scaffold.dart';
import 'walka_shell_controller.dart';
import 'walka_wide_shell_scaffold.dart';

/// Selects the released mobile shell below tablet width and the wide shell for
/// tablet/desktop windows so wide layouts are no longer forced through 560px.
class WalkaAdaptiveShellScaffold extends StatelessWidget {
  const WalkaAdaptiveShellScaffold({
    required this.controller,
    required this.pages,
    super.key,
    this.wideLeading,
  });

  final WalkaShellController controller;
  final List<Widget> pages;
  final Widget? wideLeading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final WalkaWindowClass windowClass =
            WalkaPlatformAdaptive.windowClassForWidth(width);
        final bool wide = windowClass == WalkaWindowClass.tablet ||
            windowClass == WalkaWindowClass.desktop;

        if (wide) {
          return WalkaWideShellScaffold(
            key: const ValueKey<String>('walka-adaptive-wide-shell'),
            controller: controller,
            pages: pages,
            leading: wideLeading,
          );
        }

        return WalkaMobileShellScaffold(
          key: const ValueKey<String>('walka-adaptive-mobile-shell'),
          controller: controller,
          pages: pages,
        );
      },
    );
  }
}
