import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../booking/presentation/screens/booking_screen.dart';
import '../../../chat/presentation/screens/pre_order_chat_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isFavorite = false;
  // key: 'subIndex-itemIndex', value: qty
  final Map<String, int> _cart = {};

  ServiceModel get s => widget.service;

  double get _totalPrice {
    double total = 0;
    _cart.forEach((key, qty) {
      final parts = key.split('-');
      final si = int.parse(parts[0]);
      final ii = int.parse(parts[1]);
      total += s.subServices[si].items[ii].price * qty;
    });
    return total;
  }

  bool get _hasSelected => _cart.values.any((q) => q > 0);

  int _getQty(int si, int ii) => _cart['$si-$ii'] ?? 0;

  void _setQty(int si, int ii, int qty) {
    setState(() {
      if (qty <= 0) {
        _cart.remove('$si-$ii');
      } else {
        _cart['$si-$ii'] = qty;
      }
    });
  }

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000)    return 'Rp ${(p / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  // Jumlah item dipilih per sub-service
  int _subTotal(int si) {
    int count = 0;
    for (int ii = 0; ii < s.subServices[si].items.length; ii++) {
      count += _cart['$si-$ii'] ?? 0;
    }
    return count;
  }

  // Buka bottom sheet untuk sub-service tertentu
  void _openSubSheet(int si) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => _SubServiceSheet(
          subService: s.subServices[si],
          subIndex: si,
          getQty: _getQty,
          onQtyChanged: (si, ii, qty) {
            _setQty(si, ii, qty);
            setSheetState(() {});
          },
          fmt: _fmt,
        ),
      ),
    );
  }

  void _proceed() {
    if (!_hasSelected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih minimal 1 layanan terlebih dahulu'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // Kumpulkan selected items
    final selectedItems = <SelectedItem>[];
    _cart.forEach((key, qty) {
      if (qty > 0) {
        final parts = key.split('-');
        final si = int.parse(parts[0]);
        final ii = int.parse(parts[1]);
        selectedItems.add(SelectedItem(
          subService: s.subServices[si],
          item: s.subServices[si].items[ii],
          qty: qty,
        ));
      }
    });

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => BookingScreen(
        service: s,
        selectedItems: selectedItems,
        totalPrice: _totalPrice,
      ),
    ));
  }

  static const _reviews = [
    (name: 'Budi S.',  rating: 5.0, date: '2 hari lalu',   comment: 'Sangat memuaskan! Datang tepat waktu dan hasil kerja rapi.'),
    (name: 'Ani R.',   rating: 4.5, date: '1 minggu lalu', comment: 'Pelayanan bagus, harga sesuai. Akan pesan lagi.'),
    (name: 'Doni P.',  rating: 5.0, date: '2 minggu lalu', comment: 'Profesional dan bersih. Sangat rekomendasikan!'),
  ];

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
                _HeroBanner(service: s, isFavorite: _isFavorite,
                    onBack: () => Navigator.pop(context),
                    onFavorite: () => setState(() => _isFavorite = !_isFavorite)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _MitraHeader(service: s),
                    const SizedBox(height: 14),

                    _SectionTitle(title: 'Tentang Mitra'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 0.5)),
                      child: Text(s.description, style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
                    ),
                    const SizedBox(height: 16),

                    const _SectionTitle(title: 'Layanan yang Anda Butuhkan'),
                    const SizedBox(height: 4),
                    const Text('Pilih layanan dan tambah item',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 10),

                    // Sub-service list
                    Container(
                      decoration: BoxDecoration(color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 0.5)),
                      child: Column(
                        children: List.generate(s.subServices.length, (si) {
                          final sub = s.subServices[si];
                          final selectedCount = _subTotal(si);
                          final isLast = si == s.subServices.length - 1;
                          return _SubServiceRow(
                            subService: sub,
                            selectedCount: selectedCount,
                            isLast: isLast,
                            onTambah: () => _openSubSheet(si),
                            fmt: _fmt,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const _SectionTitle(title: 'Ulasan Pelanggan'),
                    const SizedBox(height: 10),
                    ..._reviews.map((r) => _ReviewItem(review: r)),
                  ]),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomCta(
              hasSelected: _hasSelected,
              totalPrice: _totalPrice,
              fmt: _fmt,
              onPressed: _proceed,
              service: s,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUB SERVICE ROW (di list utama)
// ─────────────────────────────────────────────
class _SubServiceRow extends StatelessWidget {
  final SubService subService;
  final int selectedCount;
  final bool isLast;
  final VoidCallback onTambah;
  final String Function(double) fmt;

  const _SubServiceRow({required this.subService, required this.selectedCount,
      required this.isLast, required this.onTambah, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        onTap: onTambah,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(subService.name, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subService.description, style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
            ])),
            const SizedBox(width: 12),
            selectedCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('$selectedCount dipilih',
                          style: const TextStyle(fontSize: 12, color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ]),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: const Text('Tambah',
                        style: TextStyle(fontSize: 13, color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
          ]),
        ),
      ),
      // Preview item yang sudah dipilih
      if (selectedCount > 0)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Column(children: [
            // Tampilkan summary item terpilih
            const Divider(height: 8),
            Text('${subService.items.length} pilihan tersedia — ketuk untuk ubah',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ]),
        ),
      if (!isLast)
        const Divider(height: 0.5, indent: 14, endIndent: 14),
    ]);
  }
}

