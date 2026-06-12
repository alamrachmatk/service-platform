import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nama tidak boleh kosong'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Profil berhasil disimpan'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    Navigator.pop(context);
  }

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
        title: const Text('Edit Profil',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 24, 16,
              100 + MediaQuery.of(context).padding.bottom),
          child: Column(children: [
            // ── Avatar ──
            Center(
              child: Stack(children: [
                Container(
                  width: 88, height: 88,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(
                    widget.user.initials,
                    style: const TextStyle(fontSize: 32,
                        fontWeight: FontWeight.w700, color: Colors.white),
                  )),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_outlined,
                        size: 14, color: Colors.white),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            const Text('Ketuk untuk ubah foto',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 28),

            // ── Form ──
            _FormCard(children: [
              _FieldItem(
                label: 'Nama Lengkap',
                controller: _nameCtrl,
                icon: Icons.person_outline_rounded,
                hint: 'Nama sesuai KTP',
              ),
              const _Divider(),
              _FieldItem(
                label: 'Email',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                hint: 'contoh@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const _Divider(),
              _FieldItem(
                label: 'Nomor HP',
                controller: _phoneCtrl,
                icon: Icons.phone_android_rounded,
                hint: '08xx-xxxx-xxxx',
                keyboardType: TextInputType.phone,
                prefixText: '+62 ',
                note: 'Ubah nomor HP membutuhkan verifikasi OTP',
              ),
            ]),
            const SizedBox(height: 16),

            // ── Info akun ──
            _FormCard(children: [
              _InfoRow(label: 'Status Akun', value: 'Pelanggan Aktif',
                  valueColor: AppColors.success),
              const _Divider(),
              _InfoRow(label: 'Member sejak', value: 'Juni 2026'),
              const _Divider(),
              _InfoRow(label: 'Total Pesanan', value: '3 pesanan'),
            ]),
          ]),
        ),

        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
            color: Colors.white,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Perubahan',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5)),
    child: Column(children: children),
  );
}

class _FieldItem extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final String? prefixText, note;

  const _FieldItem({required this.label, required this.hint,
      required this.controller, required this.icon,
      this.keyboardType = TextInputType.text,
      this.prefixText, this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12,
            fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textHint),
            prefixText: prefixText,
            prefixStyle: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            filled: true, fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text(note!, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ]),
        ],
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    child: Row(children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: valueColor ?? AppColors.textPrimary)),
    ]),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 0, indent: 14, endIndent: 14);
}
