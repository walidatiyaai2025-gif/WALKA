import 'package:flutter/material.dart';

import 'walka_adaptive.dart';
import 'walka_motion.dart';
import 'walka_theme.dart';

/// Shared chrome metrics for the premium WALKA mobile shell.
abstract final class WalkaShellMetrics {
  static const double navigationHeight = 72;
  static const double headerTop = 16;
  static const double headerBottom = 8;
  static const double sectionGap = 32;
  static const double compactSectionGap = 24;
  static const double minimumTouchTarget = 48;

  static double horizontalGutter(BuildContext context) {
    return WalkaAdaptiveMetrics.horizontalPadding(context);
  }

  static double verticalSectionGap(BuildContext context) {
    return MediaQuery.sizeOf(context).width < WalkaAdaptiveMetrics.compactWidth
        ? compactSectionGap
        : sectionGap;
  }
}

class WalkaWordmark extends StatelessWidget {
  const WalkaWordmark({
    super.key,
    this.onDark = false,
    this.compact = false,
    this.showDescriptor = true,
  });

  final bool onDark;
  final bool compact;
  final bool showDescriptor;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = onDark ? WalkaColors.white : WalkaColors.navy;
    final Color descriptorColor = onDark
        ? const Color(0xFFC9D4DF)
        : WalkaColors.muted;

    return Semantics(
      header: true,
      label: 'WALKA premium home organization',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'WALKA',
              style: TextStyle(
                color: titleColor,
                fontSize: compact ? 22 : 42,
                fontWeight: FontWeight.w900,
                letterSpacing: compact ? 5.2 : 8.2,
              ),
            ),
            if (showDescriptor) ...<Widget>[
              SizedBox(height: compact ? 3 : 14),
              Text(
                'PREMIUM HOME ORGANIZATION',
                style: TextStyle(
                  color: descriptorColor,
                  fontSize: compact ? 8 : 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: compact ? 1.35 : 2.1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WalkaShellIconButton extends StatelessWidget {
  const WalkaShellIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.white,
      shape: const CircleBorder(
        side: BorderSide(color: WalkaColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 1,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints.tightFor(
          width: WalkaShellMetrics.minimumTouchTarget,
          height: WalkaShellMetrics.minimumTouchTarget,
        ),
        icon: Icon(icon, color: WalkaColors.navy, size: 21),
      ),
    );
  }
}

class WalkaPremiumNavigationBar extends StatelessWidget {
  const WalkaPremiumNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<NavigationDestination> _destinations =
      <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
      tooltip: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search_rounded),
      label: 'Search',
      tooltip: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: 'Categories',
      tooltip: 'Categories',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_border_rounded),
      selectedIcon: Icon(Icons.favorite_rounded),
      label: 'Favorites',
      tooltip: 'Favorites',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Account',
      tooltip: 'Account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
            WalkaMotion.standard,
          ),
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: _destinations,
        ),
      ),
    );
  }
}
