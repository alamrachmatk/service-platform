import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../../core/models/order_model.dart';
import '../../../payment/presentation/screens/payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final ServiceModel service;
  final List<SubService> selectedSubs;
  final double totalPrice;

  const BookingScreen({
    super.key,
    required this.service,
    this.selectedSubs = const [],
    this.totalPrice = 0,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _addressCtrl  = TextEditingController();
  final _notesCtrl    = TextEditingController();
  final _remarkCtrl   = TextEditingController();
  DateTime?  _date;
  TimeOfDay? _time;
  int  _quantity = 1;
  bool _loading  = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  ServiceModel get s => widget.service;

  bool get _showQty =>
      !['sesi', 'unit', 'titik', 'kunjungan'].contains(s.priceUnit);

  double get _subtotal  => widget.totalPrice > 0
      ? widget.totalPrice
      : s.price * _quantity;
  double get _adminFee  => 2000;
  double get _total     => _subtotal + _adminFee;

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000)    return 'Rp ${(p / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  bool get _isValid =>
      _date != null && _time != null && _addressCtrl.text.trim().isNotEmpty;

  Future<void> _proceed() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lengkapi tanggal, waktu, dan alamat'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _loading = false);
    if (!mounted) return;

    final scheduled = DateTime(
      _date!.year, _date!.month, _date!.day,
      _time!.hour, _time!.minute,
    );

    final order = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      serviceId: s.id,
      serviceName: s.name,
      serviceEmoji: s.emoji,
      mitraName: s.mitra,
      mitraPhone: '081234567890',
      price: _total,
      priceUnit: s.priceUnit,
      scheduledAt: scheduled,
      address: _addressCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    Navigator.push(context,
        MaterialPageRoute(builder: (_) => PaymentScreen(order: order)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── Gunakan Stack agar bottom bar tidak collapse konten ──
      body: Stack(
        children: [
          // ── Konten scrollable ──
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 100 + bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Safe area + app bar manual
                SizedBox(height: MediaQuery.of(context).padding.top),
                _ManualAppBar(onBack: () => Navigator.pop(context)),
                const SizedBox(height: 16),

                // ── Ringkasan layanan ──
                _ServiceSummary(service: s),
                const SizedBox(height: 14),

                // ── Kuantitas ──
                if (_showQty) ...[
                  _QuantityCard(
                    priceUnit: s.priceUnit,
                    quantity: _quantity,
                    onDecrease: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                    onIncrease: () => setState(() => _quantity++),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Jadwal ──
                _SectionCard(
                  title: 'Pilih Jadwal',
                  icon: Icons.calendar_today_outlined,
                  child: Column(children: [
                    _PickerRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Tanggal kunjungan',
                      value: _date == null
                          ? 'Pilih tanggal'
                          : '${_date!.day}/${_date!.month}/${_date!.year}',
                      isEmpty: _date == null,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                              const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                              const Duration(days: 30)),
                        );
                        if (d != null) setState(() => _date = d);
                      },
                    ),
                    const SizedBox(height: 8),
                    _PickerRow(
                      icon: Icons.access_time_rounded,
                      label: 'Waktu kunjungan',
                      value: _time == null
                          ? 'Pilih waktu'
                          : _time!.format(context),
                      isEmpty: _time == null,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (t != null) setState(() => _time = t);
                      },
                    ),
                  ]),
                ),
                const SizedBox(height: 14),

                // ── Alamat ──
                _SectionCard(
                  title: 'Alamat Lengkap',
                  icon: Icons.location_on_outlined,
                  child: Column(children: [
                    _MultilineField(
                      controller: _addressCtrl,
                      hint: 'Contoh: Jl. Merdeka No.10, RT 02/03, Bogor Tengah...',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    _SingleLineField(
                      controller: _remarkCtrl,
                      hint: 'Patokan / catatan alamat (opsional)',
                      icon: Icons.info_outline_rounded,
                    ),
                  ]),
                ),
                const SizedBox(height: 14),

                // ── Catatan ──
                _SectionCard(
                  title: 'Catatan untuk Mitra',
                  icon: Icons.sticky_note_2_outlined,
                  child: _MultilineField(
                    controller: _notesCtrl,
                    hint: 'Contoh: AC di kamar utama, susah dingin...',
                  ),
                ),
                const SizedBox(height: 14),

                // ── Ringkasan biaya ──
                _PriceSummary(
                  service: s,
                  selectedSubs: widget.selectedSubs,
                  quantity: _quantity,
                  showQty: _showQty,
                  subtotal: _subtotal,
                  adminFee: _adminFee,
                  total: _total,
                  fmt: _fmt,
                ),
              ],
            ),
          ),

          // ── Fixed bottom bar ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomBar(
              totalStr: _fmt(_total),
              isValid: _isValid,
              loading: _loading,
              onPressed: _proceed,
              bottomPadding: bottomPadding,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MANUAL APP BAR (bukan AppBar widget)
