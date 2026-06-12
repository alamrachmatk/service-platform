import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class _ReviewItem {
  final String serviceName, mitraName, serviceEmoji, date, comment;
  final double rating;
  final List<String> tags;
  const _ReviewItem({
    required this.serviceName, required this.mitraName,
    required this.serviceEmoji, required this.date,
    required this.comment, required this.rating,
    this.tags = const [],
  });
}

const _dummyReviews = [
  _ReviewItem(
    serviceName: 'Bersih-Bersih Rumah', mitraName: 'Tim CleanPro',
    serviceEmoji: '🧹', date: '7 Jun 2026', rating: 5.0,
    comment: 'Tim CleanPro sangat profesional! Rumah jadi bersih dan wangi. Datang tepat waktu dan bekerja dengan rapi.',
    tags: ['Tepat waktu', 'Profesional', 'Hasil memuaskan'],
  ),
  _ReviewItem(
    serviceName: 'Servis AC Split', mitraName: 'Pak Dedi Teknik',
    serviceEmoji: '❄️', date: '2 Jun 2026', rating: 4.5,
    comment: 'AC langsung dingin setelah diservis. Teknisi ramah dan menjelaskan masalah dengan detail. Recommended!',
    tags: ['Ramah', 'Profesional'],
  ),
];

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ulasan Saya',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: _dummyReviews.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // ── Ringkasan rating ──
                _RatingSummary(reviews: _dummyReviews),
                const SizedBox(height: 16),
                // ── List ulasan ──
                ..._dummyReviews.map((r) => _ReviewCard(review: r)),
              ],
            ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final List<_ReviewItem> reviews;
  const _RatingSummary({required this.reviews});

  double get _avg =>
      reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

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
        // Rata-rata
        Column(children: [
          Text(_avg.toStringAsFixed(1),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Row(children: List.generate(5, (i) => Icon(
            i < _avg.floor() ? Icons.star_rounded : Icons.star_half_rounded,
            color: AppColors.secondary, size: 16,
          ))),
          const SizedBox(height: 4),
          Text('${reviews.length} ulasan', style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
        ]),
        const SizedBox(width: 20),
        const VerticalDivider(width: 1),
        const SizedBox(width: 20),
        // Bar rating
        Expanded(child: Column(
          children: [5, 4, 3, 2, 1].map((star) {
            final count = reviews.where((r) => r.rating.round() == star).length;
            final ratio = reviews.isEmpty ? 0.0 : count / reviews.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Text('$star', style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded,
                    color: AppColors.secondary, size: 11),
                const SizedBox(width: 6),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                    minHeight: 6,
                  ),
                )),
                const SizedBox(width: 6),
                Text('$count', style: const TextStyle(
                    fontSize: 11, color: AppColors.textHint)),
              ]),
            );
          }).toList(),
        )),
      ]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _ReviewItem review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Text(review.serviceEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.mitraName, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
              Text(review.serviceName, style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: List.generate(5, (i) => Icon(
              i < review.rating.floor()
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: AppColors.secondary, size: 14,
            ))),
            const SizedBox(height: 2),
            Text(review.date, style: const TextStyle(
                fontSize: 11, color: AppColors.textHint)),
          ]),
        ]),
        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 10),

        // Komentar
        Text(review.comment, style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary, height: 1.5)),

        // Tags
        if (review.tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6,
            children: review.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Text(tag, style: const TextStyle(fontSize: 11,
                  color: AppColors.primary, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
        ],
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('⭐', style: TextStyle(fontSize: 48)),
        SizedBox(height: 16),
        Text('Belum ada ulasan', style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        SizedBox(height: 6),
        Text('Ulasan yang kamu berikan\nakan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13,
                color: AppColors.textSecondary, height: 1.5)),
      ]),
    );
  }
}
