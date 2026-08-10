import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaFavoritesFilters extends StatelessWidget {
  const WalkaFavoritesFilters({
    required this.count,
    required this.drawerSelected,
    required this.onAll,
    required this.onDrawer,
    super.key,
  });

  final int count;
  final bool drawerSelected;
  final VoidCallback onAll;
  final VoidCallback onDrawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-favorites-filters'),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: WalkaColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            WalkaFavoriteFilter(
              icon: Icons.favorite_border_rounded,
              label: 'All Favorites',
              countLabel: '$count',
              selected: !drawerSelected,
              onTap: onAll,
            ),
            const SizedBox(width: 4),
            WalkaFavoriteFilter(
              icon: Icons.inventory_2_outlined,
              label: 'Drawer Organizers',
              countLabel: '$count',
              selected: drawerSelected,
              onTap: onDrawer,
            ),
            const SizedBox(width: 4),
            const WalkaFavoriteFilter(
              icon: Icons.lunch_dining_outlined,
              label: 'Lunch Boxes',
              countLabel: '—',
              selected: false,
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}

class WalkaFavoriteFilter extends StatelessWidget {
  const WalkaFavoriteFilter({
    required this.icon,
    required this.label,
    required this.countLabel,
    required this.selected,
    this.enabled = true,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String countLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = enabled ? WalkaColors.navy : WalkaColors.muted;
    return Material(
      color: selected ? const Color(0xFFFFF8EA) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: selected
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: WalkaColors.gold, width: 2),
                  ),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: enabled
                      ? WalkaColors.gold.withValues(alpha: 0.16)
                      : const Color(0xFFF1F2F3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  countLabel,
                  style: TextStyle(
                    color: enabled ? WalkaColors.navy : WalkaColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
