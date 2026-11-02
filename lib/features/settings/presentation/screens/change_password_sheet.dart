import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Menampilkan sheet ubah password. Mengembalikan true bila password berhasil
/// disimpan, null/false bila dibatalkan.
///
/// Dipakai bersama oleh halaman Pengaturan dan halaman Privasi agar perilakunya
/// sama di kedua tempat.
/// TODO: panggil API ubah password di `_submit()` saat backend siap.
Future<bool?> showChangePasswordSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ChangePasswordSheet(),
  );
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  static const _minLength = 8;

  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confCtrl = TextEditingController();
  bool _saving = false;

  String? get _newError {
    if (_newCtrl.text.isEmpty) return null;
    if (_newCtrl.text.length < _minLength) {
      return 'Minimal $_minLength karakter';
    }
    if (_newCtrl.text == _oldCtrl.text) {
      return 'Password baru harus berbeda dari yang lama';
    }
    return null;
  }

  String? get _confError {
    if (_confCtrl.text.isEmpty) return null;
    if (_confCtrl.text != _newCtrl.text) return 'Konfirmasi tidak cocok';
    return null;
  }

  bool get _valid =>
      _oldCtrl.text.isNotEmpty &&
      _newCtrl.text.length >= _minLength &&
      _newCtrl.text != _oldCtrl.text &&
      _confCtrl.text == _newCtrl.text;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_valid || _saving) return;
    setState(() => _saving = true);
    // TODO: ganti dengan panggilan API ubah password
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Ubah Password', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          _PwField(ctrl: _oldCtrl, label: 'Password Lama',
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          _PwField(ctrl: _newCtrl, label: 'Password Baru',
              errorText: _newError, onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          _PwField(ctrl: _confCtrl, label: 'Konfirmasi Password Baru',
              errorText: _confError, onChanged: (_) => setState(() {})),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
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
              onPressed: (_valid && !_saving) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }
}

class _PwField extends StatefulWidget {
  final TextEditingController ctrl;
  final String label;
  final String? errorText;
  final void Function(String)? onChanged;
  const _PwField({required this.ctrl, required this.label,
      this.errorText, this.onChanged});

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
        controller: widget.ctrl,
        obscureText: _obscure,
        onChanged: widget.onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: const TextStyle(color: AppColors.textHint),
          errorText: widget.errorText,
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    ],
  );
}
