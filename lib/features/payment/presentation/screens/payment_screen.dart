import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/order_model.dart';
import '../../../orders/presentation/screens/orders_screen.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel order;
  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;
  bool _loading = false;

  static const _methods = [
    _PaymentMethod(id: 'qris',    label: 'QRIS',               icon: Icons.qr_code_rounded,               color: Color(0xFF1565C0)),
    _PaymentMethod(id: 'gopay',   label: 'GoPay',              icon: Icons.account_balance_wallet_rounded, color: Color(0xFF00AED6)),
    _PaymentMethod(id: 'ovo',     label: 'OVO',                icon: Icons.account_balance_wallet_rounded, color: Color(0xFF4C3494)),
    _PaymentMethod(id: 'dana',    label: 'DANA',               icon: Icons.account_balance_wallet_rounded, color: Color(0xFF118EEA)),
    _PaymentMethod(id: 'bca',     label: 'Transfer BCA',       icon: Icons.account_balance_rounded,        color: Color(0xFF005BAA)),
    _PaymentMethod(id: 'mandiri', label: 'Transfer Mandiri',   icon: Icons.account_balance_rounded,        color: Color(0xFF003D7A)),
    _PaymentMethod(id: 'bni',     label: 'Transfer BNI',       icon: Icons.account_balance_rounded,        color: Color(0xFFE57200)),
    _PaymentMethod(id: 'cod',     label: 'Bayar di Tempat (COD)', icon: Icons.payments_rounded,            color: Color(0xFF43A047)),
  ];

  Future<void> _pay() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih metode pembayaran terlebih dahulu'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loading = false);
    if (!mounted) return;
    await _showSuccessDialog();
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Pembayaran Berhasil!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Pesanan ${widget.order.serviceName} kamu\nsedang diproses oleh mitra.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14,
                    color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(widget.order.id,
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w700, color: AppColors.primary,
                      letterSpacing: 1)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    (route) => route.isFirst,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Lihat Pesanan',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Pembayaran',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Stack(
        children: [
          // ── Konten scrollable ──
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 100 + bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderSummaryCard(order: o),
                const SizedBox(height: 20),
                const Text('Pilih Metode Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text('Dana tersimpan aman sampai pekerjaan selesai (escrow)',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                _MethodGroup(
                  groupLabel: 'Dompet Digital',
                  methods: _methods.where((m) =>
                      ['qris', 'gopay', 'ovo', 'dana'].contains(m.id)).toList(),
                  selected: _selectedMethod,
                  onSelect: (id) => setState(() => _selectedMethod = id),
                ),
                const SizedBox(height: 12),
                _MethodGroup(
                  groupLabel: 'Transfer Bank',
                  methods: _methods.where((m) =>
                      ['bca', 'mandiri', 'bni'].contains(m.id)).toList(),
                  selected: _selectedMethod,
                  onSelect: (id) => setState(() => _selectedMethod = id),
                ),
                const SizedBox(height: 12),
                _MethodGroup(
                  groupLabel: 'Lainnya',
                  methods: _methods.where((m) => m.id == 'cod').toList(),
                  selected: _selectedMethod,
                  onSelect: (id) => setState(() => _selectedMethod = id),
                ),
                if (_selectedMethod == 'qris') ...[
                  const SizedBox(height: 16),
                  _QrisInfo(amount: o.price),
                ],
                if (['bca', 'mandiri', 'bni'].contains(_selectedMethod)) ...[
                  const SizedBox(height: 16),
                  _VaInfo(bank: _selectedMethod!, amount: o.price),
                ],
              ],
            ),
          ),

          // ── Fixed bottom bar ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _PaymentBottomBar(
              total: o.formattedPrice,
              loading: _loading,
              onPressed: _pay,
              bottomPadding: bottomPadding,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET HELPERS
// ─────────────────────────────────────────────

class _PaymentMethod {
  final String id, label;
  final IconData icon;
  final Color color;
  const _PaymentMethod({required this.id, required this.label,
      required this.icon, required this.color});
}

class _OrderSummaryCard extends StatelessWidget {
  final OrderModel order;
  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ringkasan Pesanan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          Text(order.serviceEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.serviceName, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
              Text(order.mitraName, style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
            ],
          )),
        ]),
        const Divider(height: 20),
        _SummaryRow(label: 'Jadwal',
            value: '${order.formattedDate} • ${order.formattedTime}'),
        _SummaryRow(label: 'Alamat', value: order.address, maxLines: 2),
        const Divider(height: 16),
        _SummaryRow(label: 'Biaya layanan',
            value: order.formattedPrice, isBold: true,
            valueColor: AppColors.primary),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;
  final int maxLines;
  const _SummaryRow({required this.label, required this.value,
      this.isBold = false, this.valueColor, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
        ),
        Expanded(child: Text(value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ))),
      ]),
    );
  }
}

class _MethodGroup extends StatelessWidget {
  final String groupLabel;
  final List<_PaymentMethod> methods;
  final String? selected;
  final void Function(String) onSelect;
  const _MethodGroup({required this.groupLabel, required this.methods,
      required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(groupLabel, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: List.generate(methods.length, (i) {
            final m = methods[i];
            final isSelected = selected == m.id;
            final isLast = i == methods.length - 1;
            return GestureDetector(
              onTap: () => onSelect(m.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.04)
                      : Colors.transparent,
                  border: !isLast
                      ? const Border(bottom: BorderSide(
                          color: AppColors.border, width: 0.5))
                      : null,
                ),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: m.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(m.icon, color: m.color, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(m.label,
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary))),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 5 : 1.5,
                      ),
                    ),
                  ),
                ]),
              ),
            );
          }),
        ),
      ),
    ]);
  }
}

class _QrisInfo extends StatelessWidget {
  final double amount;
  const _QrisInfo({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
      ),
      child: Column(children: [
        Container(
          width: 140, height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_2_rounded, size: 80, color: AppColors.textPrimary),
              Text('Scan QR', style: TextStyle(fontSize: 11,
                  color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('Scan dengan aplikasi apapun yang mendukung QRIS',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.timer_outlined, size: 14, color: AppColors.error),
          Text(' Berlaku selama ',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('15:00', style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w700, color: AppColors.error)),
        ]),
      ]),
    );
  }
}

class _VaInfo extends StatelessWidget {
  final String bank;
  final double amount;
  const _VaInfo({required this.bank, required this.amount});

  String get _bankName {
    switch (bank) {
      case 'bca':     return 'BCA';
      case 'mandiri': return 'Mandiri';
      case 'bni':     return 'BNI';
      default:        return bank.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('No. Virtual Account $_bankName',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(children: [
          const Text('8877-1234-5678-9012',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  letterSpacing: 1, color: AppColors.textPrimary)),
          const Spacer(),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nomor VA disalin!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Salin',
                  style: TextStyle(fontSize: 13, color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        const Text('Transfer sebelum 2x24 jam untuk menghindari pembatalan otomatis.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
      ]),
    );
  }
}

class _PaymentBottomBar extends StatelessWidget {
  final String total;
  final bool loading;
  final VoidCallback onPressed;
  final double bottomPadding;
  const _PaymentBottomBar({required this.total, required this.loading,
      required this.onPressed, required this.bottomPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total bayar',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(total, style: const TextStyle(fontSize: 18,
              fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: loading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Bayar Sekarang',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    );
  }
}
