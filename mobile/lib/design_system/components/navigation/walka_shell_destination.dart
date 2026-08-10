import 'package:flutter/material.dart';

enum WalkaShellDestination {
  home(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  search(
    label: 'Search',
    icon: Icons.search_outlined,
    selectedIcon: Icons.search_rounded,
  ),
  categories(
    label: 'Categories',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
  ),
  favorites(
    label: 'Favorites',
    icon: Icons.favorite_border_rounded,
    selectedIcon: Icons.favorite_rounded,
  ),
  account(
    label: 'Account',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  );

  const WalkaShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  int get index => WalkaShellDestination.values.indexOf(this);

  NavigationDestination toNavigationDestination() => NavigationDestination(
        icon: Icon(icon),
        selectedIcon: Icon(selectedIcon),
        label: label,
        tooltip: label,
      );

  static WalkaShellDestination fromIndex(int index) {
    assert(index >= 0 && index < values.length);
    return values[index];
  }
}
