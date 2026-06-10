import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/order_model.dart';

class CancellationScreen extends StatefulWidget {
  final OrderModel order;
  const CancellationScreen({super.key, required this.order});

  @override
  State<CancellationScreen> createState() => _CancellationScreenState();
}

class _CancellationScreenState extends State<CancellationScreen> {
  String? _selectedReason;
  final _noteCtrl = TextEditingController();
  bool _loading   = false;
  bool _submitted = false;

  static const _reasons = [
    'Ingin mengubah jadwal',
    'Ingin mengubah layanan',
    'Mitra tidak kunjung datang',
    'Ada keperluan mendadak',
    'Menemukan mitra lain yang lebih murah',
    'Alasan lainnya',
  ];

  // Kebijakan refund berdasarkan status order
  _RefundPolicy get _refundPolicy {
    switch (widget.order.status) {
      case OrderStatus.pending:
        return _RefundPolicy(
          percentage: 100,
          label: 'Refund penuh',
          desc: 'Pembatalan sebelum mitra konfirmasi mendapat refund 100%.',
          color: AppColors.success,
        );
      case OrderStatus.confirmed:
        return _RefundPolicy(
          percentage: 75,
          label: 'Refund 75%',
          desc: 'Pembatalan setelah mitra konfirmasi mendapat refund 75%. Biaya admin 25% tidak dikembalikan.',
          color: AppColors.warning,
        );
      case OrderStatus.onTheWay:
        return _RefundPolicy(
          percentage: 50,
          label: 'Refund 50%',
          desc: 'Pembatalan saat mitra dalam perjalanan mendapat refund 50%.',
          color: AppColors.warning,
        );
      default:
        return _RefundPolicy(
          percentage: 0,
          label: 'Tidak bisa dibatalkan',
          desc: 'Order yang sedang dikerjakan atau selesai tidak dapat dibatalkan.',
          color: AppColors.error,
        );
    }
  }

  bool get _canCancel =>
      widget.order.status == OrderStatus.pending ||
      widget.order.status == OrderStatus.confirmed ||
      widget.order.status == OrderStatus.onTheWay;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih alasan pembatalan terlebih dahulu'),
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
        title: const Text('Konfirmasi Pembatalan',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah kamu yakin ingin membatalkan pesanan ini?',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(_refundPolicy.desc,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4))),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Batalkan', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _SuccessScreen(order: widget.order, policy: _refundPolicy);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Batalkan Pesanan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: !_canCancel
          ? _CannotCancelView(status: widget.order.status.label)
          : Stack(children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16,
                    100 + MediaQuery.of(context).padding.bottom),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // ── Info order ──
                  _OrderSummaryCard(order: widget.order),
                  const SizedBox(height: 16),

                  // ── Kebijakan refund ──
                  _RefundPolicyCard(policy: _refundPolicy, order: widget.order),
                  const SizedBox(height: 16),

                  // ── Pilih alasan ──
                  const Text('Alasan Pembatalan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Pilih alasan yang paling sesuai',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 0.5)),
                    child: Column(
                      children: List.generate(_reasons.length, (i) {
                        final reason = _reasons[i];
                        final selected = _selectedReason == reason;
                        final isLast = i == _reasons.length - 1;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedReason = reason),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary.withOpacity(0.04) : Colors.transparent,
                              border: !isLast ? const Border(
                                  bottom: BorderSide(color: AppColors.border, width: 0.5)) : null,
                            ),
                            child: Row(children: [
                              Expanded(child: Text(reason,
                                  style: TextStyle(fontSize: 14,
                                      color: selected ? AppColors.primary : AppColors.textPrimary,
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400))),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected ? AppColors.primary : AppColors.border,
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

                  // ── Catatan tambahan ──
                  const Text('Catatan Tambahan (opsional)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ceritakan alasan lebih detail...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                  ),
                ]),
              ),

              // ── Bottom bar ──
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 12, 20,
                      12 + MediaQuery.of(context).padding.bottom),
                  decoration: const BoxDecoration(color: Colors.white,
                      border: Border(top: BorderSide(color: AppColors.border, width: 0.5))),
                  child: SizedBox(
                    height: 52, width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_loading || _selectedReason == null) ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Ajukan Pembatalan',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ),
              ),
            ]),
    );
  }
}

// ── Model kebijakan refund ──
class _RefundPolicy {
  final int percentage;
  final String label, desc;
  final Color color;
  const _RefundPolicy({required this.percentage, required this.label,
      required this.desc, required this.color});
}

// ── Info order ──
class _OrderSummaryCard extends StatelessWidget {
  final OrderModel order;
  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(children: [
        Text(order.serviceEmoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(order.mitraName, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(order.serviceName, style: const TextStyle(fontSize: 12,
              color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('${order.formattedDate} · ${order.formattedTime}',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
        ])),
        Text(order.formattedPrice, style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
    );
  }
}

// ── Kebijakan refund ──
class _RefundPolicyCard extends StatelessWidget {
  final _RefundPolicy policy;
  final OrderModel order;
  const _RefundPolicyCard({required this.policy, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: policy.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: policy.color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.account_balance_wallet_outlined, color: policy.color, size: 18),
          const SizedBox(width: 8),
          Text('Kebijakan Refund', style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: policy.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(policy.label, style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w700, color: policy.color)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(policy.desc, style: const TextStyle(fontSize: 13,
            color: AppColors.textSecondary, height: 1.5)),
        if (policy.percentage > 0) ...[
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total dibayar', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text(order.formattedPrice, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Refund ${policy.percentage}%',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text(_calcRefund(order.price, policy.percentage),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: policy.color)),
          ]),
          const SizedBox(height: 6),
          const Text('Dana dikembalikan dalam 1-3 hari kerja ke metode pembayaran asal.',
              style: TextStyle(fontSize: 11, color: AppColors.textHint)),
        ],
      ]),
    );
  }

  String _calcRefund(double price, int pct) {
    final refund = price * pct / 100;
    if (refund >= 1000000) return 'Rp ${(refund / 1000000).toStringAsFixed(1)}jt';
    if (refund >= 1000) return 'Rp ${(refund / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${refund.toStringAsFixed(0)}';
  }
}

// ── View jika tidak bisa batal ──
class _CannotCancelView extends StatelessWidget {
  final String status;
  const _CannotCancelView({required this.status});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.block_rounded, size: 40, color: AppColors.error)),
          const SizedBox(height: 16),
          const Text('Tidak Dapat Dibatalkan', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Pesanan dengan status "$status" tidak dapat dibatalkan. '
              'Hubungi CS jika ada kendala.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Kembali'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary)),
          ),
        ]),
      ),
    );
  }
}

// ── Layar sukses pembatalan ──
class _SuccessScreen extends StatelessWidget {
  final OrderModel order;
  final _RefundPolicy policy;
  const _SuccessScreen({required this.order, required this.policy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Container(width: 80, height: 80,
                decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 44, color: AppColors.success)),
            const SizedBox(height: 24),
            const Text('Pembatalan Diajukan!', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text('Pesanan ${order.serviceName} berhasil dibatalkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            if (policy.percentage > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 0.5)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Status Refund',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Sedang diproses',
                          style: TextStyle(fontSize: 11, color: AppColors.warning,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
                  const Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Jumlah Refund',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(policy.label, style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ]),
                  const SizedBox(height: 8),
                  const Text('Dana dikembalikan dalam 1-3 hari kerja ke metode pembayaran asal.',
                      style: TextStyle(fontSize: 11, color: AppColors.textHint, height: 1.4)),
                ]),
              ),
            const Spacer(),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
