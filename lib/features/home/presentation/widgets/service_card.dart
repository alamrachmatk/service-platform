import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';

// ── Kartu layanan di list ──
class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBookingSheet(context, service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          // Ikon kategori
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(service.emoji,
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),

          // Info layanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(service.mitra,
                    style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.secondary, size: 14),
                  const SizedBox(width: 3),
                  Text('${service.rating} (${service.reviewCount})',
                      style: const TextStyle(fontSize: 12,
                          color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on_outlined,
                      color: AppColors.textHint, size: 12),
                  Text(' ${service.distanceKm} km',
                      style: const TextStyle(fontSize: 12,
                          color: AppColors.textHint)),
                ]),
              ],
            ),
          ),

          // Harga
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(service.formattedPrice,
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            Text('/${service.priceUnit}',
                style: const TextStyle(fontSize: 11,
                    color: AppColors.textHint)),
          ]),
        ]),
      ),
    );
  }
}

// ── Bottom sheet booking ──
void _showBookingSheet(BuildContext context, ServiceModel service) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BookingSheet(service: service),
  );
}

class _BookingSheet extends StatefulWidget {
  final ServiceModel service;
  const _BookingSheet({required this.service});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  final _addressCtrl = TextEditingController();
  DateTime?  _date;
  TimeOfDay? _time;
  bool _loading = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _book() async {
    if (_date == null || _time == null || _addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lengkapi tanggal, waktu, dan alamat'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✅ Pesanan ${widget.service.name} berhasil dibuat!'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Info layanan
            _ServiceInfo(service: s),
            const SizedBox(height: 16),

            // Form booking
            _BookingForm(
              addressCtrl: _addressCtrl,
              date: _date,
              time: _time,
              onPickDate: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (d != null) setState(() => _date = d);
              },
              onPickTime: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 9, minute: 0),
                );
                if (t != null) setState(() => _time = t);
              },
            ),
            const SizedBox(height: 24),

            // Tombol konfirmasi
            SizedBox(
              height: 52, width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _book,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Konfirmasi & Pesan',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ServiceInfo extends StatelessWidget {
  final ServiceModel service;
  const _ServiceInfo({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(service.emoji,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service.name,
                  style: const TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w700)),
              Text(service.mitra,
                  style: const TextStyle(fontSize: 13,
                      color: AppColors.textSecondary)),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(service.formattedPrice,
                style: const TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            Text('/${service.priceUnit}',
                style: const TextStyle(fontSize: 11,
                    color: AppColors.textHint)),
          ]),
        ]),
        const Divider(height: 20),
        Text(service.description,
            style: const TextStyle(fontSize: 13,
                color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.star_rounded,
              color: AppColors.secondary, size: 15),
          Text(' ${service.rating} (${service.reviewCount} ulasan)',
              style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

class _BookingForm extends StatelessWidget {
  final TextEditingController addressCtrl;
  final DateTime? date;
  final TimeOfDay? time;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const _BookingForm({
    required this.addressCtrl,
    required this.date,
    required this.time,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Detail Pemesanan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),

        // Pilih tanggal
        GestureDetector(
          onTap: onPickDate,
          child: _PickerRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal',
            value: date == null
                ? 'Pilih tanggal'
                : '${date!.day}/${date!.month}/${date!.year}',
            isEmpty: date == null,
          ),
        ),
        const SizedBox(height: 12),

        // Pilih waktu
        GestureDetector(
          onTap: onPickTime,
          child: _PickerRow(
            icon: Icons.access_time_rounded,
            label: 'Waktu',
            value: time == null ? 'Pilih waktu' : time!.format(context),
            isEmpty: time == null,
          ),
        ),
        const SizedBox(height: 12),

        // Alamat
        const Text('Alamat Lengkap',
            style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: addressCtrl,
          maxLines: 3,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Contoh: Jl. Merdeka No. 10, RT 02, Bogor...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.background,
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
      ]),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isEmpty;

  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(value,
              style: TextStyle(fontSize: 14,
                  color: isEmpty ? AppColors.textHint : AppColors.textPrimary)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.textHint),
        ]),
      ),
    ]);
  }
}
