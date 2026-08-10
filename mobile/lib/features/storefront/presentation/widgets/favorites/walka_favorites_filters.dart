import 'package:flutter/material.dart';

import '../../../../../design_system/components/buttons/walka_pill_chip.dart';

enum WalkaFavoritesFilter { all, white, gray }

class WalkaFavoritesFilters extends StatelessWidget {
  const WalkaFavoritesFilters({
    required this.selected,
    required this.totalCount,
    required this.whiteCount,
    required this.grayCount,
    required this.onChanged,
    super.key,
  });

  final WalkaFavoritesFilter selected;
  final int totalCount;
  final int whiteCount;
  final int grayCount;
  final ValueChanged<WalkaFavoritesFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        WalkaPillChip(
          key: const ValueKey<String>('reference-favorites-filter-all'),
          label: 'All $totalCount',
          selected: selected == WalkaFavoritesFilter.all,
          onSelected: (_) => onChanged(WalkaFavoritesFilter.all),
        ),
        WalkaPillChip(
          key: const ValueKey<String>('reference-favorites-filter-white'),
          label: 'White $whiteCount',
          selected: selected == WalkaFavoritesFilter.white,
          onSelected: (_) => onChanged(WalkaFavoritesFilter.white),
        ),
        WalkaPillChip(
          key: const ValueKey<String>('reference-favorites-filter-gray'),
          label: 'Gray $grayCount',
          selected: selected == WalkaFavoritesFilter.gray,
          onSelected: (_) => onChanged(WalkaFavoritesFilter.gray),
        ),
      ],
    );
  }
}
