import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_v3.dart';
import 'package:walka/features/lifestyle/lifestyle_v4.dart';
import 'package:walka/features/storefront/storefront_shell_v4.dart';
import 'package:walka/features/storefront/storefront_v2.dart';
import 'package:walka/main.dart';

void main() {
  test('WALKA 0.4 storefront exposes the complete Phase 1 destinations', () {
    expect(const WalkaApp(), isA<WalkaApp>());
    expect(const WalkaStorefrontSplashV4(), isA<WalkaStorefrontSplashV4>());
    expect(const WalkaStorefrontShellV4(), isA<WalkaStorefrontShellV4>());
    expect(const WalkaHomeV2(), isA<WalkaHomeV2>());
    expect(const WalkaCategoriesV3(), isA<WalkaCategoriesV3>());
    expect(const WalkaCollectionScreenV3(), isA<WalkaCollectionScreenV3>());
    expect(const WalkaFavoritesV4(), isA<WalkaFavoritesV4>());
    expect(const WalkaAccountV4(), isA<WalkaAccountV4>());
    expect(const WalkaAboutV4(), isA<WalkaAboutV4>());
    expect(const WalkaProductDetailV2(), isA<WalkaProductDetailV2>());
  });

  test('WALKA design system keeps the approved brand colors', () {
    expect(WalkaColors.navy.toARGB32(), 0xFF003366);
    expect(WalkaColors.gold.toARGB32(), 0xFFD4AF37);
    expect(buildWalkaTheme().useMaterial3, isTrue);
  });
}
