import 'package:flutter/material.dart';

import '../../walka_theme.dart';

/// Reusable WALKA selectable/filter pill.
///
/// Selected state uses navy with white text; inactive state uses a white
/// surface with the shared line color. Semantics are explicit so selection is
/// announced consistently across filter rows.
class WalkaPillChip extends StatelessWidget {
  const WalkaPillChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && onSelected != null;
    final Color foreground = selected ? WalkaColors.white : WalkaColors.navy;

    return Semantics(
      label: label,
      button: true,
      selected: selected,
      enabled: isEnabled,
      onTap: isEnabled ? () => onSelected!(!selected) : null,
      child: ExcludeSemantics(
        child: FilterChip(
          selected: selected,
          onSelected: isEnabled ? onSelected : null,
          showCheckmark: false,
          backgroundColor: WalkaColors.white,
          selectedColor: WalkaColors.navy,
          disabledColor: WalkaColors.surface,
          side: BorderSide(
            color: selected ? WalkaColors.navy : WalkaColors.line,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WalkaRadius.pill),
          ),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          labelPadding: const EdgeInsets.symmetric(horizontal: WalkaSpacing.xs),
          label: Text(
            label,
            style: TextStyle(
              color: isEnabled ? foreground : WalkaColors.muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
