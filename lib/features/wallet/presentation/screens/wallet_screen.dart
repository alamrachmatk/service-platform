import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Warna brand ──
class _C {
  static const primary      = Color(0xFF00897B);
  static const primaryLight = Color(0xFF4DB6AC);
  static const bg           = Color(0xFFF5F5F5);
  static const border       = Color(0xFFE0E0E0);
  static const textPrimary  = Color(0xFF212121);
  static const textSecondary= Color(0xFF757575);
  static const textHint     = Color(0xFFBDBDBD);
  static const success      = Color(0xFF43A047);
  static const warning      = Color(0xFFFFA726);
  static const error        = Color(0xFFE53935);
  static const info         = Color(0xFF1E88E5);
}

// ── Model transaksi dompet ──
enum WalletTxType { topup, payment, refund, withdrawal }

extension WalletTxTypeX on WalletTxType {
  String get label {
    switch (this) {
      case WalletTxType.topup:      return 'Top Up';
      case WalletTxType.payment:    return 'Pembayaran';
      case WalletTxType.refund:     return 'Refund';
      case WalletTxType.withdrawal: return 'Tarik Saldo';
    }
  }
  String get emoji {
    switch (this) {
      case WalletTxType.topup:      return '💳';
      case WalletTxType.payment:    return '🧾';
      case WalletTxType.refund:     return '↩️';
      case WalletTxType.withdrawal: return '🏦';
    }
  }
  bool get isCredit =>
      this == WalletTxType.topup || this == WalletTxType.refund;
}

class WalletTransaction {
  final String id, description;
  final double amount;
  final WalletTxType type;
  final DateTime date;

  const WalletTransaction({
    required this.id, required this.description,
    required this.amount, required this.type, required this.date,
  });

  String get formattedAmount {
    final prefix = type.isCredit ? '+' : '-';
    if (amount >= 1000000) return '$prefix Rp ${(amount/1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000)    return '$prefix Rp ${(amount/1000).toStringAsFixed(0)}rb';
    return '$prefix Rp ${amount.toStringAsFixed(0)}';
  }

  String get formattedDate {
    const months = ['','Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Agu','Sep','Okt','Nov','Des'];
    final h = date.hour.toString().padLeft(2,'0');
    final m = date.minute.toString().padLeft(2,'0');
    return '${date.day} ${months[date.month]} · $h:$m';
  }
}

// ── Dummy data ──
double _walletBalance = 125000;

final List<WalletTransaction> _walletTxs = [
  WalletTransaction(id:'WTX-001', description:'Top Up via GoPay',
      amount:100000, type:WalletTxType.topup,
      date:DateTime.now().subtract(const Duration(hours:2))),
  WalletTransaction(id:'WTX-002', description:'Bayar Servis AC Split',
      amount:150000, type:WalletTxType.payment,
      date:DateTime.now().subtract(const Duration(days:1))),
  WalletTransaction(id:'WTX-003', description:'Refund Pesanan ORD-005',
      amount:75000, type:WalletTxType.refund,
      date:DateTime.now().subtract(const Duration(days:2))),
  WalletTransaction(id:'WTX-004', description:'Top Up via Transfer BCA',
      amount:200000, type:WalletTxType.topup,
      date:DateTime.now().subtract(const Duration(days:3))),
  WalletTransaction(id:'WTX-005', description:'Bayar Bersih-Bersih Rumah',
      amount:100000, type:WalletTxType.payment,
      date:DateTime.now().subtract(const Duration(days:5))),
  WalletTransaction(id:'WTX-006', description:'Tarik ke BCA ••4521',
      amount:50000, type:WalletTxType.withdrawal,
      date:DateTime.now().subtract(const Duration(days:7))),
];

// ── Payment methods ──
const _topupMethods = [
  (id:'gopay',   name:'GoPay',    emoji:'💚', fee:0),
  (id:'ovo',     name:'OVO',      emoji:'💜', fee:0),
  (id:'dana',    name:'DANA',     emoji:'💙', fee:0),
  (id:'bca',     name:'Transfer BCA',  emoji:'🏦', fee:2500),
  (id:'mandiri', name:'Transfer Mandiri', emoji:'🏦', fee:2500),
  (id:'bni',     name:'Transfer BNI',  emoji:'🏦', fee:2500),
];

