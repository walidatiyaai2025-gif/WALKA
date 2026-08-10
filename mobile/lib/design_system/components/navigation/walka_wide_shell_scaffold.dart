import 'package:flutter/material.dart';

import '../../walka_theme.dart';
import '../layout/walka_content_width.dart';
import 'walka_shell_controller.dart';
import 'walka_shell_destination.dart';

/// Wide shell that deliberately avoids the mobile 560px frame.
///
/// It is ready for the desktop reference pages while remaining opt-in until
/// adaptive routing selects it in the dedicated platform tasks.
class WalkaWideShellScaffold extends StatelessWidget {
  const WalkaWideShellScaffold({
    required this.controller,
    required this.pages,
    super.key,
    this.leading,
  }) : assert(pages.length == WalkaShellDestination.values.length);

  final WalkaShellController controller;
  final List<Widget> pages;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          backgroundColor: WalkaColors.ivory,
          body: Row(
            children: <Widget>[
              Material(
                color: WalkaColors.white,
                child: SafeArea(
                  right: false,
                  child: NavigationRail(
                    extended: true,
                    minExtendedWidth: 220,
                    selectedIndex: controller.selectedIndex,
                    onDestinationSelected: (int index) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      controller.selectIndex(index);
                    },
                    leading: leading,
                    destinations: WalkaShellDestination.values
                        .map(
                          (WalkaShellDestination item) =>
                              NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.selectedIcon),
                            label: Text(item.label),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
              const VerticalDivider(width: 1, color: WalkaColors.line),
              Expanded(
                child: ColoredBox(
                  color: WalkaColors.ivory,
                  child: WalkaContentWidth(
                    child: IndexedStack(
                      index: controller.selectedIndex,
                      children: pages,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
