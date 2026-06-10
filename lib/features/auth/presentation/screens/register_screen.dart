import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/google_button.dart';
import '../../../../shared/widgets/or_divider.dart';
import '../../../home/presentation/screens/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  /// Dipanggil setelah register → navigasi ke OtpScreen
  final void Function(String phone) onSuccess;

  const RegisterScreen({super.key, required this.onSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _agreed  = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Setujui syarat & ketentuan terlebih dahulu'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (mounted) widget.onSuccess(_phoneCtrl.text.trim());
  }

  void _registerWithGoogle() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainScreen(
          key: MainScreen.globalKey,
          user: const UserModel(
            name: 'Pengguna Google',
            phone: '',
            email: 'user@gmail.com',
          ),
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Nama Lengkap', hint: 'Nama sesuai KTP',
              icon: Icons.person_outline_rounded, controller: _nameCtrl,
              validator: (v) =>
                  v != null && v.length >= 3 ? null : 'Nama minimal 3 karakter',
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Nomor HP (WhatsApp)', hint: '08xx-xxxx-xxxx',
              icon: Icons.phone_android_rounded, controller: _phoneCtrl,
              keyboardType: TextInputType.phone, prefixText: '+62 ',
              validator: (v) =>
                  v != null && v.length >= 9 ? null : 'Nomor tidak valid',
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Email (opsional)', hint: 'contoh@email.com',
              icon: Icons.email_outlined, controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // ── Checkbox syarat ──
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Checkbox(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      children: [
                        TextSpan(text: 'Saya setuju dengan '),
                        TextSpan(text: 'Syarat & Ketentuan',
                            style: TextStyle(color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                        TextSpan(text: ' dan '),
                        TextSpan(text: 'Kebijakan Privasi',
                            style: TextStyle(color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            PrimaryButton(
              label: 'Daftar & Kirim OTP WhatsApp',
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),

            const OrDivider(label: 'atau daftar dengan'),
            const SizedBox(height: 12),

            GoogleButton(label: 'Daftar dengan Google',
                onPressed: _registerWithGoogle),
          ],
        ),
      ),
    );
  }
}
