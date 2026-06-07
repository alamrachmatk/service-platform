import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String? subtitle;
  const AuthHeader({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        children: [
          // Logo
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('JasaKu',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text(
            subtitle ?? 'Temukan jasa terpercaya di sekitarmu',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
