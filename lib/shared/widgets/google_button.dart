import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const GoogleButton({
    super.key,
    this.label = 'Lanjutkan dengan Google',
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.g_mobiledata_rounded,
            size: 26, color: AppColors.error),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600,
                fontSize: 14, color: Color(0xFF37474F))),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
