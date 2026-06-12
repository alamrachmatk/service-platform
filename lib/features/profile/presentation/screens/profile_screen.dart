import 'package:flutter/material.dart';
import '../../../promo/presentation/screens/promo_screen.dart';
import '../../../help/presentation/screens/help_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../auth/presentation/screens/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  static const _menuItems = [
    (icon: Icons.person_outline_rounded,   label: 'Edit Profil'),
    (icon: Icons.location_on_outlined,     label: 'Alamat Tersimpan'),
    (icon: Icons.payment_outlined,         label: 'Metode Pembayaran'),
    (icon: Icons.star_outline_rounded,     label: 'Ulasan Saya'),
    (icon: Icons.local_offer_outlined,     label: 'Promo & Voucher'),
    (icon: Icons.help_outline_rounded,     label: 'Bantuan & FAQ'),
    (icon: Icons.shield_outlined,          label: 'Privasi & Keamanan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Profil Saya',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Kartu profil ──
          _ProfileCard(user: user),
          const SizedBox(height: 16),

          // ── Menu ──
          ..._menuItems.map((item) => _MenuItem(
                icon: item.icon,
                label: item.label,
                onTap: () {
                  if (item.label == 'Promo & Voucher') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const PromoScreen()));
                  } else if (item.label == 'Bantuan & FAQ') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const HelpScreen()));
                  }
                },
              )),
          const SizedBox(height: 8),

          // ── Tombol keluar ──
          _LogoutButton(user: user),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserModel user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: 60, height: 60,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(user.initials,
                style: const TextStyle(fontSize: 24,
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),

        // Nama & kontak
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(user.name,
                style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(user.displayId,
                style: const TextStyle(fontSize: 13,
                    color: AppColors.textSecondary)),
          ]),
        ),

        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Pelanggan',
              style: TextStyle(fontSize: 11, color: AppColors.primary,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 20),
        ]),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final UserModel user;
  const _LogoutButton({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.error.withOpacity(0.2), width: 0.5),
        ),
        child: const Row(children: [
          Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
          SizedBox(width: 14),
          Text('Keluar dari Akun',
              style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600, color: AppColors.error)),
        ]),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
