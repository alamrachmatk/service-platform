import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(children: [
        // Lingkaran dekorasi
        Positioned(
          right: -24, top: -24,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 40, bottom: -30,
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Konten
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Promo Baru 🎉',
                    style: TextStyle(fontSize: 11, color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),
              const Text('Diskon 30% untuk\npesanan pertama!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      color: Colors.white, height: 1.3)),
            ],
          ),
        ),
      ]),
    );
  }
}
