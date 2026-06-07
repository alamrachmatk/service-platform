import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary, letterSpacing: -0.5);
  static const h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary);
  static const h3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);
  static const h4 = TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary);
  static const body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400,
      color: AppColors.textPrimary);
  static const bodySmall = TextStyle(fontSize: 13, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400,
      color: AppColors.textHint);
  static const label = TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
      color: AppColors.textSecondary);
  static const labelMedium = TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);
  static const button = TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
      color: Colors.white);
  static const link = TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
      color: AppColors.primary);
}
