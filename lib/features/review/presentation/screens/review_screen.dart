import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/order_model.dart';

class ReviewScreen extends StatefulWidget {
  final OrderModel order;
  const ReviewScreen({super.key, required this.order});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating    = 0;
  final _reviewCtrl = TextEditingController();
  final _tipCtrl    = TextEditingController();
  bool _loading     = false;
  final Set<String> _selectedTags = {};

  static const _quickTags = [
    'Tepat waktu', 'Ramah', 'Profesional', 'Bersih & rapi',
    'Hasil memuaskan', 'Harga sesuai', 'Komunikatif',
  ];

  String get _ratingLabel {
    if (_rating == 0) return 'Ketuk bintang untuk memberi nilai';
    if (_rating == 1) return '😞 Sangat kecewa';
    if (_rating == 2) return '😐 Kurang memuaskan';
    if (_rating == 3) return '🙂 Cukup baik';
    if (_rating == 4) return '😊 Memuaskan';
    return '🤩 Luar biasa!';
  }

  Color get _ratingColor {
    if (_rating <= 2) return AppColors.error;
    if (_rating == 3) return AppColors.secondary;
    return AppColors.success;
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Berikan rating bintang terlebih dahulu'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('Terima Kasih!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Ulasanmu membantu mitra\nberkembang lebih baik.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14,
                    color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Selesai',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    _tipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Beri Ulasan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // ── Ringkasan layanan yang direview ──
          _OrderSummaryCard(order: widget.order),
          const SizedBox(height: 20),

          // ── Rating bintang ──
          _RatingCard(
            rating: _rating,
            label: _ratingLabel,
            labelColor: _ratingColor,
            onRate: (r) => setState(() => _rating = r),
          ),
          const SizedBox(height: 16),

          // ── Quick tags ──
          if (_rating > 0) ...[
            _TagsCard(
              tags: _quickTags,
              selected: _selectedTags,
              onToggle: (tag) => setState(() {
                _selectedTags.contains(tag)
                    ? _selectedTags.remove(tag)
                    : _selectedTags.add(tag);
              }),
            ),
            const SizedBox(height: 16),
          ],

          // ── Tulis ulasan ──
          _WriteReviewCard(controller: _reviewCtrl),
          const SizedBox(height: 16),

          // ── Foto hasil kerja ──
          _PhotoUploadCard(),
          const SizedBox(height: 16),

          // ── Tip untuk mitra ──
          _TipCard(controller: _tipCtrl),
          const SizedBox(height: 100),
        ]),
      ),

      // ── Bottom bar ──
      bottomNavigationBar: _ReviewBottomBar(
        rating: _rating,
        loading: _loading,
        onSubmit: _submit,
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final OrderModel order;
  const _OrderSummaryCard({required this.order});

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
        Text(order.serviceEmoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.serviceName, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
            Text('oleh ${order.mitraName}', style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
            Text(order.formattedDate, style: const TextStyle(
                fontSize: 12, color: AppColors.textHint)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('✅ Selesai',
              style: TextStyle(fontSize: 11, color: AppColors.success,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final double rating;
  final String label;
  final Color labelColor;
  final void Function(double) onRate;
  const _RatingCard({required this.rating, required this.label,
      required this.labelColor, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        const Text('Bagaimana pengalaman kamu?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 13, color: labelColor,
            fontWeight: rating > 0 ? FontWeight.w600 : FontWeight.w400)),
        const SizedBox(height: 16),
        // Bintang
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < rating;
            return GestureDetector(
              onTap: () => onRate(i + 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: filled ? AppColors.secondary : AppColors.textHint,
                  size: filled ? 44 : 40,
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

class _TagsCard extends StatelessWidget {
  final List<String> tags;
  final Set<String> selected;
  final void Function(String) onToggle;
  const _TagsCard({required this.tags, required this.selected,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Apa yang kamu suka?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8,
          children: tags.map((tag) {
            final isSelected = selected.contains(tag);
            return GestureDetector(
              onTap: () => onToggle(tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(tag,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

class _WriteReviewCard extends StatelessWidget {
  final TextEditingController controller;
  const _WriteReviewCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tulis Ulasan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Ceritakan pengalamanmu agar membantu pelanggan lain',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 300,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Contoh: Mitra datang tepat waktu, hasil bersih dan rapi. Sangat puas!',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
            filled: true, fillColor: AppColors.background,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5)),
          ),
        ),
      ]),
    );
  }
}

class _PhotoUploadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Foto Hasil Kerja (opsional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Bagikan foto hasil pekerjaan untuk ulasan lebih lengkap',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border,
                  style: BorderStyle.solid),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    color: AppColors.primary, size: 28),
                SizedBox(height: 6),
                Text('Tambah foto',
                    style: TextStyle(fontSize: 12,
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _TipCard extends StatelessWidget {
  final TextEditingController controller;
  const _TipCard({required this.controller});

  static const _tips = [5000.0, 10000.0, 15000.0, 20000.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Beri Tip untuk Mitra',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('opsional',
                style: TextStyle(fontSize: 10, color: AppColors.secondary,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 4),
        const Text('100% tip langsung ke mitra, tidak dipotong platform',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(children: _tips.map((tip) {
          final label = tip >= 1000
              ? 'Rp ${(tip / 1000).toStringAsFixed(0)}rb'
              : 'Rp ${tip.toStringAsFixed(0)}';
          return Expanded(
            child: GestureDetector(
              onTap: () {
                controller.text = tip.toStringAsFixed(0);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Center(child: Text(label,
                    style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary))),
              ),
            ),
          );
        }).toList()),
      ]),
    );
  }
}

class _ReviewBottomBar extends StatelessWidget {
  final double rating;
  final bool loading;
  final VoidCallback onSubmit;
  const _ReviewBottomBar({required this.rating, required this.loading,
      required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SizedBox(
        height: 52, width: double.infinity,
        child: ElevatedButton(
          onPressed: (rating > 0 && !loading) ? onSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.border,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Kirim Ulasan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ),
    );
  }
}
