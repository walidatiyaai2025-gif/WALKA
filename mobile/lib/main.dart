import 'package:flutter/material.dart';

import 'design_system/walka_theme.dart';
import 'features/storefront/storefront_shell_v4.dart';

void main() {
  runApp(const WalkaApp());
}

class WalkaApp extends StatelessWidget {
  const WalkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WALKA',
      debugShowCheckedModeBanner: false,
      theme: buildWalkaTheme(),
      home: const WalkaStorefrontSplashV4(),
    );
  }
}
