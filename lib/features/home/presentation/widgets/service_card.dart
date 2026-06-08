import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../services/presentation/screens/service_detail_screen.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + nama mitra + rating ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar mitra (inisial)
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      service.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Nama mitra + rating + jarak
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama mitra — judul utama
                      Text(
                        service.mitra,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Rating + ulasan + jarak
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.secondary, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${service.rating}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                        Text(
                          ' (${service.reviewCount} ulasan)',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.textHint, size: 12),
                        Text(
                          ' ${service.distanceKm} km',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textHint),
                        ),
                      ]),
                      const SizedBox(height: 5),
                      // Badge verified
                      if (service.isVerified)
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.verified_rounded,
                              color: AppColors.primary, size: 13),
                          const SizedBox(width: 3),
                          const Text('Terverifikasi',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ]),
                    ],
                  ),
                ),

                // Ikon favorit
                const Icon(Icons.favorite_border_rounded,
                    color: AppColors.textHint, size: 20),
              ],
            ),
          ),

          // ── Divider ──
          const Divider(height: 1, indent: 14, endIndent: 14),

          // ── Deskripsi singkat ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Text(
              service.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ── Preview sub-layanan (maks 2) ──
          if (service.subServices.isNotEmpty) ...[
            const Divider(height: 1, indent: 14, endIndent: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Column(
                children: service.subServices.take(2).map((sub) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(children: [
                            Container(
                              width: 5, height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(sub.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                        ),
                        // Tampilkan harga mulai dari item termurah
                        Text(
                          sub.items.isEmpty
                              ? '-'
                              : 'Mulai ${sub.formattedMinPrice}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
              ),
            ),
            // Jika ada lebih dari 2 sub-layanan
            if (service.subServices.length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 14, bottom: 8),
                child: Text(
                  '+${service.subServices.length - 2} layanan lainnya',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500),
                ),
              ),
          ],

          // ── Tombol aksi ──
          const Divider(height: 1, indent: 14, endIndent: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(children: [
              // Tombol Lihat Profil
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ServiceDetailScreen(service: service),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Lihat Profil',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              // Tombol Pilih Layanan
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ServiceDetailScreen(service: service),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Pilih Layanan',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
