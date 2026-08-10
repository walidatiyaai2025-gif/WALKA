import 'package:flutter/material.dart';

import '../../walka_motion.dart';
import '../../walka_theme.dart';
import '../chrome/walka_shell_metrics.dart';
import 'walka_shell_destination.dart';

/// Dedicated WALKA bottom navigation chrome.
class WalkaPremiumNavigationBar extends StatelessWidget {
  const WalkaPremiumNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final List<NavigationDestination> destinations = WalkaShellDestination.values
        .map((WalkaShellDestination item) => item.toNavigationDestination())
        .toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: WalkaColors.white,
        border: const Border(
          top: BorderSide(color: WalkaColors.line, width: 0.7),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: WalkaColors.navyDark.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          height: WalkaShellMetrics.navigationHeight,
          animationDuration: WalkaMotion.duration(
            context,
            WalkaMotion.navigationSelection,
          ),
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations,
        ),
      ),
    );
  }
}
