import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/screens/auth_screen.dart';

class _OnboardPage {
  final String emoji, title, subtitle, description;
  final Color color;
  const _OnboardPage({
    required this.emoji, required this.title,
    required this.subtitle, required this.description,
    required this.color,
  });
}

const _pages = [
  _OnboardPage(
    emoji: '🏠',
    title: 'Selamat Datang\ndi JasaKu',
    subtitle: 'Platform jasa terpercaya',
    description: 'Temukan ribuan mitra profesional terverifikasi untuk berbagai kebutuhan layanan rumahmu.',
    color: AppColors.primary,
  ),
  _OnboardPage(
    emoji: '🔍',
    title: 'Cari & Pesan\nMudah',
    subtitle: 'Dalam hitungan detik',
    description: 'Cari layanan berdasarkan kategori, lokasi, atau nama. Pesan same-day atau jadwalkan kapan saja.',
    color: Color(0xFF1E88E5),
  ),
  _OnboardPage(
    emoji: '📍',
    title: 'Lacak Mitra\nReal-time',
    subtitle: 'Pantau di mana saja',
    description: 'Lihat posisi mitra secara langsung di peta. Tahu kapan tepatnya mitra tiba di lokasimu.',
    color: Color(0xFF8E24AA),
  ),
  _OnboardPage(
    emoji: '🛡️',
    title: 'Dijamin\nAman & Puas',
    subtitle: 'Jaminan kepuasan 100%',
    description: 'Semua mitra terverifikasi. Tidak puas? Dapatkan layanan ulang gratis atau refund penuh.',
    color: Color(0xFF43A047),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _ctrl = PageController();
  int _current = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _animCtrl.reset();
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
      _animCtrl.forward();
    } else {
      _goToAuth();
    }
  }

  void _goToAuth() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_current];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // Skip button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 16),
              child: _current < _pages.length - 1
                  ? TextButton(
                      onPressed: _goToAuth,
                      child: const Text('Lewati',
                          style: TextStyle(fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500)),
                    )
                  : const SizedBox(height: 40),
            ),
          ),

          // PageView area
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) {
                _animCtrl.reset();
                setState(() => _current = i);
                _animCtrl.forward();
              },
              itemCount: _pages.length,
              itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
            ),
          ),

          // Bottom section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(children: [

              // Teks animasi
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(children: [
                    Text(page.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, height: 1.2)),
                    const SizedBox(height: 10),
                    Text(page.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14,
                            color: AppColors.textSecondary, height: 1.6)),
                  ]),
                ),
              ),
              const SizedBox(height: 28),

              // Dot indicators
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? page.color : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Tombol lanjut/mulai
              SizedBox(
                width: double.infinity, height: 54,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: page.color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _current == _pages.length - 1
                              ? 'Mulai Sekarang'
                              : 'Lanjut',
                          style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _current == _pages.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.chevron_right_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Ilustrasi
      Container(
        width: 200, height: 200,
        decoration: BoxDecoration(
          color: page.color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(page.emoji,
            style: const TextStyle(fontSize: 96))),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: page.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(page.subtitle, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: page.color)),
      ),
    ]);
  }
}
