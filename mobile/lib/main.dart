import 'package:flutter/material.dart';

import 'design_system/walka_theme.dart';
import 'features/favorites/favorites_state.dart';
import 'features/storefront/storefront_shell_v5.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final WalkaFavoritesController favoritesController = WalkaFavoritesController(
    SharedPreferencesWalkaFavoritesStore(),
  );
  await favoritesController.load();
  runApp(WalkaApp(favoritesController: favoritesController));
}

class WalkaApp extends StatelessWidget {
  const WalkaApp({required this.favoritesController, super.key});

  final WalkaFavoritesController favoritesController;

  @override
  Widget build(BuildContext context) {
    return WalkaFavoritesScope(
      controller: favoritesController,
      child: MaterialApp(
        title: 'WALKA',
        debugShowCheckedModeBanner: false,
        theme: buildWalkaTheme(),
        home: const WalkaStorefrontSplashV5(),
      ),
    );
  }
}