// ─────────────────────────────────────────────
// BOTTOM SHEET SUB-SERVICE ITEMS
// ─────────────────────────────────────────────
class _SubServiceSheet extends StatelessWidget {
  final SubService subService;
  final int subIndex;
  final int Function(int, int) getQty;
  final void Function(int, int, int) onQtyChanged;
  final String Function(double) fmt;

  const _SubServiceSheet({
    required this.subService, required this.subIndex,
    required this.getQty, required this.onQtyChanged, required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(children: [
            Expanded(child: Text(subService.name, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
            ),
          ]),
        ),
        const Divider(height: 0),

        // Daftar item
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: subService.items.length,
            separatorBuilder: (_, __) => const Divider(height: 0, indent: 20, endIndent: 20),
            itemBuilder: (_, ii) {
              final item = subService.items[ii];
              final qty = getQty(subIndex, ii);
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.name, style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(item.description, style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                    const SizedBox(height: 5),
                    Row(children: [
                      if (item.originalPrice != null) ...[
                        Text(item.formattedOriginalPrice!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 6),
                      ],
                      Text(item.formattedPrice, style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ]),
                  ])),
                  const SizedBox(width: 16),
                  // Counter qty
                  qty == 0
                      ? GestureDetector(
                          onTap: () => onQtyChanged(subIndex, ii, 1),
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                            ),
                            child: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                          ),
                        )
                      : Row(children: [
                          _SheetQtyBtn(
                            icon: Icons.remove_rounded,
                            onTap: () => onQtyChanged(subIndex, ii, qty - 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('$qty', style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                          _SheetQtyBtn(
                            icon: Icons.add_rounded,
                            onTap: () => onQtyChanged(subIndex, ii, qty + 1),
                            filled: true,
                          ),
                        ]),
                ]),
              );
            },
          ),
        ),

        const Divider(height: 0),
        // Tombol Tambah / selesai
        Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
          child: SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Konfirmasi Pilihan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SheetQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _SheetQtyBtn({required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary),
        ),
        child: Icon(icon, size: 16, color: filled ? Colors.white : AppColors.primary),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
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
      height: 200, width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Stack(children: [
        Positioned(right: -30, top: -30, child: Container(width: 160, height: 160,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle))),
        Center(child: Text(service.emoji, style: const TextStyle(fontSize: 72))),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8, left: 12,
          child: GestureDetector(onTap: onBack,
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColors.textPrimary))),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8, right: 12,
          child: GestureDetector(onTap: onFavorite,
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18, color: isFavorite ? Colors.red : AppColors.textPrimary))),
        ),
      ]),
    );
  }
}

class _MitraHeader extends StatelessWidget {
  final ServiceModel service;
  const _MitraHeader({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(service.category, style: const TextStyle(fontSize: 11,
                color: AppColors.primary, fontWeight: FontWeight.w600))),
          const Spacer(),
          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textHint),
          Text(' ${service.distanceKm} km', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
        ]),
        const SizedBox(height: 8),
        Text(service.mitra, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
          Text(' ${service.rating}', style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(' (${service.reviewCount} ulasan)', style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 8),
        if (service.isVerified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2))),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.verified_rounded, color: AppColors.primary, size: 14),
              SizedBox(width: 5),
              Text('Mitra Terverifikasi JasaKu',
                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ]),
          ),
        const SizedBox(height: 6),
        // Badge jaminan kepuasan
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.2))),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shield_outlined, color: AppColors.success, size: 14),
            SizedBox(width: 5),
            Text('Bergaransi — Layanan ulang gratis atau refund',
                style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
}

class _ReviewItem extends StatelessWidget {
  final ({String name, double rating, String date, String comment}) review;
  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 34, height: 34,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Center(child: Text(review.name[0],
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(review.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(review.date, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ])),
          Row(children: List.generate(5, (i) => Icon(
            i < review.rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
            color: AppColors.secondary, size: 14))),
        ]),
        const SizedBox(height: 8),
        Text(review.comment, style: const TextStyle(fontSize: 13,
            color: AppColors.textSecondary, height: 1.5)),
      ]),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final bool hasSelected;
  final double totalPrice;
  final String Function(double) fmt;
  final VoidCallback onPressed;
  final ServiceModel service;

  const _BottomCta({
    required this.hasSelected,
    required this.totalPrice,
    required this.fmt,
    required this.onPressed,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ── Baris 1: Estimasi harga + Selanjutnya ──
        Row(children: [
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
                foregroundColor: hasSelected
                    ? Colors.white
                    : AppColors.textHint,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Selanjutnya',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ]),
        const SizedBox(height: 8),

        // ── Baris 2: Tombol Konsultasi Dulu ──
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PreOrderChatScreen(service: service),
              ),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text('Konsultasi Dulu (Gratis)',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }
}
