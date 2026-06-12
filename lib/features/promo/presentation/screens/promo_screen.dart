import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

// ── Model Voucher ──
class VoucherModel {
  final String code, title, desc, expiry;
  final int discountPct;
  final int? minOrder;
  final int? maxDiscount;
  final VoucherType type;
  final bool isUsed;

  const VoucherModel({
    required this.code,
    required this.title,
    required this.desc,
    required this.expiry,
    required this.discountPct,
    required this.type,
    this.minOrder,
    this.maxDiscount,
    this.isUsed = false,
  });
}

enum VoucherType { discount, freeOngkir, cashback, referral }

extension VoucherTypeX on VoucherType {
  String get label {
    switch (this) {
      case VoucherType.discount:   return 'Diskon';
      case VoucherType.freeOngkir: return 'Gratis Biaya';
      case VoucherType.cashback:   return 'Cashback';
      case VoucherType.referral:   return 'Referral';
    }
  }

  Color get color {
    switch (this) {
      case VoucherType.discount:   return AppColors.primary;
      case VoucherType.freeOngkir: return AppColors.info;
      case VoucherType.cashback:   return AppColors.success;
      case VoucherType.referral:   return const Color(0xFF7B1FA2);
    }
  }

  IconData get icon {
    switch (this) {
      case VoucherType.discount:   return Icons.local_offer_outlined;
      case VoucherType.freeOngkir: return Icons.delivery_dining_outlined;
      case VoucherType.cashback:   return Icons.account_balance_wallet_outlined;
      case VoucherType.referral:   return Icons.people_outline_rounded;
    }
  }
}

// ── Dummy data voucher ──
const _myVouchers = [
  VoucherModel(
    code: 'JASAKU30',
    title: 'Diskon 30% Pesanan Pertama',
    desc: 'Berlaku untuk semua kategori layanan. Maks diskon Rp50.000.',
    expiry: '30 Jun 2026',
    discountPct: 30,
    minOrder: 100000,
    maxDiscount: 50000,
    type: VoucherType.discount,
  ),
  VoucherModel(
    code: 'GRATIS2RB',
    title: 'Gratis Biaya Layanan',
    desc: 'Biaya layanan Rp2.000 ditanggung platform.',
    expiry: '15 Jul 2026',
    discountPct: 100,
    type: VoucherType.freeOngkir,
  ),
  VoucherModel(
    code: 'CASHBACK10',
    title: 'Cashback 10%',
    desc: 'Cashback 10% maks Rp20.000. Dikreditkan ke saldo dalam 1x24 jam.',
    expiry: '31 Jul 2026',
    discountPct: 10,
    minOrder: 150000,
    maxDiscount: 20000,
    type: VoucherType.cashback,
  ),
  VoucherModel(
    code: 'WEEKEND25',
    title: 'Diskon 25% Weekend',
    desc: 'Khusus Sabtu–Minggu untuk layanan kebersihan dan laundry.',
    expiry: '31 Agu 2026',
    discountPct: 25,
    minOrder: 80000,
    maxDiscount: 35000,
    type: VoucherType.discount,
  ),
  VoucherModel(
    code: 'REFERRAL25K',
    title: 'Bonus Referral Rp25.000',
    desc: 'Kamu berhasil mengajak teman! Kredit Rp25.000 siap digunakan.',
    expiry: '31 Des 2026',
    discountPct: 0,
    type: VoucherType.referral,
    isUsed: true,
  ),
];

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _codeCtrl = TextEditingController();
  bool _loadingCode = false;
  String? _codeError;
  String? _codeSuccess;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _redeemCode() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() { _codeError = 'Masukkan kode voucher'; _codeSuccess = null; });
      return;
    }
    setState(() { _loadingCode = true; _codeError = null; _codeSuccess = null; });
    await Future.delayed(const Duration(seconds: 1));

    // Cek apakah kode valid
    final valid = _myVouchers.any((v) => v.code == code);
    setState(() {
      _loadingCode = false;
      if (valid) {
        _codeSuccess = 'Voucher $code berhasil ditambahkan!';
        _codeCtrl.clear();
      } else {
        _codeError = 'Kode voucher tidak valid atau sudah kedaluwarsa.';
      }
    });
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
        title: const Text('Promo & Voucher',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(children: [
        // ── Input kode voucher ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Punya kode voucher?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 1),
                  onChanged: (_) => setState(() {
                    _codeError = null;
                    _codeSuccess = null;
                  }),
                  decoration: InputDecoration(
                    hintText: 'Contoh: JASAKU30',
                    hintStyle: const TextStyle(fontSize: 14,
                        color: AppColors.textHint, letterSpacing: 0,
                        fontWeight: FontWeight.w400),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: _codeError != null
                                ? AppColors.error
                                : AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loadingCode ? null : _redeemCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: _loadingCode
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Gunakan',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
            // Pesan error / sukses
            if (_codeError != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.error_outline_rounded,
                    size: 14, color: AppColors.error),
                const SizedBox(width: 6),
                Text(_codeError!, style: const TextStyle(
                    fontSize: 12, color: AppColors.error)),
              ]),
            ],
            if (_codeSuccess != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Text(_codeSuccess!, style: const TextStyle(
                    fontSize: 12, color: AppColors.success)),
              ]),
            ],
          ]),
        ),

        // ── Tab bar ──
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14),
            tabs: [
              Tab(text: 'Voucherku (${_myVouchers.where((v) => !v.isUsed).length})'),
              const Tab(text: 'Program Referral'),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.border),

        // ── Tab content ──
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              // Tab voucher
              _VoucherList(vouchers: _myVouchers),
              // Tab referral
              const _ReferralTab(),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── List voucher ──
