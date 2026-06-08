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
  // Menyimpan quantity tiap sub-layanan yang dipilih
  final Map<int, int> _selectedQty = {};

  ServiceModel get s => widget.service;

  // Total harga dari semua sub-layanan yang dipilih
  double get _totalPrice {
    double total = 0;
    _selectedQty.forEach((index, qty) {
      total += s.subServices[index].price * qty;
    });
    return total;
  }

  bool get _hasSelected => _selectedQty.values.any((q) => q > 0);

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000) return 'Rp ${(p / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  static const _reviews = [
    (name: 'Budi S.',  rating: 5.0, date: '2 hari lalu',
     comment: 'Sangat memuaskan! Datang tepat waktu dan hasil kerja rapi.'),
    (name: 'Ani R.',   rating: 4.5, date: '1 minggu lalu',
     comment: 'Pelayanan bagus, harga sesuai. Akan pesan lagi.'),
    (name: 'Doni P.',  rating: 5.0, date: '2 minggu lalu',
     comment: 'Profesional dan bersih. Sangat rekomendasikan!'),
  ];

  void _proceed() {
    if (!_hasSelected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih minimal 1 layanan terlebih dahulu'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // Kumpulkan sub-layanan yang dipilih
    final selectedSubs = <SubService>[];
    _selectedQty.forEach((index, qty) {
      if (qty > 0) {
        for (int i = 0; i < qty; i++) {
          selectedSubs.add(s.subServices[index]);
        }
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          service: s,
          selectedSubs: selectedSubs,
          totalPrice: _totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero banner ──
                _HeroBanner(
                  service: s,
                  isFavorite: _isFavorite,
                  onBack: () => Navigator.pop(context),
                  onFavorite: () =>
                      setState(() => _isFavorite = !_isFavorite),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Info mitra ──
                      _MitraHeader(service: s),
                      const SizedBox(height: 14),

                      // ── Deskripsi ──
                      _SectionTitle(title: 'Tentang Mitra'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.border, width: 0.5),
                        ),
                        child: Text(s.description,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.6)),
                      ),
                      const SizedBox(height: 16),

                      // ── Pilih layanan (sub-services) ──
                      _SectionTitle(title: 'Pilih Layanan yang Dibutuhkan'),
                      const SizedBox(height: 4),
                      const Text('Bisa pilih lebih dari satu',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      _SubServiceList(
                        subServices: s.subServices,
                        selectedQty: _selectedQty,
                        onAdd: (i) =>
                            setState(() => _selectedQty[i] =
                                (_selectedQty[i] ?? 0) + 1),
                        onRemove: (i) {
                          final curr = _selectedQty[i] ?? 0;
                          if (curr > 0) {
                            setState(() => _selectedQty[i] = curr - 1);
                          }
                        },
                        fmt: _fmt,
                      ),
                      const SizedBox(height: 16),

                      // ── Ulasan ──
                      _SectionTitle(
                          title: 'Ulasan Pelanggan (${s.reviewCount})'),
                      const SizedBox(height: 10),
                      ..._reviews.map((r) => _ReviewItem(review: r)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom CTA ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomCta(
              hasSelected: _hasSelected,
              totalPrice: _totalPrice,
              fmt: _fmt,
              onPressed: _proceed,
            ),
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
  final VoidCallback onBack, onFavorite;
  const _HeroBanner({required this.service, required this.isFavorite,
      required this.onBack, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned(right: -30, top: -30, child: Container(
          width: 160, height: 160,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
        )),
        Center(child: Text(service.emoji,
            style: const TextStyle(fontSize: 72))),
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
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 18,
                color: isFavorite ? Colors.red : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// MITRA HEADER
// ─────────────────────────────────────────────
class _MitraHeader extends StatelessWidget {
  final ServiceModel service;
  const _MitraHeader({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Badge kategori
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(service.category,
                style: const TextStyle(fontSize: 11,
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          // Jarak
          const Icon(Icons.location_on_outlined,
              size: 13, color: AppColors.textHint),
          Text(' ${service.distanceKm} km',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
        ]),
        const SizedBox(height: 8),
        // Nama mitra
        Text(service.mitra,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        // Rating + ulasan
        Row(children: [
          const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
          Text(' ${service.rating}',
              style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(' (${service.reviewCount} ulasan)',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 8),
        // Verified badge
        if (service.isVerified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.verified_rounded, color: AppColors.primary, size: 14),
              SizedBox(width: 5),
              Text('Mitra Terverifikasi JasaKu',
                  style: TextStyle(fontSize: 12, color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
      ]),
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
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary));
}

// ─────────────────────────────────────────────
// SUB SERVICE LIST — pilih layanan + qty
// ─────────────────────────────────────────────
class _SubServiceList extends StatelessWidget {
  final List<SubService> subServices;
  final Map<int, int> selectedQty;
  final void Function(int) onAdd;
  final void Function(int) onRemove;
  final String Function(double) fmt;

  const _SubServiceList({
    required this.subServices,
    required this.selectedQty,
    required this.onAdd,
    required this.onRemove,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: List.generate(subServices.length, (i) {
          final sub = subServices[i];
          final qty = selectedQty[i] ?? 0;
          final isLast = i == subServices.length - 1;

          return Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: qty > 0
                  ? AppColors.primary.withOpacity(0.03)
                  : Colors.transparent,
              border: !isLast
                  ? const Border(bottom: BorderSide(
                      color: AppColors.border, width: 0.5))
                  : null,
              borderRadius: isLast
                  ? const BorderRadius.vertical(bottom: Radius.circular(14))
                  : i == 0
                  ? const BorderRadius.vertical(top: Radius.circular(14))
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info layanan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sub.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text(sub.description,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary,
                              height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text(
                        sub.price == 0 ? 'Gratis' : fmt(sub.price),
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: sub.price == 0
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Kontrol qty
                qty == 0
                    ? GestureDetector(
                        onTap: () => onAdd(i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: const Text('Tambah',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      )
                    : Row(children: [
                        _QtyBtn(
                          icon: Icons.remove_rounded,
                          onTap: () => onRemove(i),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('$qty',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ),
                        _QtyBtn(
                          icon: Icons.add_rounded,
                          onTap: () => onAdd(i),
                          isFilled: true,
                        ),
                      ]),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isFilled;
  const _QtyBtn({required this.icon, required this.onTap,
      this.isFilled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: isFilled
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 16,
            color: isFilled ? Colors.white : AppColors.primary),
      ),
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
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(review.name[0],
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700, color: AppColors.primary))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.name, style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
              Text(review.date, style: const TextStyle(
                  fontSize: 11, color: AppColors.textHint)),
            ],
          )),
          Row(children: List.generate(5, (i) => Icon(
            i < review.rating.floor()
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            color: AppColors.secondary, size: 14,
          ))),
        ]),
        const SizedBox(height: 8),
        Text(review.comment, style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM CTA
// ─────────────────────────────────────────────
class _BottomCta extends StatelessWidget {
  final bool hasSelected;
  final double totalPrice;
  final String Function(double) fmt;
  final VoidCallback onPressed;
  const _BottomCta({required this.hasSelected, required this.totalPrice,
      required this.fmt, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Estimasi Harga',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(
            hasSelected ? fmt(totalPrice) : 'Rp0',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: hasSelected ? AppColors.primary : AppColors.textHint,
            ),
          ),
          if (!hasSelected)
            const Text('Pilih layanan dahulu',
                style: TextStyle(fontSize: 10, color: AppColors.textHint)),
        ]),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasSelected
                  ? AppColors.primary
                  : AppColors.border,
              foregroundColor: hasSelected ? Colors.white : AppColors.textHint,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Selanjutnya',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    );
  }
}
