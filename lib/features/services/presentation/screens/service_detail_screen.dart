import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../booking/presentation/screens/booking_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isFavorite = false;

  ServiceModel get s => widget.service;

  List<String> get _includedItems {
    switch (s.category) {
      case 'Laundry':
        return ['Cuci dengan detergen premium', 'Setrika rapi', 'Lipat pakaian', 'Antar jemput (radius 3 km)'];
      case 'Elektronik':
        return ['Diagnosa kerusakan gratis', 'Bersih filter & evaporator', 'Isi freon (jika perlu)', 'Garansi servis 7 hari'];
      case 'Kebersihan':
        return ['Sapu & pel seluruh ruangan', 'Bersihkan dapur & kamar mandi', 'Lap perabotan', 'Buang sampah'];
      case 'Instalasi':
        return ['Survey lokasi', 'Pasang perangkat', 'Setting & konfigurasi', 'Garansi pemasangan 1 bulan'];
      case 'Kesehatan':
        return ['Konsultasi singkat', 'Pijat relaksasi 60 menit', 'Aroma terapi', 'Alat pijat profesional'];
      default:
        return ['Layanan profesional', 'Peralatan lengkap', 'Garansi kepuasan'];
    }
  }

  static const _reviews = [
    (name: 'Budi S.',  rating: 5.0, date: '2 hari lalu',   comment: 'Sangat memuaskan! Mitra datang tepat waktu dan hasil kerja rapi.'),
    (name: 'Ani R.',   rating: 4.5, date: '1 minggu lalu', comment: 'Pelayanan bagus, harga sesuai. Akan pesan lagi.'),
    (name: 'Doni P.',  rating: 5.0, date: '2 minggu lalu', comment: 'Profesional dan bersih. Sangat rekomendasikan!'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Konten scrollable ──
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero banner ──
                _HeroBanner(
                  service: s,
                  isFavorite: _isFavorite,
                  onBack: () => Navigator.pop(context),
                  onFavorite: () => setState(() => _isFavorite = !_isFavorite),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Judul & lokasi ──
                      _ServiceHeader(service: s),
                      const SizedBox(height: 16),

                      // ── Stats (rating, ulasan, order, harga) ──
                      _StatsRow(service: s),
                      const SizedBox(height: 16),

                      // ── Deskripsi ──
                      _SectionTitle(title: 'Tentang Layanan'),
                      const SizedBox(height: 8),
                      Text(s.description,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.6)),
                      const SizedBox(height: 16),

                      // ── Yang termasuk ──
                      _SectionTitle(title: 'Yang Termasuk'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Column(
                          children: _includedItems
                              .map((item) => _CheckItem(label: item))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Profil mitra ──
                      _SectionTitle(title: 'Tentang Mitra'),
                      const SizedBox(height: 8),
                      _MitraCard(service: s),
                      const SizedBox(height: 16),

                      // ── Ulasan ──
                      _SectionTitle(title: 'Ulasan Pelanggan (${s.reviewCount})'),
                      const SizedBox(height: 8),
                      Column(
                        children: _reviews
                            .map((r) => _ReviewItem(review: r))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed bottom CTA ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomCta(service: s),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO BANNER
// ─────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final ServiceModel service;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  const _HeroBanner({
    required this.service,
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      color: AppColors.primary,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Dekorasi lingkaran
          Positioned(
            right: -30, top: -30,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20, bottom: -40,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Emoji layanan
          Center(
            child: Text(service.emoji,
                style: const TextStyle(fontSize: 80)),
          ),
          // Tombol back
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    size: 16, color: AppColors.textPrimary),
              ),
            ),
          ),
          // Tombol favorit
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: GestureDetector(
              onTap: onFavorite,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: isFavorite ? Colors.red : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary));
  }
}

// ─────────────────────────────────────────────
// SERVICE HEADER
// ─────────────────────────────────────────────
class _ServiceHeader extends StatelessWidget {
  final ServiceModel service;
  const _ServiceHeader({required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(service.category,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600)),
      ),
      const SizedBox(height: 8),
      Text(service.name,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Row(children: [
        const Icon(Icons.location_on_outlined,
            size: 14, color: AppColors.textHint),
        Text(' ${service.distanceKm} km dari lokasi kamu',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textHint)),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────
// STATS ROW
// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final ServiceModel service;
  const _StatsRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        _StatItem(
          icon: Icons.star_rounded,
          iconColor: AppColors.secondary,
          value: service.rating.toString(),
          label: 'Rating',
        ),
        _VerticalDivider(),
        _StatItem(
          icon: Icons.people_outline_rounded,
          iconColor: AppColors.primary,
          value: '${service.reviewCount}',
          label: 'Ulasan',
        ),
        _VerticalDivider(),
        _StatItem(
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.success,
          value: '${service.reviewCount * 3}+',
          label: 'Order',
        ),
        _VerticalDivider(),
        Expanded(
          child: Column(children: [
            Text(service.formattedPrice,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            Text('/${service.priceUnit}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textHint)),
          ]),
        ),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value, label;
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 0.5, height: 40,
        color: AppColors.border,
        margin: const EdgeInsets.symmetric(horizontal: 4));
  }
}

// ─────────────────────────────────────────────
// CHECK ITEM
// ─────────────────────────────────────────────
class _CheckItem extends StatelessWidget {
  final String label;
  const _CheckItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              size: 13, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// MITRA CARD
// ─────────────────────────────────────────────
class _MitraCard extends StatelessWidget {
  final ServiceModel service;
  const _MitraCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: 48, height: 48,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              service.mitra[0].toUpperCase(),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(service.mitra,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Terverifikasi',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.secondary, size: 13),
                Text(
                  ' ${service.rating}  •  '
                  '${service.reviewCount} ulasan  •  '
                  '${service.distanceKm} km',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
              ]),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded,
            color: AppColors.textHint, size: 20),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// REVIEW ITEM
// ─────────────────────────────────────────────
class _ReviewItem extends StatelessWidget {
  final ({String name, double rating, String date, String comment}) review;
  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Avatar
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(review.name[0],
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 10),
          // Nama & tanggal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(review.date,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
          // Bintang
          Row(
            children: List.generate(5, (i) => Icon(
              i < review.rating.floor()
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: AppColors.secondary,
              size: 14,
            )),
          ),
        ]),
        const SizedBox(height: 8),
        Text(review.comment,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM CTA
// ─────────────────────────────────────────────
class _BottomCta extends StatelessWidget {
  final ServiceModel service;
  const _BottomCta({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        // Harga
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Harga mulai dari',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Row(children: [
            Text(service.formattedPrice,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            Text('/${service.priceUnit}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textHint)),
          ]),
        ]),
        const SizedBox(width: 16),
        // Tombol pesan
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingScreen(service: service),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Pesan Sekarang',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    );
  }
}
