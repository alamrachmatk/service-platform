import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MethodChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const MethodChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? color : AppColors.textHint, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: selected ? color : AppColors.textHint,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
