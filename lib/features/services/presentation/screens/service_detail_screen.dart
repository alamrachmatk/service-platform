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

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar dengan hero image ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    size: 18, color: AppColors.textPrimary),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => setState(() => _isFavorite = !_isFavorite),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: _isFavorite ? Colors.red : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(s.emoji,
                      style: const TextStyle(fontSize: 80)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Info utama ──
                  _ServiceHeader(service: s),
                  const SizedBox(height: 20),

                  // ── Stats ──
                  _StatsRow(service: s),
                  const SizedBox(height: 20),

                  // ── Deskripsi ──
                  _Section(
                    title: 'Tentang Layanan',
                    child: Text(s.description,
                        style: const TextStyle(fontSize: 14,
                            color: AppColors.textSecondary, height: 1.6)),
                  ),
                  const SizedBox(height: 20),

                  // ── Yang termasuk ──
                  _Section(
                    title: 'Yang Termasuk',
                    child: Column(
                      children: _includedItems(s.category)
                          .map((item) => _CheckItem(label: item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Profil mitra ──
                  _Section(
                    title: 'Tentang Mitra',
                    child: _MitraCard(service: s),
                  ),
                  const SizedBox(height: 20),

                  // ── Ulasan ──
                  _Section(
                    title: 'Ulasan Pelanggan (${s.reviewCount})',
                    child: Column(
                      children: _dummyReviews
                          .map((r) => _ReviewItem(review: r))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA ──
      bottomNavigationBar: _BottomCta(service: s),
    );
  }

  List<String> _includedItems(String category) {
    switch (category) {
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

  static const _dummyReviews = [
    (name: 'Budi S.', rating: 5.0, date: '2 hari lalu',
     comment: 'Sangat memuaskan! Mitra datang tepat waktu dan hasil kerja rapi.'),
    (name: 'Ani R.', rating: 4.5, date: '1 minggu lalu',
     comment: 'Pelayanan bagus, harga sesuai. Akan pesan lagi.'),
    (name: 'Doni P.', rating: 5.0, date: '2 minggu lalu',
     comment: 'Profesional dan bersih. Sangat rekomendasikan!'),
  ];
}

class _ServiceHeader extends StatelessWidget {
  final ServiceModel service;
  const _ServiceHeader({required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Badge kategori
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(service.category,
            style: const TextStyle(fontSize: 12, color: AppColors.primary,
                fontWeight: FontWeight.w600)),
      ),
      const SizedBox(height: 8),
      Text(service.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Row(children: [
        const Icon(Icons.location_on_outlined,
            size: 14, color: AppColors.textHint),
        Text(' ${service.distanceKm} km dari lokasi kamu',
            style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
      ]),
    ]);
  }
}

class _StatsRow extends StatelessWidget {
  final ServiceModel service;
  const _StatsRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        _Divider(),
        _StatItem(
          icon: Icons.people_outline_rounded,
          iconColor: AppColors.primary,
          value: '${service.reviewCount}',
          label: 'Ulasan',
        ),
        _Divider(),
        _StatItem(
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.success,
          value: '${service.reviewCount * 3}+',
          label: 'Order',
        ),
        _Divider(),
        Column(children: [
          Text(service.formattedPrice,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          Text('/${service.priceUnit}',
              style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        ]),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value, label;
  const _StatItem({required this.icon, required this.iconColor,
      required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Icon(icon, color: iconColor, size: 20),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      Text(label, style: const TextStyle(fontSize: 11,
          color: AppColors.textSecondary)),
    ]));
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 0.5, height: 40, color: AppColors.border,
        margin: const EdgeInsets.symmetric(horizontal: 4));
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16,
          fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      child,
    ]);
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  const _CheckItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              size: 12, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14,
            color: AppColors.textPrimary)),
      ]),
    );
  }
}

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
        Container(
          width: 52, height: 52,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(service.mitra[0],
                style: const TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(service.mitra, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Terverifikasi',
                    style: TextStyle(fontSize: 10, color: AppColors.success,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.secondary, size: 13),
              Text(' ${service.rating}  •  ${service.reviewCount} ulasan  •  ${service.distanceKm} km',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ],
        )),
        const Icon(Icons.chevron_right_rounded,
            color: AppColors.textHint, size: 20),
      ]),
    );
  }
}

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
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(review.name[0],
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700, color: AppColors.primary))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.name, style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600)),
              Text(review.date, style: const TextStyle(fontSize: 11,
                  color: AppColors.textHint)),
            ],
          )),
          Row(children: List.generate(5, (i) => Icon(
            i < review.rating.floor()
                ? Icons.star_rounded : Icons.star_outline_rounded,
            color: AppColors.secondary, size: 14,
          ))),
        ]),
        const SizedBox(height: 8),
        Text(review.comment, style: const TextStyle(fontSize: 13,
            color: AppColors.textSecondary, height: 1.5)),
      ]),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final ServiceModel service;
  const _BottomCta({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Harga mulai dari',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Row(children: [
            Text(service.formattedPrice,
                style: const TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w700, color: AppColors.primary)),
            Text('/${service.priceUnit}',
                style: const TextStyle(fontSize: 13,
                    color: AppColors.textHint)),
          ]),
        ]),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => BookingScreen(service: service))),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Pesan Sekarang',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    );
  }
}
