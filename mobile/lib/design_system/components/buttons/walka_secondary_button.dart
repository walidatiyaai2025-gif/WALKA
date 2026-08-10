import 'package:flutter/material.dart';

/// WALKA secondary call-to-action wrapper.
///
/// Styling intentionally comes from [ThemeData.outlinedButtonTheme], keeping
/// navy borders, pill geometry and touch targets centralized in the WALKA
/// theme rather than duplicating them in feature screens.
class WalkaSecondaryButton extends StatelessWidget {
  const WalkaSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isExpanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final Widget button;
    if (icon == null) {
      button = OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    } else {
      button = OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    if (!isExpanded) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
