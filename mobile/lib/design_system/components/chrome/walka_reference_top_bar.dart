import 'package:flutter/material.dart';

import '../../walka_theme.dart';

/// Shared WALKA top-bar contract for owner-visible reference screens.
///
/// The leading and trailing slots keep a deterministic 48x48 extent so the
/// wordmark remains optically centered whether a slot is interactive,
/// decorative, or empty.
class WalkaReferenceTopBar extends StatelessWidget {
  const WalkaReferenceTopBar({
    this.headerKey,
    this.leadingIcon,
    this.leadingColor = WalkaColors.navy,
    this.leadingTooltip,
    this.leadingKey,
    this.onLeading,
    this.trailingIcon,
    this.trailingColor = WalkaColors.navy,
    this.trailingTooltip,
    this.trailingKey,
    this.onTrailing,
    super.key,
  });

  static const double horizontalPadding = 12;
  static const double verticalPadding = 10;
  static const double slotExtent = 48;
  static const double extent = slotExtent + (verticalPadding * 2);
  static const double dividerWidth = 0.7;

  static const TextStyle wordmarkStyle = TextStyle(
    color: WalkaColors.navy,
    fontFamily: 'serif',
    fontSize: 27,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.8,
  );

  final Key? headerKey;
  final IconData? leadingIcon;
  final Color leadingColor;
  final String? leadingTooltip;
  final Key? leadingKey;
  final VoidCallback? onLeading;
  final IconData? trailingIcon;
  final Color trailingColor;
  final String? trailingTooltip;
  final Key? trailingKey;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: headerKey,
      height: extent,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: WalkaColors.white,
          border: Border(
            bottom: BorderSide(
              color: WalkaColors.line,
              width: dividerWidth,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            children: <Widget>[
              _WalkaReferenceTopBarSlot(
                icon: leadingIcon,
                color: leadingColor,
                tooltip: leadingTooltip,
                actionKey: leadingKey,
                onPressed: onLeading,
              ),
              const Expanded(
                child: Center(
                  child: Text('WALKA', style: wordmarkStyle),
                ),
              ),
              _WalkaReferenceTopBarSlot(
                icon: trailingIcon,
                color: trailingColor,
                tooltip: trailingTooltip,
                actionKey: trailingKey,
                onPressed: onTrailing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkaReferenceTopBarSlot extends StatelessWidget {
  const _WalkaReferenceTopBarSlot({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.actionKey,
    required this.onPressed,
  });

  final IconData? icon;
  final Color color;
  final String? tooltip;
  final Key? actionKey;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return const SizedBox.square(dimension: WalkaReferenceTopBar.slotExtent);
    }

    if (onPressed == null) {
      return SizedBox.square(
        dimension: WalkaReferenceTopBar.slotExtent,
        child: Icon(icon, color: color),
      );
    }

    return SizedBox.square(
      dimension: WalkaReferenceTopBar.slotExtent,
      child: IconButton(
        key: actionKey,
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, color: color),
      ),
    );
  }
}
