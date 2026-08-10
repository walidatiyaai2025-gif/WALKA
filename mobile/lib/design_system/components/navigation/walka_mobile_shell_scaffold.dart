import 'package:flutter/material.dart';

import '../../walka_adaptive.dart';
import 'walka_premium_navigation_bar.dart';
import 'walka_shell_controller.dart';
import 'walka_shell_destination.dart';

/// Mobile shell composition owning page persistence + bottom navigation only.
class WalkaMobileShellScaffold extends StatelessWidget {
  const WalkaMobileShellScaffold({
    required this.controller,
    required this.pages,
    super.key,
  }) : assert(pages.length == WalkaShellDestination.values.length);

  final WalkaShellController controller;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          body: WalkaAdaptiveFrame(
            child: IndexedStack(
              index: controller.selectedIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: WalkaAdaptiveNavigationFrame(
            child: WalkaPremiumNavigationBar(
              selectedIndex: controller.selectedIndex,
              onDestinationSelected: (int index) {
                FocusManager.instance.primaryFocus?.unfocus();
                controller.selectIndex(index);
              },
            ),
          ),
        );
      },
    );
  }
}