class _VoucherList extends StatelessWidget {
  final List<VoucherModel> vouchers;
  const _VoucherList({required this.vouchers});

  @override
  Widget build(BuildContext context) {
    final active = vouchers.where((v) => !v.isUsed).toList();
    final used   = vouchers.where((v) => v.isUsed).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (active.isNotEmpty) ...[
          ...active.map((v) => _VoucherCard(voucher: v)),
        ],
        if (used.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('Sudah Digunakan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
          ...used.map((v) => _VoucherCard(voucher: v)),
        ],
      ],
    );
  }
}

// ── Kartu voucher ──
class _VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  const _VoucherCard({required this.voucher});

  String _fmt(int amount) {
    if (amount >= 1000000) return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000)    return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    return 'Rp $amount';
  }

  @override
  Widget build(BuildContext context) {
    final color = voucher.isUsed ? AppColors.textHint : voucher.type.color;

    return Opacity(
      opacity: voucher.isUsed ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          // ── Strip kiri ──
          Container(
            width: 6,
            height: 110,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),

          // ── Ikon ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(voucher.type.icon, color: color, size: 22),
            ),
          ),

          // ── Info voucher ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(voucher.type.label,
                          style: TextStyle(fontSize: 10,
                              fontWeight: FontWeight.w600, color: color)),
                    ),
                    const Spacer(),
                    Text('s/d ${voucher.expiry}',
                        style: const TextStyle(fontSize: 11,
                            color: AppColors.textHint)),
                    const SizedBox(width: 14),
                  ]),
                  const SizedBox(height: 5),
                  Text(voucher.title,
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(voucher.desc,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11,
                          color: AppColors.textSecondary, height: 1.4)),
                  if (voucher.minOrder != null) ...[
                    const SizedBox(height: 4),
                    Text('Min. order ${_fmt(voucher.minOrder!)}',
                        style: const TextStyle(fontSize: 11,
                            color: AppColors.textHint)),
                  ],
                ],
              ),
            ),
          ),

          // ── Tombol salin kode ──
          if (!voucher.isUsed)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: voucher.code));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Kode ${voucher.code} disalin!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                },
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: color.withOpacity(0.3)),
                    ),
                    child: Text(voucher.code,
                        style: TextStyle(fontSize: 11,
                            fontWeight: FontWeight.w700, color: color,
                            letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 4),
                  Text('Salin',
                      style: TextStyle(fontSize: 10,
                          color: color, fontWeight: FontWeight.w500)),
                ]),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Terpakai',
                    style: TextStyle(fontSize: 11,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ]),
      ),
    );
  }
}

// ── Tab referral ──
class _ReferralTab extends StatelessWidget {
  const _ReferralTab();

  static const _kodeReferral = 'JASAKU-U001';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(children: [
        // ── Banner referral ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Text('🎁', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            const Text('Ajak Teman, Dapat Bonus!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 6),
            const Text('Kamu dan temanmu masing-masing\ndapat kredit Rp25.000',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Kode referral ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(children: [
            const Text('Kode Referralmu',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_kodeReferral,
                      style: const TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 2)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          const ClipboardData(text: _kodeReferral));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Kode referral disalin!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.copy_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Bagikan ke Teman',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Cara kerja ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cara Kerja Referral',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              _StepItem(step: 1, icon: Icons.share_outlined,
                  title: 'Bagikan kode kamu',
                  desc: 'Kirim kode referral ke teman lewat WhatsApp atau media sosial'),
              _StepItem(step: 2, icon: Icons.person_add_outlined,
                  title: 'Teman daftar & order',
                  desc: 'Teman daftar menggunakan kode kamu dan menyelesaikan pesanan pertama'),
              _StepItem(step: 3, icon: Icons.account_balance_wallet_outlined,
                  title: 'Keduanya dapat bonus',
                  desc: 'Kamu dan temanmu masing-masing mendapat kredit Rp25.000', isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Status referral ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Statistik Referral',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Row(children: [
                _StatBox(label: 'Diajak', value: '1 orang', color: AppColors.primary),
                const SizedBox(width: 10),
                _StatBox(label: 'Bonus didapat', value: 'Rp25.000', color: AppColors.success),
                const SizedBox(width: 10),
                _StatBox(label: 'Saldo aktif', value: 'Rp25.000', color: AppColors.warning),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int step;
  final IconData icon;
  final String title, desc;
  final bool isLast;
  const _StepItem({required this.step, required this.icon,
      required this.title, required this.desc, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 32, height: 32,
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          child: Center(child: Text('$step',
              style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w700, color: Colors.white))),
        ),
        if (!isLast)
          Container(width: 2, height: 36, color: AppColors.border),
      ]),
      const SizedBox(width: 14),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 3),
            Text(desc, style: const TextStyle(fontSize: 12,
                color: AppColors.textSecondary, height: 1.4)),
          ]),
        ),
      ),
    ]);
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 11,
              color: AppColors.textSecondary), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