const _withdrawMethods = [
  (id:'bca',     name:'BCA',     no:'••4521', emoji:'🏦'),
  (id:'gopay',   name:'GoPay',   no:'••7890', emoji:'💚'),
  (id:'ovo',     name:'OVO',     no:'••7890', emoji:'💜'),
];

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _balanceVisible = true;
  String _filterType   = 'Semua';
  static const _filters = ['Semua','Top Up','Pembayaran','Refund','Tarik'];
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p/1000000).toStringAsFixed(1)}jt';
    if (p >= 1000)    return 'Rp ${(p/1000).toStringAsFixed(0)}.000';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  List<WalletTransaction> get _filtered {
    if (_filterType == 'Semua') return _walletTxs;
    final map = {'Top Up': WalletTxType.topup, 'Pembayaran': WalletTxType.payment,
        'Refund': WalletTxType.refund, 'Tarik': WalletTxType.withdrawal};
    return _walletTxs.where((t) => t.type == map[_filterType]).toList();
  }

  void _openTopUp() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TopUpSheet(),
    );
    if (result != null && result > 0) {
      setState(() {
        _walletBalance += result;
        _walletTxs.insert(0, WalletTransaction(
          id: 'WTX-NEW-${DateTime.now().millisecondsSinceEpoch}',
          description: 'Top Up via JasaKu Pay',
          amount: result, type: WalletTxType.topup,
          date: DateTime.now(),
        ));
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Top up ${_fmt(result)} berhasil!'),
        backgroundColor: _C.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _openWithdraw() async {
    if (_walletBalance < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Saldo minimum untuk tarik adalah Rp 10.000'),
        backgroundColor: _C.error, behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WithdrawSheet(balance: _walletBalance),
    );
    if (result != null && result > 0) {
      // Minta PIN konfirmasi
      final pinOk = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _PinSheet(),
      );
      if (pinOk == true) {
        setState(() {
          _walletBalance -= result;
          _walletTxs.insert(0, WalletTransaction(
            id: 'WTX-WD-${DateTime.now().millisecondsSinceEpoch}',
            description: 'Tarik ke rekening',
            amount: result, type: WalletTxType.withdrawal,
            date: DateTime.now(),
          ));
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Penarikan ${_fmt(result)} berhasil diajukan!'),
          backgroundColor: _C.success, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.primary, elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('JasaKu Pay', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: CustomScrollView(controller: _scrollCtrl, slivers: [

        // ── Header saldo ──
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_C.primary, _C.primaryLight],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Column(children: [
              const Text('Saldo JasaKu Pay', style: TextStyle(
                  fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  _balanceVisible ? _fmt(_walletBalance) : 'Rp ••••••',
                  style: const TextStyle(fontSize: 32,
                      fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () =>
                      setState(() => _balanceVisible = !_balanceVisible),
                  child: Icon(
                    _balanceVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white70, size: 20,
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // Tombol Top Up & Tarik
              Row(children: [
                Expanded(child: _WalletBtn(
                  icon: Icons.add_rounded,
                  label: 'Top Up',
                  onTap: _openTopUp,
                )),
                const SizedBox(width: 12),
                Expanded(child: _WalletBtn(
                  icon: Icons.account_balance_rounded,
                  label: 'Tarik Saldo',
                  onTap: _openWithdraw,
                )),
                const SizedBox(width: 12),
                Expanded(child: _WalletBtn(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  onTap: () => _scrollCtrl.animateTo(
                    300,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  ),
                )),
              ]),
            ]),
          ),
        ),

        // ── Info penggunaan ──
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.border, width: 0.5),
            ),
            child: Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _C.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: _C.primary, size: 20)),
              const SizedBox(width: 12),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saldo Terlindungi', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
                  Text('Saldo aman & bisa dipakai untuk semua pesanan JasaKu',
                      style: TextStyle(fontSize: 11, color: _C.textSecondary,
                          height: 1.4)),
                ],
              )),
            ]),
          ),
        ),

        // ── Filter transaksi ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Riwayat Transaksi', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = _filters[i];
                      final sel = f == _filterType;
                      return GestureDetector(
                        onTap: () => setState(() => _filterType = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? _C.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? _C.primary : _C.border,
                              width: sel ? 0 : 0.5,
                            ),
                          ),
                          child: Text(f, style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : _C.textSecondary)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── List transaksi ──
        _filtered.isEmpty
            ? SliverToBoxAdapter(
                child: const Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('💸', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 12),
                    Text('Belum ada transaksi', style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: _C.textPrimary)),
                  ]),
                )),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _TxCard(tx: _filtered[i]),
                    childCount: _filtered.length,
                  ),
                ),
              ),
      ]),
    );
  }
}

