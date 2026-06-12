import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final List<_PayMethod> _methods = [
    _PayMethod(type: 'GoPay', icon: Icons.account_balance_wallet_rounded,
        detail: 'Saldo Rp 125.000', color: const Color(0xFF00AED6), isLinked: true),
    _PayMethod(type: 'OVO', icon: Icons.account_balance_wallet_rounded,
        detail: 'Saldo Rp 50.000', color: const Color(0xFF4C3494), isLinked: true),
  ];

  static const _available = [
    (label: 'QRIS',           icon: Icons.qr_code_rounded,          color: Color(0xFF1565C0)),
    (label: 'DANA',           icon: Icons.account_balance_wallet_rounded, color: Color(0xFF118EEA)),
    (label: 'Transfer BCA',   icon: Icons.account_balance_rounded,   color: Color(0xFF005BAA)),
    (label: 'Transfer Mandiri', icon: Icons.account_balance_rounded, color: Color(0xFF003D7A)),
    (label: 'Transfer BNI',   icon: Icons.account_balance_rounded,   color: Color(0xFFE57200)),
  ];

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
        title: const Text('Metode Pembayaran',
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
          // ── Terhubung ──
          if (_methods.isNotEmpty) ...[
            const _SectionLabel(label: 'Tersimpan'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(
                children: List.generate(_methods.length, (i) {
                  final m = _methods[i];
                  final isLast = i == _methods.length - 1;
                  return Container(
                    decoration: BoxDecoration(
                      border: !isLast ? const Border(
                          bottom: BorderSide(color: AppColors.border, width: 0.5)) : null,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: m.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(m.icon, color: m.color, size: 20),
                      ),
                      title: Text(m.type, style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(m.detail, style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                      trailing: GestureDetector(
                        onTap: () {
                          setState(() => _methods.removeAt(i));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${m.type} dihapus'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Hapus', style: TextStyle(
                              fontSize: 12, color: AppColors.error,
                              fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Metode tersedia ──
          const _SectionLabel(label: 'Metode Lainnya'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5)),
            child: Column(
              children: List.generate(_available.length, (i) {
                final m = _available[i];
                final isLast = i == _available.length - 1;
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${m.label} akan segera tersedia'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: !isLast ? const Border(
                          bottom: BorderSide(color: AppColors.border, width: 0.5)) : null,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: m.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(m.icon, color: m.color, size: 20),
                      ),
                      title: Text(m.label, style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textHint, size: 20),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Row(children: [
              Icon(Icons.security_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text(
                'Semua transaksi dilindungi enkripsi SSL dan sistem escrow JasaKu.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              )),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary));
}

class _PayMethod {
  final String type, detail;
  final IconData icon;
  final Color color;
  final bool isLinked;
  const _PayMethod({required this.type, required this.icon,
      required this.detail, required this.color, required this.isLinked});
}
