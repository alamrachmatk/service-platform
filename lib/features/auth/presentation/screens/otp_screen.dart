import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/otp_box.dart';
import '../../../home/presentation/screens/main_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focuses     = List.generate(6, (_) => FocusNode());
  bool   _loading   = false;
  bool   _hasError  = false;
  int    _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focuses[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focuses) f.dispose();
    super.dispose();
  }

  // ── Countdown resend ──
  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_countdown <= 0) { t.cancel(); return; }
      setState(() => _countdown--);
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  // ── Verifikasi OTP ──
  Future<void> _verify() async {
    if (_otp.length < 6) return;
    setState(() { _loading = true; _hasError = false; });
    await Future.delayed(const Duration(seconds: 1));

    // Dev mode: kode valid = 123456
    if (_otp == '123456') {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainScreen(
            key: MainScreen.globalKey,
            user: UserModel(
              name: 'Pengguna JasaKu',
              phone: widget.phone,
            ),
          ),
        ),
        (_) => false,
      );
    } else {
      setState(() { _loading = false; _hasError = true; });
      for (final c in _controllers) c.clear();
      _focuses[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Ikon ──
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      size: 40, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),

              // ── Judul ──
              const Text('Verifikasi OTP',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14,
                      color: AppColors.textSecondary, height: 1.6),
                  children: [
                    const TextSpan(text: 'Kode OTP 6 digit telah dikirim ke\n'),
                    TextSpan(
                      text: '+62 ${widget.phone}',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Dev hint ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text('Mode dev: gunakan kode  1 2 3 4 5 6',
                      style: TextStyle(fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500)),
                ]),
              ),
              const SizedBox(height: 32),

              // ── 6 Kotak OTP ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => OtpBox(
                  controller: _controllers[i],
                  focusNode: _focuses[i],
                  hasError: _hasError,
                  onChanged: (v) {
                    setState(() => _hasError = false);
                    if (v.isNotEmpty && i < 5) _focuses[i + 1].requestFocus();
                    if (v.isEmpty && i > 0)    _focuses[i - 1].requestFocus();
                    if (_otp.length == 6) _verify();
                  },
                  onBackspace: () {
                    if (_controllers[i].text.isEmpty && i > 0) {
                      _focuses[i - 1].requestFocus();
                    }
                  },
                )),
              ),

              // ── Pesan error ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _hasError
                    ? const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Row(children: [
                          Icon(Icons.error_outline_rounded,
                              size: 16, color: AppColors.error),
                          SizedBox(width: 6),
                          Text('Kode OTP salah. Silakan coba lagi.',
                              style: TextStyle(fontSize: 13,
                                  color: AppColors.error)),
                        ]),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              // ── Tombol verifikasi ──
              PrimaryButton(
                label: 'Verifikasi',
                loading: _loading,
                onPressed: _otp.length == 6 ? _verify : () {},
              ),
              const SizedBox(height: 24),

              // ── Resend countdown ──
              Center(
                child: _countdown > 0
                    ? RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13,
                              color: AppColors.textSecondary),
                          children: [
                            const TextSpan(text: 'Kirim ulang kode dalam '),
                            TextSpan(
                              text: '$_countdown detik',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: _startCountdown,
                        child: const Text('Kirim ulang OTP',
                            style: TextStyle(fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline)),
                      ),
              ),

              const Spacer(),

              // ── Ganti nomor ──
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text('Ganti nomor HP',
                      style: TextStyle(fontSize: 13,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.underline)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
