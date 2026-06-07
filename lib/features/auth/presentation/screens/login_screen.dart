import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/google_button.dart';
import '../../../../shared/widgets/or_divider.dart';
import '../widgets/method_chip.dart';
import '../../../home/presentation/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  /// Dipanggil setelah request OTP sukses → navigasi ke OtpScreen
  final void Function(String phone) onSuccess;

  const LoginScreen({super.key, required this.onSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _inputCtrl = TextEditingController();
  bool   _loading  = false;
  String _method   = 'whatsapp'; // 'whatsapp' | 'sms' | 'email'

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // Simulasi request ke server
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (mounted) widget.onSuccess(_inputCtrl.text.trim());
  }

  void _loginWithGoogle() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainScreen(
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
            const Text('Masuk dengan',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),

            // ── Pilih metode ──
            Row(children: [
              MethodChip(
                icon: Icons.chat_rounded, label: 'WhatsApp',
                selected: _method == 'whatsapp', color: AppColors.waGreen,
                onTap: () => setState(() => _method = 'whatsapp'),
              ),
              const SizedBox(width: 8),
              MethodChip(
                icon: Icons.sms_rounded, label: 'SMS',
                selected: _method == 'sms', color: AppColors.smsBlue,
                onTap: () => setState(() => _method = 'sms'),
              ),
              const SizedBox(width: 8),
              MethodChip(
                icon: Icons.email_rounded, label: 'Email',
                selected: _method == 'email', color: AppColors.error,
                onTap: () => setState(() => _method = 'email'),
              ),
            ]),
            const SizedBox(height: 20),

            // ── Input ──
            if (_method == 'email')
              AppTextField(
                label: 'Alamat Email', hint: 'contoh@email.com',
                icon: Icons.email_outlined, controller: _inputCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Email tidak valid',
              )
            else
              AppTextField(
                label: 'Nomor HP', hint: '08xx-xxxx-xxxx',
                icon: Icons.phone_android_rounded, controller: _inputCtrl,
                keyboardType: TextInputType.phone, prefixText: '+62 ',
                validator: (v) =>
                    v != null && v.length >= 9 ? null : 'Nomor tidak valid',
              ),
            const SizedBox(height: 16),

            // ── Tombol kirim OTP ──
            PrimaryButton(
              label: _method == 'email'
                  ? 'Kirim Link Masuk'
                  : 'Kirim OTP via ${_method == 'whatsapp' ? 'WhatsApp' : 'SMS'}',
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 20),

            const OrDivider(),
            const SizedBox(height: 16),

            GoogleButton(onPressed: _loginWithGoogle),
          ],
        ),
      ),
    );
  }
}
