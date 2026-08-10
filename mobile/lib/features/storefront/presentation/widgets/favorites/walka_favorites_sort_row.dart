import 'package:flutter/material.dart';

import '../../../../../design_system/walka_theme.dart';

class WalkaFavoritesSortRow extends StatelessWidget {
  const WalkaFavoritesSortRow({
    required this.editMode,
    required this.onToggleEdit,
    super.key,
  });

  final bool editMode;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Text(
            'Saved recently',
            key: ValueKey<String>('reference-favorites-sort-label'),
            style: TextStyle(
              color: WalkaColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton.icon(
          key: const ValueKey<String>('reference-favorites-edit'),
          onPressed: onToggleEdit,
          icon: Icon(
            editMode ? Icons.check_rounded : Icons.edit_outlined,
            size: 17,
          ),
          label: Text(editMode ? 'DONE' : 'EDIT'),
        ),
      ],
    );
  }
}
