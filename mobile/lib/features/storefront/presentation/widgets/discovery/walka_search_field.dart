import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaSearchField extends StatelessWidget {
  const WalkaSearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
    this.placeholder = 'Search WALKA…',
    super.key,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey<String>('premium-discovery-search-field'),
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: const Icon(Icons.search_rounded, color: WalkaColors.navy),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                key: const ValueKey<String>('reference-search-clear'),
                onPressed: onClear,
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: WalkaColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: WalkaColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: WalkaColors.gold, width: 1.4),
        ),
      ),
    );
  }
}
