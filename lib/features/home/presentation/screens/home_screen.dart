import 'package:flutter/material.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/service_model.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_list.dart';
import '../widgets/service_card.dart';

/// HomeTab = konten tab "Beranda" di dalam MainScreen
class HomeTab extends StatelessWidget {
  final UserModel user;
  final void Function(int) onNavTap;

  const HomeTab({super.key, required this.user, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _TopBar(user: user)),

            // Search bar → tap pindah ke tab Cari
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => onNavTap(1),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(children: [
                      Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                      SizedBox(width: 10),
                      Text('Cari layanan atau kategori...',
                          style: TextStyle(fontSize: 14, color: AppColors.textHint)),
                    ]),
                  ),
                ),
              ),
            ),

            // Promo banner
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: PromoBanner(),
              ),
            ),

            // Label kategori
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text('Kategori Jasa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
            ),

            // Kategori horizontal list
            const SliverToBoxAdapter(
              child: SizedBox(height: 88, child: CategoryList()),
            ),

            // Label layanan populer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Populer di Sekitarmu',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    GestureDetector(
                      onTap: () => onNavTap(1),
                      child: const Text('Lihat semua',
                          style: TextStyle(fontSize: 13, color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),

            // List layanan atau empty state
            DummyServices.all.isEmpty
                ? const SliverFillRemaining(
                    child: _EmptyHomeState())
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            ServiceCard(service: DummyServices.all[i]),
                        childCount: DummyServices.all.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final UserModel user;
  const _TopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Halo, ${user.firstName} 👋',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const Text('Mau pesan jasa apa?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const NotificationsScreen())),
          child: Stack(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: AppColors.textPrimary, size: 22),
            ),
            Positioned(
              right: 9, top: 9,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.error, shape: BoxShape.circle),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Empty state saat tidak ada layanan ──
class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔍', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Belum Ada Layanan\ndi Area Kamu',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, height: 1.3)),
          const SizedBox(height: 10),
          const Text(
            'Kami belum menjangkau lokasimu saat ini.\n'
            'Coba perluas area pencarian atau cek kembali nanti.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14,
                color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 28),

          // Suggestions
          Row(children: [
            _SuggestionChip(label: '📍 Ubah Lokasi', onTap: () {}),
            const SizedBox(width: 10),
            _SuggestionChip(label: '🔔 Beri Tahu Saya', onTap: () {}),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(child: Text(
                'JasaKu terus berkembang ke lebih banyak kota. '
                'Daftarkan emailmu untuk notifikasi saat JasaKu '
                'hadir di kotamu!',
                style: TextStyle(fontSize: 12,
                    color: AppColors.primary, height: 1.5),
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(child: Text(label, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary))),
      ),
    ),
  );
}
