import 'package:flutter/material.dart';

import '../../../../design_system/walka_theme.dart';

class WalkaPdpVariantOption<T> {
  const WalkaPdpVariantOption({
    required this.value,
    required this.label,
    required this.color,
  });

  final T value;
  final String label;
  final Color color;
}

class WalkaPdpVariantSelector<T> extends StatelessWidget {
  const WalkaPdpVariantSelector({
    required this.selected,
    required this.selectedLabel,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final T selected;
  final String selectedLabel;
  final List<WalkaPdpVariantOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<String>('walka-pdp-variant-selector'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'COLOR / FINISH',
          style: TextStyle(
            color: WalkaColors.muted,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          selectedLabel,
          key: const ValueKey<String>('premium-pdp-selected-variant'),
          style: const TextStyle(
            color: WalkaColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 11),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((WalkaPdpVariantOption<T> option) {
            final bool isSelected = option.value == selected;
            return Semantics(
              button: true,
              selected: isSelected,
              label: '${option.label} variant',
              child: Material(
                color: isSelected ? const Color(0xFFFFF8E7) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => onChanged(option.value),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 88, minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? WalkaColors.gold : WalkaColors.line,
                        width: isSelected ? 1.6 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: option.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: WalkaColors.navy.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          option.label,
                          style: const TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}
