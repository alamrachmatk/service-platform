import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/recurring_schedule_model.dart';

class RecurringScheduleScreen extends StatefulWidget {
  const RecurringScheduleScreen({super.key});

  @override
  State<RecurringScheduleScreen> createState() => _RecurringScheduleScreenState();
}

class _RecurringScheduleScreenState extends State<RecurringScheduleScreen> {
  late List<RecurringScheduleModel> _schedules;

  @override
  void initState() {
    super.initState();
    _schedules = DummyRecurring.all;
  }

  void _togglePause(int index) {
    setState(() {
      final s = _schedules[index];
      final newStatus = s.status == RecurringStatus.active
          ? RecurringStatus.paused
          : RecurringStatus.active;
      _schedules[index] = RecurringScheduleModel(
        id: s.id, serviceId: s.serviceId, serviceName: s.serviceName,
        serviceEmoji: s.serviceEmoji, mitraName: s.mitraName,
        price: s.price, priceUnit: s.priceUnit, frequency: s.frequency,
        startDate: s.startDate, time: s.time, address: s.address,
        status: newStatus, completedCount: s.completedCount,
        nextDate: s.nextDate,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_schedules[index].status == RecurringStatus.paused
          ? 'Jadwal dijeda' : 'Jadwal diaktifkan kembali'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _cancelSchedule(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Jadwal Rutin?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Semua jadwal mendatang akan dihentikan. Pesanan yang sudah berjalan tidak terpengaruh.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error,
                foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      setState(() => _schedules.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Jadwal rutin dibatalkan'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
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
        title: const Text('Jadwal Layanan Rutin',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: _schedules.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // ── Info banner ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.repeat_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 10),
                    Expanded(child: Text(
                      'Layanan otomatis terjadwal sesuai frekuensi. Kamu bisa jeda atau batalkan kapan saja.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    )),
                  ]),
                ),
                const SizedBox(height: 16),

                ...List.generate(_schedules.length, (i) =>
                    _ScheduleCard(
                      schedule: _schedules[i],
                      onTogglePause: () => _togglePause(i),
                      onCancel: () => _cancelSchedule(i),
                    )),
              ],
            ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final RecurringScheduleModel schedule;
  final VoidCallback onTogglePause, onCancel;

  const _ScheduleCard({required this.schedule, required this.onTogglePause,
      required this.onCancel});

  Color get _statusColor {
    switch (schedule.status) {
      case RecurringStatus.active:    return AppColors.success;
      case RecurringStatus.paused:    return AppColors.warning;
      case RecurringStatus.cancelled: return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = schedule.status == RecurringStatus.paused;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            Text(schedule.serviceEmoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schedule.mitraName, style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(schedule.serviceName, style: const TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(schedule.status.label, style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w600, color: _statusColor)),
            ),
          ]),
        ),
        Container(height: 0.5, color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 14)),

        // ── Detail jadwal ──
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            _DetailRow(icon: Icons.repeat_rounded,
                label: 'Frekuensi', value: schedule.frequency.label),
            _DetailRow(icon: Icons.access_time_rounded,
                label: 'Waktu', value: schedule.time.formatted),
            _DetailRow(icon: Icons.calendar_today_outlined,
                label: 'Jadwal Berikutnya', value: schedule.formattedNextDate,
                valueColor: isPaused ? AppColors.textHint : AppColors.primary,
                strike: isPaused),
            _DetailRow(icon: Icons.location_on_outlined,
                label: 'Alamat', value: schedule.address, maxLines: 2),
            _DetailRow(icon: Icons.check_circle_outline_rounded,
                label: 'Sudah Selesai', value: '${schedule.completedCount}x'),
            _DetailRow(icon: Icons.payments_outlined,
                label: 'Harga per sesi', value: schedule.formattedPrice,
                valueColor: AppColors.primary, isBold: true),
          ]),
        ),

        // ── Tombol aksi ──
        Container(height: 0.5, color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 14)),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTogglePause,
                icon: Icon(isPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded, size: 16),
                label: Text(isPaused ? 'Aktifkan' : 'Jeda',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Batalkan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  final bool isBold, strike;
  final int maxLines;

  const _DetailRow({required this.icon, required this.label, required this.value,
      this.valueColor, this.isBold = false, this.strike = false, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(width: 110, child: Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Expanded(child: Text(value,
            maxLines: maxLines, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              decoration: strike ? TextDecoration.lineThrough : null,
            ))),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.repeat_rounded, size: 40, color: AppColors.primary)),
          const SizedBox(height: 16),
          const Text('Belum Ada Jadwal Rutin', style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text(
              'Aktifkan jadwal rutin saat memesan layanan agar tidak perlu pesan berulang setiap kali.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ]),
      ),
    );
  }
}
