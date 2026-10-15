import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Notifikasi ──
  bool _notifPesanan     = true;
  bool _notifPromo       = true;
  bool _notifChat        = true;
  bool _notifPembayaran  = true;
  bool _notifPengingat   = true;
  bool _notifUlasan      = false;

  // ── Suara & Getar ──
  bool _suaraNotif  = true;
  bool _getarNotif  = true;
  bool _suaraPesan  = true;

  // ── Umum ──
  bool _modeMalam   = false;
  String _bahasa    = 'Indonesia';

  static const _bahasaOptions = ['Indonesia', 'English'];

  void _snack(String msg, {Color color = AppColors.success}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengaturan', style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Notifikasi ──
          _SectionHeader(title: 'Notifikasi',
              icon: Icons.notifications_outlined),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _SwitchTile(
              icon: Icons.receipt_long_outlined,
              iconColor: AppColors.primary,
              title: 'Update Pesanan',
              subtitle: 'Status perjalanan dan penyelesaian mitra',
              value: _notifPesanan,
              onChanged: (v) => setState(() => _notifPesanan = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: AppColors.info,
              title: 'Pesan Chat',
              subtitle: 'Pesan dari mitra atau JasaKu',
              value: _notifChat,
              onChanged: (v) => setState(() => _notifChat = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.payments_outlined,
              iconColor: AppColors.success,
              title: 'Pembayaran & Saldo',
              subtitle: 'Konfirmasi pembayaran dan top up JasaKu Pay',
              value: _notifPembayaran,
              onChanged: (v) => setState(() => _notifPembayaran = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.local_offer_outlined,
              iconColor: AppColors.warning,
              title: 'Promo & Voucher',
              subtitle: 'Penawaran spesial dan voucher baru',
              value: _notifPromo,
              onChanged: (v) => setState(() => _notifPromo = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.alarm_outlined,
              iconColor: AppColors.error,
              title: 'Pengingat Jadwal',
              subtitle: 'Pengingat H-1 sebelum jadwal layanan',
              value: _notifPengingat,
              onChanged: (v) => setState(() => _notifPengingat = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.star_outline_rounded,
              iconColor: AppColors.secondary,
              title: 'Minta Ulasan',
              subtitle: 'Pengingat untuk beri ulasan setelah layanan',
              value: _notifUlasan,
              onChanged: (v) => setState(() => _notifUlasan = v),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Suara & Getar ──
          _SectionHeader(title: 'Suara & Getar',
              icon: Icons.volume_up_outlined),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _SwitchTile(
              icon: Icons.notifications_active_outlined,
              iconColor: AppColors.primary,
              title: 'Suara Notifikasi',
              subtitle: 'Bunyi saat ada notifikasi masuk',
              value: _suaraNotif,
              onChanged: (v) => setState(() => _suaraNotif = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.vibration_rounded,
              iconColor: AppColors.info,
              title: 'Getar',
              subtitle: 'Getaran saat ada notifikasi masuk',
              value: _getarNotif,
              onChanged: (v) => setState(() => _getarNotif = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.chat_outlined,
              iconColor: AppColors.success,
              title: 'Suara Pesan',
              subtitle: 'Bunyi saat menerima pesan chat',
              value: _suaraPesan,
              onChanged: (v) => setState(() => _suaraPesan = v),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Tampilan ──
          _SectionHeader(title: 'Tampilan & Bahasa',
              icon: Icons.palette_outlined),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _SwitchTile(
              icon: Icons.dark_mode_outlined,
              iconColor: const Color(0xFF5C6BC0),
              title: 'Mode Malam',
              subtitle: 'Tampilan gelap untuk menghemat baterai',
              value: _modeMalam,
              onChanged: (v) {
                setState(() => _modeMalam = v);
                _snack('Mode malam ${v ? 'aktif' : 'nonaktif'} '
                    '(tersedia di versi berikutnya)',
                    color: AppColors.info);
              },
            ),
            const _Divider(),
            _SelectTile(
              icon: Icons.language_rounded,
              iconColor: AppColors.primary,
              title: 'Bahasa',
              value: _bahasa,
              options: _bahasaOptions,
              onChanged: (v) {
                setState(() => _bahasa = v);
                _snack('Bahasa diubah ke $v');
              },
            ),
          ]),
          const SizedBox(height: 16),

          // ── Keamanan ──
          _SectionHeader(title: 'Keamanan Akun',
              icon: Icons.security_outlined),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _NavTile(
              icon: Icons.lock_outline_rounded,
              iconColor: AppColors.warning,
              title: 'Ubah Password',
              subtitle: 'Ganti password akun JasaKu',
              onTap: () => _showChangePasswordSheet(),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.pin_outlined,
              iconColor: AppColors.primary,
              title: 'PIN JasaKu Pay',
              subtitle: 'Atur PIN untuk transaksi dompet',
              onTap: () => _snack('Fitur ubah PIN segera hadir'),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.fingerprint_rounded,
              iconColor: AppColors.success,
              title: 'Biometrik',
              subtitle: 'Login dengan sidik jari atau Face ID',
              onTap: () => _snack('Fitur biometrik segera hadir'),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.phone_android_rounded,
              iconColor: AppColors.info,
              title: 'Ubah Nomor HP',
              subtitle: 'Verifikasi OTP diperlukan',
              onTap: () => _snack('Fitur ubah nomor HP segera hadir'),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.devices_outlined,
              iconColor: AppColors.error,
              title: 'Sesi Aktif',
              subtitle: 'Lihat dan kelola perangkat yang login',
              onTap: () => _showActiveSessionsSheet(),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Privasi ──
          _SectionHeader(title: 'Privasi',
              icon: Icons.privacy_tip_outlined),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _NavTile(
              icon: Icons.location_off_outlined,
              iconColor: AppColors.primary,
              title: 'Izin Lokasi',
              subtitle: 'Kelola akses lokasi aplikasi',
              onTap: () => _snack('Buka pengaturan lokasi HP'),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.error,
              title: 'Hapus Riwayat Pencarian',
              subtitle: 'Bersihkan riwayat pencarian layanan',
              onTap: () => _confirmClearHistory(),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Info Aplikasi ──
          _SectionHeader(title: 'Info Aplikasi',
              icon: Icons.info_outline_rounded),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _NavTile(
              icon: Icons.description_outlined,
              iconColor: AppColors.primary,
              title: 'Syarat & Ketentuan',
              onTap: () => _showInfoSheet('Syarat & Ketentuan',
                  'Dengan menggunakan aplikasi JasaKu, kamu menyetujui '
                  'seluruh syarat dan ketentuan yang berlaku. '
                  'JasaKu berhak memperbarui ketentuan sewaktu-waktu '
                  'dengan pemberitahuan sebelumnya.'),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: AppColors.info,
              title: 'Kebijakan Privasi',
              onTap: () => _showInfoSheet('Kebijakan Privasi',
                  'JasaKu berkomitmen melindungi data pribadi pengguna. '
                  'Data yang dikumpulkan hanya digunakan untuk keperluan '
                  'operasional platform dan tidak dijual kepada pihak ketiga.'),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.star_rate_rounded,
              iconColor: AppColors.secondary,
              title: 'Beri Rating Aplikasi',
              subtitle: 'Bantu kami berkembang dengan ulasanmu',
              onTap: () => _snack('Membuka Play Store...'),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.headset_mic_outlined,
              iconColor: AppColors.success,
              title: 'Hubungi CS',
              subtitle: 'WhatsApp: +62 812-3456-7890',
              onTap: () => _snack('Membuka WhatsApp CS...'),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Versi ──
          Center(child: Column(children: [
            const Text('JasaKu', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            const Text('Versi 1.0.0 (Build 100)',
                style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Versi terbaru ✓',
                  style: TextStyle(fontSize: 10, color: AppColors.success,
                      fontWeight: FontWeight.w600)),
            ),
          ])),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showChangePasswordSheet() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.fromLTRB(20, 12, 20,
              MediaQuery.of(context).padding.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Ubah Password', style: TextStyle(fontSize: 17,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            _PwField(ctrl: oldCtrl, label: 'Password Lama'),
            const SizedBox(height: 12),
            _PwField(ctrl: newCtrl, label: 'Password Baru'),
            const SizedBox(height: 12),
            _PwField(ctrl: confCtrl, label: 'Konfirmasi Password Baru'),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Batal',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _snack('Password berhasil diubah');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white, elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Simpan',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showActiveSessionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.fromLTRB(20, 12, 20,
            MediaQuery.of(context).padding.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Sesi Aktif', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _SessionTile(device: 'Samsung Galaxy S23', location: 'Bogor, ID',
              time: 'Sekarang', isCurrent: true),
          const Divider(),
          _SessionTile(device: 'iPhone 14 Pro', location: 'Jakarta, ID',
              time: '2 hari lalu', isCurrent: false),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                _snack('Semua sesi lain berhasil dikeluarkan',
                    color: AppColors.error);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Keluarkan Semua Sesi Lain',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showInfoSheet(String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.fromLTRB(20, 12, 20,
            MediaQuery.of(context).padding.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 17,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.background,
                borderRadius: BorderRadius.circular(12)),
            child: Text(content, style: const TextStyle(fontSize: 13,
                color: AppColors.textSecondary, height: 1.6)),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Tutup',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Riwayat?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Semua riwayat pencarian akan dihapus.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _snack('Riwayat pencarian berhasil dihapus');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white, elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 15,
        fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  ]);
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

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
      const Divider(height: 0, indent: 56, endIndent: 0);
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final void Function(bool) onChanged;
  const _SwitchTile({required this.icon, required this.iconColor,
      required this.title, this.subtitle, required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(fontSize: 11,
                color: AppColors.textSecondary)),
        ],
      )),
      Switch(value: value, onChanged: onChanged,
          activeColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    ]),
  );
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _NavTile({required this.icon, required this.iconColor,
      required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            if (subtitle != null)
              Text(subtitle!, style: const TextStyle(fontSize: 11,
                  color: AppColors.textSecondary)),
          ],
        )),
        const Icon(Icons.chevron_right_rounded,
            color: AppColors.textHint, size: 18),
      ]),
    ),
  );
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, value;
  final List<String> options;
  final void Function(String) onChanged;
  const _SelectTile({required this.icon, required this.iconColor,
      required this.title, required this.value, required this.options,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
      DropdownButton<String>(
        value: value, underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.textHint, size: 18),
        style: const TextStyle(fontSize: 13,
            color: AppColors.primary, fontWeight: FontWeight.w600),
        items: options.map((o) =>
            DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    ]),
  );
}