// ── Wallet button ──
class _WalletBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _WalletBtn({required this.icon, required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 11,
            color: Colors.white, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ── Transaction card ──
class _TxCard extends StatelessWidget {
  final WalletTransaction tx;
  const _TxCard({required this.tx});

  Color get _color => tx.type.isCredit ? _C.success : _C.error;

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TxDetailSheet(tx: tx),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _showDetail(context),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border, width: 0.5),
      ),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(
            color: _color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(tx.type.emoji,
              style: const TextStyle(fontSize: 22)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tx.type.label, style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w600, color: _C.textSecondary)),
            Text(tx.description, style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w500, color: _C.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(tx.formattedDate, style: const TextStyle(
                fontSize: 11, color: _C.textHint)),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(tx.formattedAmount, style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: _color)),
          const SizedBox(height: 4),
          const Icon(Icons.chevron_right_rounded,
              size: 16, color: _C.textHint),
        ]),
      ]),
    ),
  );
}

// ── Detail transaksi bottom sheet ──
class _TxDetailSheet extends StatelessWidget {
  final WalletTransaction tx;
  const _TxDetailSheet({required this.tx});

  Color get _color => tx.type.isCredit ? _C.success : _C.error;

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p/1000000).toStringAsFixed(1)}jt';
    if (p >= 1000)    return 'Rp ${(p/1000).toStringAsFixed(0)}.000';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: _C.border,
                borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 24),

        // Ikon & nominal
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: _color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(tx.type.emoji,
              style: const TextStyle(fontSize: 30))),
        ),
        const SizedBox(height: 12),
        Text(tx.type.label, style: const TextStyle(
            fontSize: 13, color: _C.textSecondary)),
        const SizedBox(height: 6),
        Text(
          '${tx.type.isCredit ? '+' : '-'} ${_fmt(tx.amount)}',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
              color: _color),
        ),
        const SizedBox(height: 20),

        // Detail info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _C.bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: [
            _DetailRow(label: 'ID Transaksi', value: tx.id,
                valueColor: _C.primary),
            const Divider(height: 16),
            _DetailRow(label: 'Keterangan', value: tx.description),
            const Divider(height: 16),
            _DetailRow(label: 'Tanggal', value: tx.formattedDate),
            const Divider(height: 16),
            _DetailRow(label: 'Tipe', value: tx.type.label),
            const Divider(height: 16),
            _DetailRow(
              label: 'Status',
              value: '✅ Berhasil',
              valueColor: _C.success,
            ),
          ]),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary, foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Tutup',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(
          fontSize: 12, color: _C.textSecondary))),
      Expanded(child: Text(value, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: valueColor ?? _C.textPrimary),
          textAlign: TextAlign.right)),
    ],
  );
}

