import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/storefront/storefront_v2.dart';
import 'package:walka/main.dart';

void main() {
  test('WALKA 0.2 storefront exposes the application entry points', () {
    expect(const WalkaApp(), isA<WalkaApp>());
    expect(const WalkaStorefrontSplash(), isA<WalkaStorefrontSplash>());
    expect(const WalkaStorefrontShell(), isA<WalkaStorefrontShell>());
    expect(const WalkaHomeV2(), isA<WalkaHomeV2>());
    expect(const WalkaProductDetailV2(), isA<WalkaProductDetailV2>());
  });

  test('WALKA design system keeps the approved brand colors', () {
    expect(WalkaColors.navy.toARGB32(), 0xFF003366);
    expect(WalkaColors.gold.toARGB32(), 0xFFD4AF37);
    expect(buildWalkaTheme().useMaterial3, isTrue);
  });
}
