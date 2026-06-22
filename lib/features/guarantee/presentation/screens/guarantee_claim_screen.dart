import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/order_model.dart';

// ── Status klaim ──
enum ClaimStatus { draft, submitted, reviewing, approved, rejected, resolved }

extension ClaimStatusX on ClaimStatus {
  String get label {
    switch (this) {
      case ClaimStatus.draft:      return 'Draft';
      case ClaimStatus.submitted:  return 'Dikirim';
      case ClaimStatus.reviewing:  return 'Sedang Ditinjau';
      case ClaimStatus.approved:   return 'Disetujui';
      case ClaimStatus.rejected:   return 'Ditolak';
      case ClaimStatus.resolved:   return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case ClaimStatus.draft:      return AppColors.textHint;
      case ClaimStatus.submitted:  return AppColors.info;
      case ClaimStatus.reviewing:  return AppColors.warning;
      case ClaimStatus.approved:   return AppColors.success;
      case ClaimStatus.rejected:   return AppColors.error;
      case ClaimStatus.resolved:   return AppColors.primary;
    }
  }
}

// ── Alasan klaim ──
const _claimReasons = [
  'Hasil kerja tidak sesuai ekspektasi',
  'Mitra tidak menyelesaikan semua pekerjaan',
  'Kerusakan properti saat pengerjaan',
  'Mitra tidak datang sesuai jadwal',
  'Kualitas bahan tidak sesuai yang dijanjikan',
  'Alasan lainnya',
];

class GuaranteeClaimScreen extends StatefulWidget {
  final OrderModel order;
  const GuaranteeClaimScreen({super.key, required this.order});

  @override
  State<GuaranteeClaimScreen> createState() => _GuaranteeClaimScreenState();
}

class _GuaranteeClaimScreenState extends State<GuaranteeClaimScreen> {
  String? _selectedReason;
  final _descCtrl = TextEditingController();
  bool _loading   = false;
  bool _submitted = false;
  int _photoCount = 0;

  Duration get _claimWindow {
    final cat = widget.order.serviceName.toLowerCase();
    if (cat.contains('ac') || cat.contains('elektronik')) {
      return const Duration(hours: 72);
    }
    return const Duration(hours: 24);
  }

  bool get _isWithinWindow {
    final deadline = widget.order.scheduledAt.add(_claimWindow);
    return DateTime.now().isBefore(deadline);
  }

  String get _windowText {
    if (_claimWindow.inHours == 72) return '3x24 jam';
    return '1x24 jam';
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih alasan klaim terlebih dahulu'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Deskripsikan masalah yang dialami'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _loading = false; _submitted = true; });
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Kirim Klaim Garansi?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const Text(
          'Tim JasaKu akan meninjau klaimmu dalam 1x24 jam. '
          'Pastikan deskripsi dan foto sudah lengkap.',
          style: TextStyle(fontSize: 14,
              color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Periksa Lagi',
                style: TextStyle(color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Kirim Klaim',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _ClaimSuccessScreen(order: widget.order);
    }

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
        title: const Text('Klaim Garansi',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: !_isWithinWindow
          ? _ExpiredView(windowText: _windowText)
          : Stack(children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16,
                    100 + MediaQuery.of(context).padding.bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GuaranteeInfoCard(windowText: _windowText),
                    const SizedBox(height: 16),

                    _OrderCard(order: widget.order),
                    const SizedBox(height: 16),

                    const Text('Alasan Klaim',
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Pilih yang paling sesuai dengan masalah kamu',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.border, width: 0.5),
                      ),
                      child: Column(
                        children: List.generate(
                            _claimReasons.length, (i) {
                          final reason = _claimReasons[i];
                          final selected = _selectedReason == reason;
                          final isLast = i == _claimReasons.length - 1;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedReason = reason),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary.withOpacity(0.04)
                                    : Colors.transparent,
                                border: !isLast
                                    ? const Border(bottom: BorderSide(
                                    color: AppColors.border, width: 0.5))
                                    : null,
                              ),
                              child: Row(children: [
                                Expanded(child: Text(reason,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ))),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: selected ? 5 : 1.5,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Deskripsi Masalah',
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Ceritakan masalah secara detail agar tim kami bisa membantu',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 5,
                      maxLength: 500,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText:
                        'Contoh: AC sudah diservis tapi masih tidak dingin. '
                            'Teknisi hanya membersihkan filter tapi tidak cek freon...',
                        hintStyle: const TextStyle(
                            fontSize: 13, color: AppColors.textHint),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Foto Bukti',
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text(
                        'Foto memperkuat klaim kamu. Tambahkan foto sebelum/sesudah jika ada.',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    Row(children: [
                      ...List.generate(_photoCount, (i) => Container(
                        width: 76, height: 76,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Stack(children: [
                          const Center(child: Icon(
                              Icons.image_outlined,
                              color: AppColors.primary, size: 28)),
                          Positioned(
                            top: 4, right: 4,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _photoCount--),
                              child: Container(
                                width: 18, height: 18,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.white, size: 11),
                              ),
                            ),
                          ),
                        ]),
                      )),
                      if (_photoCount < 5)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _photoCount++),
                          child: Container(
                            width: 76, height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.border,
                                  style: BorderStyle.solid),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    color: AppColors.primary, size: 24),
                                SizedBox(height: 4),
                                Text('Tambah',
                                    style: TextStyle(fontSize: 10,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 8),
                    Text('$_photoCount/5 foto ditambahkan',
                        style: const TextStyle(fontSize: 11,
                            color: AppColors.textHint)),
                    const SizedBox(height: 16),

                    _ClaimProcessInfo(),
                  ],
                ),
              ),

              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 12, 20,
                      12 + MediaQuery.of(context).padding.bottom),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(
                        color: AppColors.border, width: 0.5)),
                  ),
                  child: SizedBox(
                    height: 52, width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_loading || _selectedReason == null)
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : const Text('Kirim Klaim Garansi',
                          style: TextStyle(fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                  ),
                ),
              ),
            ]),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET HELPERS
