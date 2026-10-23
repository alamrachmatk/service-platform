import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

/// Ubah ke true saat testing agar onboarding selalu tampil di setiap
/// app dibuka. Kembalikan ke false sebelum rilis.
const bool kAlwaysShowOnboarding = false;

const _kOnboardingSeenKey = 'onboarding_seen';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Cek apakah onboarding sudah pernah ditampilkan
  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool(_kOnboardingSeenKey) ?? false;
  final showOnboarding = kAlwaysShowOnboarding || !seen;

  // Tandai sudah dilihat, jadi pembukaan app berikutnya langsung ke login
  if (!seen) {
    await prefs.setBool(_kOnboardingSeenKey, true);
  }

  runApp(JasaKuApp(showOnboarding: showOnboarding));
}

class JasaKuApp extends StatelessWidget {
  final bool showOnboarding;
  const JasaKuApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JasaKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: showOnboarding ? const OnboardingScreen() : const AuthScreen(),
    );
  }
}
