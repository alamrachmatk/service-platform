import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/address_model.dart';
import '../../../../core/models/recurring_schedule_model.dart';
import '../../../../shared/widgets/location_picker_sheet.dart';
import '../../../payment/presentation/screens/payment_screen.dart';

// ── Enum pilihan gender mitra ──
enum MitraGender { any, male, female }

extension MitraGenderX on MitraGender {
  String get label {
    switch (this) {
      case MitraGender.any:    return 'Tidak Ada Preferensi';
      case MitraGender.male:   return 'Laki-laki';
      case MitraGender.female: return 'Perempuan';
    }
  }

  String get desc {
    switch (this) {
      case MitraGender.any:    return 'Mitra mana saja yang tersedia';
      case MitraGender.male:   return 'Khusus mitra laki-laki';
      case MitraGender.female: return 'Khusus mitra perempuan';
    }
  }

  String get emoji {
    switch (this) {
      case MitraGender.any:    return '👥';
      case MitraGender.male:   return '👨';
      case MitraGender.female: return '👩';
    }
  }
}

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

  // ── Jadwal rutin ──
  bool _isRecurring = false;
  RecurringFrequency _frequency = RecurringFrequency.weekly;

  // ── Pilih gender mitra ──
  MitraGender _preferredGender = MitraGender.any;

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

  void _openAddressPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressPickerSheet(
        onSelectSaved: (addr) => setState(() => _address = addr),
        onAddNew: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => LocationPickerSheet(
              onSelected: (addr) => setState(() => _address = addr),
            ),
          );
        },
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

    final recurringNote = _isRecurring
        ? '🔁 Jadwal Rutin: ${_frequency.label}'
        : null;
    final genderNote = _preferredGender != MitraGender.any
        ? '${_preferredGender.emoji} Preferensi Mitra: ${_preferredGender.label}'
        : null;
    final combinedNotes = [
      if (recurringNote != null) recurringNote,
      if (genderNote != null) genderNote,
      if (_notesCtrl.text.trim().isNotEmpty) _notesCtrl.text.trim(),
    ].join('\n');

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
      notes: combinedNotes.isEmpty ? null : combinedNotes,
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
                    // ── Quick action: Pesan Hari Ini ──
                    if (s.isAvailableToday) ...[
                      GestureDetector(
                        onTap: () {
                          final now = DateTime.now();
                          setState(() {
                            _date = DateTime(now.year, now.month, now.day);
                            _time = TimeOfDay(
                                hour: now.hour + 1, minute: 0);
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.warning.withOpacity(0.4)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.bolt_rounded,
                                color: AppColors.warning, size: 18),
                            const SizedBox(width: 8),
                            const Expanded(child: Text(
                              'Mitra ini tersedia hari ini juga!',
                              style: TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning),
                            )),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Pesan Sekarang',
                                  style: TextStyle(fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ]),
                        ),
                      ),
                    ],
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
                          initialDate: s.isAvailableToday
                              ? DateTime.now()
                              : DateTime.now().add(const Duration(days: 1)),
                          firstDate: s.isAvailableToday
                              ? DateTime.now()
                              : DateTime.now().add(const Duration(days: 1)),
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
                          onTap: _openAddressPicker,
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
                              Text('Pilih atau tambah alamat',
                                  style: TextStyle(fontSize: 14,
                                      color: AppColors.textHint)),
                              Spacer(),
                              Icon(Icons.chevron_right_rounded,
                                  size: 18, color: AppColors.textHint),
                            ]),
                          ),
                        )
                      : GestureDetector(
                          onTap: _openAddressPicker,
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

                // ── Jadwal rutin ──
                _RecurringCard(
                  isRecurring: _isRecurring,
                  frequency: _frequency,
                  onToggle: (v) => setState(() => _isRecurring = v),
                  onFrequencyChange: (f) => setState(() => _frequency = f),
                ),
                const SizedBox(height: 14),

                // ── Pilih gender mitra ──
                _GenderCard(
                  selected: _preferredGender,
                  onChanged: (g) => setState(() => _preferredGender = g),
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

// ─────────────────────────────────────────────
// BOTTOM SHEET PILIH ALAMAT
// ─────────────────────────────────────────────
class _AddressPickerSheet extends StatelessWidget {
  final void Function(AddressModel) onSelectSaved;
  final VoidCallback onAddNew;

  const _AddressPickerSheet({
    required this.onSelectSaved,
    required this.onAddNew,
  });

  // Alamat tersimpan dummy — nanti dari database/state
  static final _saved = [
    _SavedAddress(
      label: 'Rumah',
      icon: Icons.home_outlined,
      detail: 'Jl. Merdeka No. 10, RT 02/03',
      area: 'Bogor Tengah, Kota Bogor, Jawa Barat',
      isPrimary: true,
      address: AddressModel(
        province: 'Jawa Barat',
        city: 'Kota Bogor',
        district: 'Bogor Tengah',
        village: 'Cibogor',
        detail: 'Jl. Merdeka No. 10, RT 02/03',
      ),
    ),
    _SavedAddress(
      label: 'Kantor',
      icon: Icons.business_outlined,
      detail: 'Jl. Sudirman No. 45, Lt. 3',
      area: 'Bogor Selatan, Kota Bogor, Jawa Barat',
      isPrimary: false,
      address: AddressModel(
        province: 'Jawa Barat',
        city: 'Kota Bogor',
        district: 'Bogor Selatan',
        village: 'Empang',
        detail: 'Jl. Sudirman No. 45, Lt. 3',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
          width: 40, height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(children: [
            Text('Pilih Alamat Kunjungan',
                style: TextStyle(fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
        ),
        const Divider(height: 0),

        // ── Alamat tersimpan ──
        if (_saved.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(children: [
              Icon(Icons.bookmark_outline_rounded,
                  size: 15, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text('Alamat Tersimpan',
                  style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ]),
          ),
          ..._saved.map((s) => GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onSelectSaved(s.address);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: s.isPrimary
                    ? AppColors.primary.withOpacity(0.04)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: s.isPrimary
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.border,
                  width: s.isPrimary ? 1.5 : 0.5,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s.icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(s.label, style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                      if (s.isPrimary) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Utama',
                              style: TextStyle(fontSize: 9,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 2),
                    Text(s.detail, style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                    Text(s.area, style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint)),
                  ],
                )),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint, size: 18),
              ]),
            ),
          )),
          const Divider(height: 20, indent: 16, endIndent: 16),
        ],

        // ── Tambah alamat baru ──
        GestureDetector(
          onTap: onAddNew,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_location_alt_outlined,
                    color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('Tambah Alamat Baru',
                    style: TextStyle(fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _SavedAddress {
  final String label, detail, area;
  final IconData icon;
  final bool isPrimary;
  final AddressModel address;

  const _SavedAddress({
    required this.label, required this.detail, required this.area,
    required this.icon, required this.isPrimary, required this.address,
  });
}

// ─────────────────────────────────────────────
// CARD JADWAL RUTIN
// ─────────────────────────────────────────────
class _RecurringCard extends StatelessWidget {
  final bool isRecurring;
  final RecurringFrequency frequency;
  final void Function(bool) onToggle;
  final void Function(RecurringFrequency) onFrequencyChange;

  const _RecurringCard({
    required this.isRecurring,
    required this.frequency,
    required this.onToggle,
    required this.onFrequencyChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRecurring
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.border,
          width: isRecurring ? 1.5 : 0.5,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.repeat_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jadikan Jadwal Rutin',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const Text('Layanan otomatis terjadwal berulang',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          )),
          Switch(
            value: isRecurring,
            onChanged: onToggle,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ]),

        if (isRecurring) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          const Text('Pilih Frekuensi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ...RecurringFrequency.values.map((f) {
            final selected = frequency == f;
            return GestureDetector(
              onTap: () => onFrequencyChange(f),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withOpacity(0.06)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 1.5 : 0.5,
                  ),
                ),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 5 : 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.label, style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: selected ? AppColors.primary : AppColors.textPrimary)),
                      Text(f.desc, style: const TextStyle(
                          fontSize: 11, color: AppColors.textHint)),
                    ],
                  )),
                ]),
              ),
            );
          }),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, size: 13, color: AppColors.warning),
              SizedBox(width: 6),
              Expanded(child: Text(
                'Kamu bisa jeda atau batalkan jadwal kapan saja dari menu Profil',
                style: TextStyle(fontSize: 11, color: AppColors.warning),
              )),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// CARD PILIH GENDER MITRA
// ─────────────────────────────────────────────
class _GenderCard extends StatelessWidget {
  final MitraGender selected;
  final void Function(MitraGender) onChanged;

  const _GenderCard({required this.selected, required this.onChanged});

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
        // Header
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_search_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preferensi Gender Mitra',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text('Opsional — sesuai kenyamanan kamu',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          )),
        ]),
        const SizedBox(height: 14),

        // Pilihan gender — 3 tombol horizontal
        Row(children: MitraGender.values.map((g) {
          final isSelected = selected == g;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  right: g != MitraGender.female ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.08)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(g.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 5),
                  Text(g.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      )),
                ]),
              ),
            ),
          );
        }).toList()),
        const SizedBox(height: 10),

        // Info ketersediaan
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: selected == MitraGender.any
              ? const SizedBox.shrink()
              : Container(
                  key: ValueKey(selected),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.info.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'Kami akan mencarikan mitra ${selected.label.toLowerCase()} '
                      'yang tersedia. Waktu tunggu mungkin sedikit lebih lama.',
                      style: const TextStyle(fontSize: 11,
                          color: AppColors.info, height: 1.4),
                    )),
                  ]),
                ),
        ),
      ]),
    );
  }
}
