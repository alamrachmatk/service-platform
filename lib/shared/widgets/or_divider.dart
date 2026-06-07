import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class OrDivider extends StatelessWidget {
  final String label;
  const OrDivider({super.key, this.label = 'atau'});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
      ),
      const Expanded(child: Divider()),
    ]);
  }
}
