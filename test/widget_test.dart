// Smoke test untuk alur awal aplikasi JasaKu (Pelanggan):
// - pengguna baru  -> OnboardingScreen
// - pengguna lama  -> AuthScreen (login)
//
// Jalankan dengan:  flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:platformservice/features/auth/presentation/screens/auth_screen.dart';
import 'package:platformservice/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:platformservice/main.dart';

/// Ukuran layar ponsel (360x800 logical px). Layar default test (800x600)
/// terlalu pendek untuk layout onboarding dan memicu overflow palsu.
void _usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Pengguna baru melihat onboarding dan bisa melanjutkan',
      (WidgetTester tester) async {
    _usePhoneScreen(tester);

    await tester.pumpWidget(const JasaKuApp(showOnboarding: true));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);

    // Maju ke halaman terakhir (4 halaman = 3x "Lanjut")
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
    }

    // Di halaman terakhir: tombol berubah dan "Lewati" hilang
    expect(find.text('Mulai Sekarang'), findsOneWidget);
    expect(find.text('Lewati'), findsNothing);
  });

  testWidgets('Pengguna lama langsung masuk ke halaman login',
      (WidgetTester tester) async {
    _usePhoneScreen(tester);

    await tester.pumpWidget(const JasaKuApp(showOnboarding: false));
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(AuthScreen), findsOneWidget);
  });
}