class _PwField extends StatefulWidget {
  final TextEditingController ctrl;
  final String label;
  const _PwField({required this.ctrl, required this.label});

  @override
  State<_PwField> createState() => _PwFieldState();
}

class _PwFieldState extends State<_PwField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(widget.label, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextField(
        controller: widget.ctrl, obscureText: _obscure,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: const TextStyle(color: AppColors.textHint),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
                size: 18, color: AppColors.textHint),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          filled: true, fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12),
        ),
      ),
    ],
  );
}

class _SessionTile extends StatelessWidget {
  final String device, location, time;
  final bool isCurrent;
  const _SessionTile({required this.device, required this.location,
      required this.time, required this.isCurrent});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primary.withOpacity(0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.phone_android_rounded,
            color: isCurrent ? AppColors.primary : AppColors.textHint,
            size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(device, style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('$location · $time', style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary)),
        ],
      )),
      if (isCurrent)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Aktif', style: TextStyle(fontSize: 10,
              color: AppColors.success, fontWeight: FontWeight.w700)),
        )
      else
        TextButton(
          onPressed: () {},
          child: const Text('Keluarkan',
              style: TextStyle(fontSize: 11, color: AppColors.error,
                  fontWeight: FontWeight.w600)),
        ),
    ]),
  );
}