// ─────────────────────────────────────────────

class _GuaranteeInfoCard extends StatelessWidget {
  final String windowText;
  const _GuaranteeInfoCard({required this.windowText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.verified_user_rounded,
              color: AppColors.primary, size: 20),
          SizedBox(width: 8),
          Text('Jaminan Kepuasan JasaKu',
              style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ]),
        const SizedBox(height: 10),
        _GuaranteePoint(
          icon: Icons.replay_rounded,
          text: 'Layanan ulang gratis jika hasil tidak memuaskan',
        ),
        _GuaranteePoint(
          icon: Icons.account_balance_wallet_outlined,
          text: 'Refund penuh jika mitra terbukti lalai',
        ),
        _GuaranteePoint(
          icon: Icons.security_rounded,
          text: 'Perlindungan kerusakan properti hingga Rp5.000.000',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.timer_outlined,
                size: 14, color: AppColors.warning),
            const SizedBox(width: 6),
            Text('Klaim dalam $windowText setelah layanan selesai',
                style: const TextStyle(fontSize: 11,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

class _GuaranteePoint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _GuaranteePoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
            style: const TextStyle(fontSize: 13,
                color: AppColors.textSecondary))),
      ]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Text(order.serviceEmoji,
            style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.mitraName,
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            Text(order.serviceName,
                style: const TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('${order.formattedDate} · ${order.formattedTime}',
                style: const TextStyle(fontSize: 11,
                    color: AppColors.textHint)),
          ],
        )),
        Text(order.formattedPrice,
            style: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      ]),
    );
  }
}

class _ClaimProcessInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Proses Klaim',
              style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _ProcessStep(step: 1, title: 'Klaim dikirim',
              desc: 'Tim JasaKu menerima klaimmu',
              isLast: false),
          _ProcessStep(step: 2, title: 'Ditinjau (1x24 jam)',
              desc: 'Tim menghubungi kamu dan mitra untuk klarifikasi',
              isLast: false),
          _ProcessStep(step: 3, title: 'Solusi diberikan',
              desc: 'Layanan ulang gratis atau refund sesuai klaim',
              isLast: true),
        ],
      ),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  final int step;
  final String title, desc;
  final bool isLast;
  const _ProcessStep({required this.step, required this.title,
      required this.desc, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          child: Center(child: Text('$step',
              style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: Colors.white))),
        ),
        if (!isLast) Container(width: 2, height: 32,
            color: AppColors.border),
      ]),
      const SizedBox(width: 12),
      Expanded(child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 12,
                color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
      )),
    ]);
  }
}

// ── View klaim kedaluwarsa ──
class _ExpiredView extends StatelessWidget {
  final String windowText;
  const _ExpiredView({required this.windowText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_off_rounded,
                size: 40, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          const Text('Waktu Klaim Habis',
              style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Klaim garansi hanya bisa diajukan dalam $windowText '
            'setelah layanan selesai. Hubungi CS kami jika ada keluhan mendesak.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13,
                color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Kembali'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Screen sukses setelah submit ──
class _ClaimSuccessScreen extends StatelessWidget {
  final OrderModel order;
  const _ClaimSuccessScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_rounded,
                  size: 44, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            const Text('Klaim Berhasil Dikirim! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            const Text(
              'Tim JasaKu akan meninjau klaimmu dalam 1x24 jam '
              'dan menghubungimu via WhatsApp atau notifikasi aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14,
                  color: AppColors.textSecondary, height: 1.6)),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(children: [
                _ClaimInfoRow(label: 'ID Klaim',
                    value: 'CLM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    valueColor: AppColors.primary),
                const Divider(height: 16),
                _ClaimInfoRow(label: 'Order',
                    value: order.serviceName),
                const Divider(height: 16),
                _ClaimInfoRow(label: 'Status',
                    value: '🔍 Sedang Ditinjau',
                    valueColor: AppColors.warning),
                const Divider(height: 16),
                _ClaimInfoRow(label: 'Estimasi',
                    value: 'Selesai dalam 1x24 jam'),
              ]),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                SizedBox(width: 10),
                Expanded(child: Text(
                  'Jika klaim disetujui, kamu akan mendapat layanan ulang gratis '
                  'atau refund ke metode pembayaran asal dalam 1-3 hari kerja.',
                  style: TextStyle(fontSize: 12,
                      color: AppColors.textSecondary, height: 1.4),
                )),
              ]),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Kembali ke Beranda',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ClaimInfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _ClaimInfoRow({required this.label, required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13,
            color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}
