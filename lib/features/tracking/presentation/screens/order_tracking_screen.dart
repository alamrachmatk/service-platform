import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/order_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

  static const _steps = [
    (status: OrderStatus.pending,    label: 'Menunggu Konfirmasi',
     desc: 'Pesanan diterima, menunggu mitra mengonfirmasi'),
    (status: OrderStatus.confirmed,  label: 'Dikonfirmasi',
     desc: 'Mitra telah mengonfirmasi dan menyiapkan peralatan'),
    (status: OrderStatus.onTheWay,   label: 'Mitra Dalam Perjalanan',
     desc: 'Mitra sedang menuju lokasi kamu'),
    (status: OrderStatus.inProgress, label: 'Sedang Dikerjakan',
     desc: 'Mitra sedang mengerjakan pesanan di lokasi'),
    (status: OrderStatus.completed,  label: 'Selesai',
     desc: 'Pesanan berhasil diselesaikan'),
  ];

  int get _currentStep {
    switch (order.status) {
      case OrderStatus.pending:    return 0;
      case OrderStatus.confirmed:  return 1;
      case OrderStatus.onTheWay:   return 2;
      case OrderStatus.inProgress: return 3;
      case OrderStatus.completed:  return 4;
      default:                     return 0;
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
        title: const Text('Lacak Pesanan',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // ── ID & info order ──
          _OrderIdCard(order: order),
          const SizedBox(height: 16),

          // ── Peta simulasi ──
          _MapPlaceholder(status: order.status),
          const SizedBox(height: 16),

          // ── Info mitra ──
          if (order.status == OrderStatus.onTheWay ||
              order.status == OrderStatus.inProgress)
            _MitraInfoCard(order: order),
          if (order.status == OrderStatus.onTheWay ||
              order.status == OrderStatus.inProgress)
            const SizedBox(height: 16),

          // ── Timeline progress ──
          _TimelineCard(steps: _steps, currentStep: _currentStep),
          const SizedBox(height: 16),

          // ── Detail pesanan ──
          _DetailCard(order: order),
          const SizedBox(height: 20),
        ]),
      ),

      // ── Bottom: tombol chat / selesai ──
      bottomNavigationBar: _TrackingBottomBar(order: order),
    );
  }
}

class _OrderIdCard extends StatelessWidget {
  final OrderModel order;
  const _OrderIdCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Text(order.serviceEmoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.serviceName, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(order.id, style: const TextStyle(
                fontSize: 12, color: AppColors.textHint,
                letterSpacing: 0.5)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${order.status.emoji} ${order.status.label}',
            style: const TextStyle(fontSize: 11,
                fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ),
      ]),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final OrderStatus status;
  const _MapPlaceholder({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Stack(children: [
        // Grid simulasi peta
        CustomPaint(painter: _MapGridPainter(), size: Size.infinite),

        // Label peta
        Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.person_pin_circle_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                    blurRadius: 8)],
              ),
              child: Text(
                status == OrderStatus.onTheWay
                    ? '🚗 Mitra ± 5 menit lagi'
                    : status == OrderStatus.inProgress
                    ? '🔧 Mitra di lokasi kamu'
                    : '📍 Lokasi layanan',
                style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        )),
      ]),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.08)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MitraInfoCard extends StatelessWidget {
  final OrderModel order;
  const _MitraInfoCard({required this.order});

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
          width: 44, height: 44,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight]),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(order.mitraName[0],
              style: const TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w700, color: Colors.white))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.mitraName, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
            const Text('Mitra JasaKu · Terverifikasi ✓',
                style: TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
          ],
        )),
        Row(children: [
          // Telepon
          _CircleAction(
            icon: Icons.phone_rounded,
            color: AppColors.success,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          // Chat
          _CircleAction(
            icon: Icons.chat_bubble_rounded,
            color: AppColors.primary,
            onTap: () {},
          ),
        ]),
      ]),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final List<({OrderStatus status, String label, String desc})> steps;
  final int currentStep;
  const _TimelineCard({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progress Pesanan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final isDone    = i < currentStep;
            final isCurrent = i == currentStep;
            final isLast    = i == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Garis & lingkaran
                Column(children: [
                  _StepCircle(isDone: isDone, isCurrent: isCurrent, step: i + 1),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: isDone
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                ]),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].label,
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: (isDone || isCurrent)
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                            )),
                        const SizedBox(height: 2),
                        Text(steps[i].desc,
                            style: TextStyle(
                              fontSize: 12,
                              color: isCurrent
                                  ? AppColors.textSecondary
                                  : AppColors.textHint,
                            )),
                        if (isCurrent) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Status saat ini',
                                style: TextStyle(fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final bool isDone, isCurrent;
  final int step;
  const _StepCircle({required this.isDone, required this.isCurrent,
      required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone
            ? AppColors.primary
            : isCurrent
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.background,
        border: Border.all(
          color: (isDone || isCurrent) ? AppColors.primary : AppColors.border,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: isDone
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
          : Center(child: Text('$step',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: isCurrent ? AppColors.primary : AppColors.textHint))),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final OrderModel order;
  const _DetailCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Pesanan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _DetailRow(icon: Icons.calendar_today_outlined,
              label: 'Jadwal',
              value: '${order.formattedDate} • ${order.formattedTime}'),
          _DetailRow(icon: Icons.location_on_outlined,
              label: 'Alamat', value: order.address),
          if (order.paymentMethod != null)
            _DetailRow(icon: Icons.payment_outlined,
                label: 'Pembayaran',
                value: '${order.paymentMethod} • ${order.isPaid ? 'Lunas' : 'Belum dibayar'}'),
          _DetailRow(icon: Icons.attach_money_rounded,
              label: 'Total', value: order.formattedPrice,
              valueStyle: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final TextStyle? valueStyle;
  const _DetailRow({required this.icon, required this.label,
      required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(width: 80, child: Text(label,
            style: const TextStyle(fontSize: 12,
                color: AppColors.textSecondary))),
        Expanded(child: Text(value,
            style: valueStyle ?? const TextStyle(fontSize: 13,
                color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _TrackingBottomBar extends StatelessWidget {
  final OrderModel order;
  const _TrackingBottomBar({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text('Chat Mitra',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.phone_rounded, size: 16),
            label: const Text('Hubungi',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ]),
    );
  }
}