// ─────────────────────────────────────────────
class _ManualAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _ManualAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded,
                size: 16, color: AppColors.textPrimary),
          ),
        ),
        const Expanded(
          child: Text('Detail Pemesanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
        const SizedBox(width: 36), // balancer
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SERVICE SUMMARY
// ─────────────────────────────────────────────
class _ServiceSummary extends StatelessWidget {
  final ServiceModel service;
  const _ServiceSummary({required this.service});

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
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(service.emoji,
              style: const TextStyle(fontSize: 26))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.name, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(service.mitra, style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(service.formattedPrice, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.primary)),
          Text('/${service.priceUnit}', style: const TextStyle(
              fontSize: 11, color: AppColors.textHint)),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// QUANTITY CARD
// ─────────────────────────────────────────────
class _QuantityCard extends StatelessWidget {
  final String priceUnit;
  final int quantity;
  final VoidCallback onDecrease, onIncrease;
  const _QuantityCard({
    required this.priceUnit,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

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
        const Icon(Icons.straighten_rounded,
            color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text('Jumlah ($priceUnit)',
            style: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500))),
        _QtyBtn(icon: Icons.remove_rounded,
            onTap: onDecrease, enabled: quantity > 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$quantity', style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
        ),
        _QtyBtn(icon: Icons.add_rounded, onTap: onIncrease, enabled: true),
      ]),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _QtyBtn({required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18,
            color: enabled ? AppColors.primary : AppColors.textHint),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION CARD
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

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
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// PICKER ROW
// ─────────────────────────────────────────────
class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isEmpty;
  final VoidCallback onTap;
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isEmpty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(
                  fontSize: 11, color: AppColors.textHint)),
              Text(value, style: TextStyle(
                  fontSize: 14,
                  fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                  color: isEmpty
                      ? AppColors.textHint
                      : AppColors.textPrimary)),
            ],
          )),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.textHint),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TEXT FIELDS
// ─────────────────────────────────────────────
class _MultilineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final void Function(String)? onChanged;
  const _MultilineField({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}

class _SingleLineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  const _SingleLineField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textHint),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 13),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRICE SUMMARY
// ─────────────────────────────────────────────
class _PriceSummary extends StatelessWidget {
  final ServiceModel service;
  final List<SubService> selectedSubs;
  final int quantity;
  final bool showQty;
  final double subtotal, adminFee, total;
  final String Function(double) fmt;

  const _PriceSummary({
    required this.service,
    required this.selectedSubs,
    required this.quantity,
    required this.showQty,
    required this.subtotal,
    required this.adminFee,
    required this.total,
    required this.fmt,
  });

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
        const Text('Ringkasan Biaya',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        // Tampilkan per sub-layanan jika ada
        if (selectedSubs.isNotEmpty) ...[
          ...selectedSubs.map((sub) => _PriceRow(
                label: sub.name,
                value: sub.price == 0 ? 'Gratis' : fmt(sub.price),
              )),
        ] else ...[
          _PriceRow(
            label: showQty
                ? '${service.name} x$quantity ${service.priceUnit}'
                : service.name,
            value: fmt(subtotal),
          ),
        ],
        _PriceRow(label: 'Biaya layanan', value: fmt(adminFee)),
        const Divider(height: 20),
        _PriceRow(
          label: 'Total',
          value: fmt(total),
          isBold: true,
          valueColor: AppColors.primary,
        ),
      ]),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(
              fontSize: 13,
              color: isBold
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400))),
          Text(value, style: TextStyle(
              fontSize: 13,
              color: valueColor ??
                  (isBold
                      ? AppColors.textPrimary
                      : AppColors.textSecondary),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM BAR
// ─────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final String totalStr;
  final bool isValid, loading;
  final VoidCallback onPressed;
  final double bottomPadding;

  const _BottomBar({
    required this.totalStr,
    required this.isValid,
    required this.loading,
    required this.onPressed,
    required this.bottomPadding,
  });

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
          const Text('Total pembayaran',
              style: TextStyle(fontSize: 12,
                  color: AppColors.textSecondary)),
          Text(totalStr, style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary)),
        ]),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: (isValid && !loading) ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.border,
              disabledForegroundColor: AppColors.textHint,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Lanjut ke Pembayaran',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ]),
    );
  }
}
