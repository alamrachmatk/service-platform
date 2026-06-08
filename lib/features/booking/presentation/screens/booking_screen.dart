import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/address_model.dart';
import '../../../../shared/widgets/location_picker_sheet.dart';
import '../../../payment/presentation/screens/payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final ServiceModel service;
  final List<SelectedItem> selectedItems;
  final double totalPrice;

  const BookingScreen({
    super.key,
    required this.service,
    this.selectedItems = const [],
    this.totalPrice = 0,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _notesCtrl    = TextEditingController();
  DateTime?     _date;
  TimeOfDay?    _time;
  AddressModel? _address;
  bool _loading = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  ServiceModel get s => widget.service;

  double get _adminFee => 2000;
  double get _total    => widget.totalPrice + _adminFee;

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000)    return 'Rp ${(p / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  bool get _isValid =>
      _date != null && _time != null && _address != null;

  void _openLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationPickerSheet(
        onSelected: (addr) => setState(() => _address = addr),
      ),
    );
  }

  Future<void> _proceed() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lengkapi jadwal dan alamat terlebih dahulu'),
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
      priceUnit: 'layanan',
      scheduledAt: scheduled,
      address: _address!.fullAddress,
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 100 + bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                _ManualAppBar(onBack: () => Navigator.pop(context)),
                const SizedBox(height: 16),

                // ── Ringkasan mitra ──
                _MitraSummary(service: s),
                const SizedBox(height: 14),

                // ── Layanan yang dipilih ──
                if (widget.selectedItems.isNotEmpty) ...[
                  _SelectedItemsCard(items: widget.selectedItems, fmt: _fmt),
                  const SizedBox(height: 14),
                ],

                // ── Pilih jadwal ──
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
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (d != null) setState(() => _date = d);
                      },
                    ),
                    const SizedBox(height: 8),
                    _PickerRow(
                      icon: Icons.access_time_rounded,
                      label: 'Waktu kunjungan',
                      value: _time == null ? 'Pilih waktu' : _time!.format(context),
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

                // ── Pilih alamat ──
                _SectionCard(
                  title: 'Alamat Kunjungan',
                  icon: Icons.location_on_outlined,
                  child: _address == null
                      ? GestureDetector(
                          onTap: _openLocationPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Row(children: [
                              Icon(Icons.add_location_alt_outlined,
                                  size: 18, color: AppColors.primary),
                              SizedBox(width: 10),
                              Text('Pilih alamat (Provinsi → Kelurahan)',
                                  style: TextStyle(fontSize: 14,
                                      color: AppColors.textHint)),
                              Spacer(),
                              Icon(Icons.chevron_right_rounded,
                                  size: 18, color: AppColors.textHint),
                            ]),
                          ),
                        )
                      : GestureDetector(
                          onTap: _openLocationPicker,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(Icons.location_on_rounded,
                                      size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  const Text('Alamat terpilih',
                                      style: TextStyle(fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  const Text('Ubah',
                                      style: TextStyle(fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline)),
                                ]),
                                const SizedBox(height: 8),
                                _AddressLine(
                                    icon: Icons.location_city_outlined,
                                    text: '${_address!.province} · ${_address!.city}'),
                                _AddressLine(
                                    icon: Icons.holiday_village_outlined,
                                    text: '${_address!.district} · ${_address!.village}'),
                                _AddressLine(
                                    icon: Icons.home_outlined,
                                    text: _address!.detail),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 14),

                // ── Catatan ──
                _SectionCard(
                  title: 'Catatan untuk Mitra',
                  icon: Icons.sticky_note_2_outlined,
                  child: TextField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14,
                        color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Contoh: AC di kamar utama, susah dingin...',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: AppColors.textHint),
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
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Ringkasan biaya ──
                _PriceSummaryCard(
                  items: widget.selectedItems,
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
// WIDGETS
// ─────────────────────────────────────────────

class _ManualAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _ManualAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      GestureDetector(
        onTap: onBack,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 0.5)),
          child: const Icon(Icons.arrow_back_ios_rounded,
              size: 16, color: AppColors.textPrimary),
        ),
      ),
      const Expanded(child: Text('Detail Pemesanan',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary))),
      const SizedBox(width: 36),
    ]);
  }
}

class _MitraSummary extends StatelessWidget {
  final ServiceModel service;
  const _MitraSummary({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(service.emoji,
              style: const TextStyle(fontSize: 24)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.mitra, style: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(service.category, style: const TextStyle(fontSize: 12,
                color: AppColors.textSecondary)),
          ])),
        if (service.isVerified)
          const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
      ]),
    );
  }
}

class _SelectedItemsCard extends StatelessWidget {
  final List<SelectedItem> items;
  final String Function(double) fmt;
  const _SelectedItemsCard({required this.items, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Layanan Dipilih', style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...items.map((sel) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Container(width: 6, height: 6,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sel.item.name, style: const TextStyle(
                    fontSize: 13, color: AppColors.textPrimary)),
                Text(sel.subService.name, style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
              ],
            )),
            Text('x${sel.qty}  ${fmt(sel.item.price * sel.qty)}',
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
        )),
      ]),
    );
  }
}

class _AddressLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AddressLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(
            fontSize: 13, color: AppColors.textPrimary))),
      ]),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isEmpty;
  final VoidCallback onTap;
  const _PickerRow({required this.icon, required this.label,
      required this.value, required this.isEmpty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              Text(value, style: TextStyle(fontSize: 14,
                  fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                  color: isEmpty ? AppColors.textHint : AppColors.textPrimary)),
            ])),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint),
        ]),
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  final List<SelectedItem> items;
  final double adminFee, total;
  final String Function(double) fmt;
  const _PriceSummaryCard({required this.items, required this.adminFee,
      required this.total, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ringkasan Biaya', style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...items.map((sel) => _Row(
          label: '${sel.item.name} x${sel.qty}',
          value: fmt(sel.item.price * sel.qty),
        )),
        _Row(label: 'Biaya layanan', value: fmt(adminFee)),
        const Divider(height: 20),
        _Row(label: 'Total', value: fmt(total),
            isBold: true, valueColor: AppColors.primary),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;
  const _Row({required this.label, required this.value,
      this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 13,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400))),
        Text(value, style: TextStyle(fontSize: 13,
            color: valueColor ?? (isBold ? AppColors.textPrimary : AppColors.textSecondary),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
      ]),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String totalStr;
  final bool isValid, loading;
  final VoidCallback onPressed;
  final double bottomPadding;
  const _BottomBar({required this.totalStr, required this.isValid,
      required this.loading, required this.onPressed, required this.bottomPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPadding),
      decoration: const BoxDecoration(color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total pembayaran',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(totalStr, style: const TextStyle(fontSize: 18,
              fontWeight: FontWeight.w700, color: AppColors.primary)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Lanjut ke Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ]),
    );
  }
}