// ─────────────────────────────────────────────
// TOP UP SHEET
// ─────────────────────────────────────────────
class _TopUpSheet extends StatefulWidget {
  const _TopUpSheet();
  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<_TopUpSheet> {
  double _amount = 0;
  String _method = 'gopay';
  static const _quickAmounts = [25000, 50000, 100000, 200000, 500000];

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p/1000000).toStringAsFixed(1)}jt';
    if (p >= 1000)    return 'Rp ${(p/1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  int get _fee => _topupMethods.firstWhere((m) => m.id == _method).fee;
  bool get _isValid => _amount >= 10000;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: _C.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Top Up JasaKu Pay', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w700, color: _C.textPrimary)),
          const SizedBox(height: 20),

          // Nominal
          const Align(alignment: Alignment.centerLeft,
            child: Text('Nominal Top Up', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: _C.textSecondary))),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
            children: _quickAmounts.map((a) {
              final sel = _amount == a;
              return GestureDetector(
                onTap: () => setState(() => _amount = a.toDouble()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? _C.primary.withOpacity(0.1) : _C.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? _C.primary : _C.border,
                      width: sel ? 1.5 : 0.5,
                    ),
                  ),
                  child: Text(_fmt(a.toDouble()), style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: sel ? _C.primary : _C.textSecondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Metode pembayaran
          const Align(alignment: Alignment.centerLeft,
            child: Text('Metode Pembayaran', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: _C.textSecondary))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border, width: 0.5)),
            child: Column(
              children: List.generate(_topupMethods.length, (i) {
                final m = _topupMethods[i];
                final sel = _method == m.id;
                final isLast = i == _topupMethods.length - 1;
                return GestureDetector(
                  onTap: () => setState(() => _method = m.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? _C.primary.withOpacity(0.04) : Colors.transparent,
                      border: !isLast ? const Border(bottom: BorderSide(
                          color: _C.border, width: 0.5)) : null,
                    ),
                    child: Row(children: [
                      Text(m.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(m.name, style: TextStyle(
                          fontSize: 14,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                          color: sel ? _C.primary : _C.textPrimary))),
                      if (m.fee > 0)
                        Text('+ Rp ${(m.fee/1000).toStringAsFixed(1)}rb',
                            style: const TextStyle(fontSize: 11,
                                color: _C.textSecondary))
                      else
                        const Text('Gratis', style: TextStyle(
                            fontSize: 11, color: _C.success,
                            fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18, height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: sel ? _C.primary : _C.border,
                            width: sel ? 5 : 1.5,
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

          // Total
          if (_isValid) Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _C.bg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total dibayar', style: TextStyle(
                    fontSize: 13, color: _C.textSecondary)),
                Text(_fmt(_amount + _fee), style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: _C.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _isValid
                  ? () => Navigator.pop(context, _amount)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary, foregroundColor: Colors.white,
                disabledBackgroundColor: _C.border, elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(_isValid
                  ? 'Top Up ${_fmt(_amount)}'
                  : 'Pilih nominal minimal Rp 10.000',
                  style: const TextStyle(fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WITHDRAW SHEET
// ─────────────────────────────────────────────
class _WithdrawSheet extends StatefulWidget {
  final double balance;
  const _WithdrawSheet({required this.balance});
  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  double _amount = 0;
  String _method = 'bca';
  static const _quickAmounts = [10000, 25000, 50000, 100000];

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p/1000000).toStringAsFixed(1)}jt';
    if (p >= 1000)    return 'Rp ${(p/1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  bool get _isValid => _amount >= 10000 && _amount <= widget.balance;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: _C.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Tarik Saldo', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w700, color: _C.textPrimary)),
          const SizedBox(height: 6),

          // Info saldo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saldo tersedia',
                    style: TextStyle(fontSize: 13, color: _C.textSecondary)),
                Text(_fmt(widget.balance), style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: _C.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick amount
          const Align(alignment: Alignment.centerLeft,
            child: Text('Nominal Penarikan', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: _C.textSecondary))),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
            children: [
              ..._quickAmounts.map((a) {
                final sel = _amount == a;
                final disabled = a > widget.balance;
                return GestureDetector(
                  onTap: disabled ? null
                      : () => setState(() => _amount = a.toDouble()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: disabled ? _C.bg
                          : sel ? _C.primary.withOpacity(0.1) : _C.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: disabled ? _C.border
                            : sel ? _C.primary : _C.border,
                        width: sel ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(_fmt(a.toDouble()), style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: disabled ? _C.textHint
                            : sel ? _C.primary : _C.textSecondary)),
                  ),
                );
              }),
              // Tarik semua
              GestureDetector(
                onTap: () => setState(() => _amount = widget.balance),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: _amount == widget.balance
                        ? _C.primary.withOpacity(0.1) : _C.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _amount == widget.balance
                          ? _C.primary : _C.border,
                      width: _amount == widget.balance ? 1.5 : 0.5,
                    ),
                  ),
                  child: Text('Semua (${_fmt(widget.balance)})',
                      style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _amount == widget.balance
                              ? _C.primary : _C.textSecondary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tujuan penarikan
          const Align(alignment: Alignment.centerLeft,
            child: Text('Tujuan Penarikan', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: _C.textSecondary))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border, width: 0.5)),
            child: Column(
              children: List.generate(_withdrawMethods.length, (i) {
                final m = _withdrawMethods[i];
                final sel = _method == m.id;
                final isLast = i == _withdrawMethods.length - 1;
                return GestureDetector(
                  onTap: () => setState(() => _method = m.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? _C.primary.withOpacity(0.04) : Colors.transparent,
                      border: !isLast ? const Border(bottom: BorderSide(
                          color: _C.border, width: 0.5)) : null,
                    ),
                    child: Row(children: [
                      Text(m.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: TextStyle(fontSize: 14,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                              color: sel ? _C.primary : _C.textPrimary)),
                          Text(m.no, style: const TextStyle(
                              fontSize: 11, color: _C.textSecondary)),
                        ],
                      )),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18, height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: sel ? _C.primary : _C.border,
                            width: sel ? 5 : 1.5,
                          ),
                        ),
                      ),
                    ]),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Dana masuk dalam 1x24 jam hari kerja · Gratis biaya',
              style: TextStyle(fontSize: 11, color: _C.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),

          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _isValid
                  ? () => Navigator.pop(context, _amount)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary, foregroundColor: Colors.white,
                disabledBackgroundColor: _C.border, elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(_isValid
                  ? 'Tarik ${_fmt(_amount)}'
                  : _amount > widget.balance
                      ? 'Melebihi saldo'
                      : 'Pilih nominal minimal Rp 10.000',
                  style: const TextStyle(fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PIN SHEET
// ─────────────────────────────────────────────
class _PinSheet extends StatefulWidget {
  const _PinSheet();
  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  String _pin = '';
  bool _loading = false;
  bool _error = false;
  static const _correctPin = '123456'; // simulasi PIN

  void _onKey(String k) {
    if (_pin.length >= 6) return;
    setState(() { _pin += k; _error = false; });
    if (_pin.length == 6) _verify();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    if (_pin == _correctPin) {
      Navigator.pop(context, true);
    } else {
      setState(() { _pin = ''; _loading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: _C.border,
                borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        const Icon(Icons.lock_outline_rounded, color: _C.primary, size: 36),
        const SizedBox(height: 10),
        const Text('Masukkan PIN', style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w700, color: _C.textPrimary)),
        const Text('Konfirmasi dengan PIN 6 digit kamu',
            style: TextStyle(fontSize: 13, color: _C.textSecondary)),
        const SizedBox(height: 20),

        // PIN dots
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 14, height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < _pin.length
                  ? (_error ? _C.error : _C.primary)
                  : _C.border,
            ),
          )),
        ),
        if (_error) ...[
          const SizedBox(height: 8),
          const Text('PIN salah, coba lagi',
              style: TextStyle(fontSize: 12, color: _C.error,
                  fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 24),

        // Numpad
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: _C.primary),
          )
        else
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...['1','2','3','4','5','6','7','8','9'].map((k) =>
                  _PinKey(label: k, onTap: () => _onKey(k))),
              const SizedBox(),
              _PinKey(label: '0', onTap: () => _onKey('0')),
              _PinKey(
                icon: Icons.backspace_outlined,
                onTap: _onDelete,
              ),
            ],
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal', style: TextStyle(
              color: _C.textSecondary, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _PinKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  const _PinKey({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _C.bg, borderRadius: BorderRadius.circular(12)),
      child: Center(child: icon != null
          ? Icon(icon, color: _C.textPrimary, size: 22)
          : Text(label!, style: const TextStyle(fontSize: 22,
              fontWeight: FontWeight.w600, color: _C.textPrimary))),
    ),
  );
}
