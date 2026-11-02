import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Menampilkan pilihan sumber foto (Galeri / Kamera) lalu mengembalikan path
/// foto, atau null jika dibatalkan.
///
/// TODO: ganti bagian "stub" dengan image_picker saat siap:
///   final picker = ImagePicker();
///   final x = await picker.pickImage(
///       source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
///       imageQuality: 80);
///   return x?.path;
Future<String?> pickPhoto(BuildContext context,
    {String title = 'Pilih Sumber Foto'}) async {
  final source = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(ctx).padding.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: const TextStyle(fontSize: 16,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _SourceButton(
            icon: Icons.photo_library_outlined, label: 'Galeri',
            onTap: () => Navigator.pop(ctx, 'gallery'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _SourceButton(
            icon: Icons.camera_alt_outlined, label: 'Kamera',
            onTap: () => Navigator.pop(ctx, 'camera'),
          )),
        ]),
      ]),
    ),
  );
  if (source == null) return null;

  // ── stub: simulasi memilih foto ──
  await Future.delayed(const Duration(milliseconds: 400));
  return 'dummy_${source}_${DateTime.now().millisecondsSinceEpoch}';
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceButton({required this.icon, required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
    ),
  );
}
