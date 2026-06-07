import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../services/presentation/screens/service_detail_screen.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ✅ Sekarang navigasi ke ServiceDetailScreen, bukan bottom sheet
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(service: service),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          // Ikon kategori
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(service.emoji,
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),

          // Info layanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(service.mitra,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.secondary, size: 14),
                  const SizedBox(width: 3),
                  Text('${service.rating} (${service.reviewCount})',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on_outlined,
                      color: AppColors.textHint, size: 12),
                  Text(' ${service.distanceKm} km',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint)),
                ]),
              ],
            ),
          ),

          // Harga + arrow
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(service.formattedPrice,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            Text('/${service.priceUnit}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint)),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 10, color: AppColors.textHint),
          ]),
        ]),
      ),
    );
  }
}
