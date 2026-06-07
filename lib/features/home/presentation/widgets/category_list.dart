import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../search/presentation/screens/search_screen.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: DummyServices.categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final (emoji, label) = DummyServices.categories[i];
        return _CategoryItem(emoji: emoji, label: label);
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String emoji;
  final String label;
  const _CategoryItem({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Push ke SearchScreen dengan filter kategori yang dipilih
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchScreen(initialCategory: label),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ikon kategori
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
