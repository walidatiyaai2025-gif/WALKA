import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/storefront/storefront_catalog_v120.dart';

class WalkaSearchFilters extends StatelessWidget {
  const WalkaSearchFilters({
    required this.selectedFamily,
    required this.onChanged,
    this.allLabel = 'All',
    this.drawerLabel = 'Drawer',
    this.lunchLabel = 'Lunch',
    super.key,
  });

  final WalkaCatalogFamily? selectedFamily;
  final ValueChanged<WalkaCatalogFamily?> onChanged;
  final String allLabel;
  final String drawerLabel;
  final String lunchLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _FamilyChip(
          key: const ValueKey<String>('premium-family-All'),
          label: allLabel,
          selected: selectedFamily == null,
          onSelected: () => onChanged(null),
        ),
        _FamilyChip(
          key: const ValueKey<String>('premium-family-Drawer'),
          label: drawerLabel,
          selected: selectedFamily == WalkaCatalogFamily.drawer,
          onSelected: () => onChanged(WalkaCatalogFamily.drawer),
        ),
        _FamilyChip(
          key: const ValueKey<String>('premium-family-Lunch'),
          label: lunchLabel,
          selected: selectedFamily == WalkaCatalogFamily.lunch,
          onSelected: () => onChanged(WalkaCatalogFamily.lunch),
        ),
      ],
    );
  }
}

class _FamilyChip extends StatelessWidget {
  const _FamilyChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: WalkaColors.navy,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? WalkaColors.navy : WalkaColors.line),
      labelStyle: TextStyle(
        color: selected ? Colors.white : WalkaColors.navy,
        fontWeight: FontWeight.w800,
        fontSize: 11,
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}
