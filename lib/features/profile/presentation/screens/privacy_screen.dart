import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _notifOrder   = true;
  bool _notifPromo   = true;
  bool _notifSystem  = true;
  bool _shareLocation = true;
  bool _twoFactor    = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Privasi & Keamanan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Keamanan Akun ──
          _SectionTitle(title: 'Keamanan Akun'),
          const SizedBox(height: 8),
          _Card(children: [
            _ActionRow(
              icon: Icons.lock_outline_rounded,
              iconColor: AppColors.primary,
              title: 'Ubah Password',
              subtitle: 'Atur password untuk login via email',
              onTap: () => _showSnack('Fitur ubah password akan segera hadir'),
            ),
            const _Divider(),
            _SwitchRow(
              icon: Icons.security_rounded,
              iconColor: const Color(0xFF1976D2),
              title: 'Verifikasi 2 Langkah',
              subtitle: 'Keamanan ekstra saat login',
              value: _twoFactor,
              onChanged: (v) => setState(() => _twoFactor = v),
            ),
            const _Divider(),
            _ActionRow(
              icon: Icons.devices_outlined,
              iconColor: const Color(0xFF7B1FA2),
              title: 'Perangkat Aktif',
              subtitle: '1 perangkat sedang login',
              onTap: () => _showSnack('Menampilkan perangkat aktif'),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Notifikasi ──
          _SectionTitle(title: 'Pengaturan Notifikasi'),
          const SizedBox(height: 8),
          _Card(children: [
            _SwitchRow(
              icon: Icons.receipt_long_outlined,
              iconColor: AppColors.primary,
              title: 'Notifikasi Pesanan',
              subtitle: 'Update status pesanan real-time',
              value: _notifOrder,
              onChanged: (v) => setState(() => _notifOrder = v),
            ),
            const _Divider(),
            _SwitchRow(
              icon: Icons.local_offer_outlined,
              iconColor: AppColors.warning,
              title: 'Notifikasi Promo',
              subtitle: 'Diskon dan penawaran spesial',
              value: _notifPromo,
              onChanged: (v) => setState(() => _notifPromo = v),
            ),
            const _Divider(),
            _SwitchRow(
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF1976D2),
              title: 'Notifikasi Sistem',
              subtitle: 'Pembaruan aplikasi dan kebijakan',
              value: _notifSystem,
              onChanged: (v) => setState(() => _notifSystem = v),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Data & Privasi ──
          _SectionTitle(title: 'Data & Privasi'),
          const SizedBox(height: 8),
          _Card(children: [
            _SwitchRow(
              icon: Icons.location_on_outlined,
              iconColor: AppColors.error,
              title: 'Bagikan Lokasi',
              subtitle: 'Untuk mencari mitra terdekat',
              value: _shareLocation,
              onChanged: (v) => setState(() => _shareLocation = v),
            ),
            const _Divider(),
            _ActionRow(
              icon: Icons.download_outlined,
              iconColor: AppColors.success,
              title: 'Unduh Data Saya',
              subtitle: 'Ekspor semua data akunmu',
              onTap: () => _showSnack('Permintaan unduh data dikirim ke email'),
            ),
            const _Divider(),
            _ActionRow(
              icon: Icons.description_outlined,
              iconColor: AppColors.textSecondary,
              title: 'Kebijakan Privasi',
              subtitle: 'Baca kebijakan privasi JasaKu',
              onTap: () => _showSnack('Membuka kebijakan privasi'),
            ),
            const _Divider(),
            _ActionRow(
              icon: Icons.article_outlined,
              iconColor: AppColors.textSecondary,
              title: 'Syarat & Ketentuan',
              subtitle: 'Baca syarat dan ketentuan penggunaan',
              onTap: () => _showSnack('Membuka syarat & ketentuan'),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Hapus Akun ──
          _SectionTitle(title: 'Zona Berbahaya'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.error.withOpacity(0.3), width: 0.5),
              ),
              child: const Row(children: [
                Icon(Icons.delete_forever_rounded,
                    color: AppColors.error, size: 22),
                SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hapus Akun', style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700, color: AppColors.error)),
                    SizedBox(height: 2),
                    Text('Akun dan semua data akan dihapus permanen',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                )),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.error, size: 20),
              ]),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Akun?',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error)),
        content: const Text(
            'Semua data termasuk riwayat pesanan, ulasan, dan saldo akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(
                color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus Akun',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ──

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary));
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5)),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 0, indent: 14, endIndent: 14);
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _SwitchRow({required this.icon, required this.iconColor,
      required this.title, required this.subtitle,
      required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          Text(subtitle, style: const TextStyle(fontSize: 12,
              color: AppColors.textSecondary)),
        ])),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.iconColor,
      required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 12,
                color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 20),
        ]),
      ),
    );
  }
}
