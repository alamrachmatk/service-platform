import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/order_model.dart';
import '../../../tracking/presentation/screens/order_tracking_screen.dart';
import '../../../review/presentation/screens/review_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  List<OrderModel> get _active =>
      DummyOrders.all.where((o) => o.status.isActive).toList();
  List<OrderModel> get _done =>
      DummyOrders.all.where((o) => !o.status.isActive).toList();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Pesanan Saya',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14),
          tabs: [
            Tab(text: 'Aktif (${_active.length})'),
            Tab(text: 'Riwayat (${_done.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // Tab aktif
          _active.isEmpty
              ? const _EmptyState(label: 'Belum ada pesanan aktif',
                  sub: 'Pesanan yang sedang berjalan\nakan muncul di sini')
              : _OrderList(orders: _active, isActive: true),

          // Tab riwayat
          _done.isEmpty
              ? const _EmptyState(label: 'Belum ada riwayat',
                  sub: 'Pesanan yang sudah selesai\nakan muncul di sini')
              : _OrderList(orders: _done, isActive: false),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final bool isActive;
  const _OrderList({required this.orders, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: orders.length,
      itemBuilder: (_, i) => _OrderCard(order: orders[i], isActive: isActive),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isActive;
  const _OrderCard({required this.order, required this.isActive});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.pending:    return AppColors.secondary;
      case OrderStatus.confirmed:  return AppColors.primary;
      case OrderStatus.onTheWay:   return const Color(0xFF1976D2);
      case OrderStatus.inProgress: return AppColors.primary;
      case OrderStatus.completed:  return AppColors.success;
      case OrderStatus.cancelled:  return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              Text(order.serviceEmoji,
                  style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama mitra sebagai judul utama
                  Text(order.mitraName,
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  // Nama layanan sebagai subtitle
                  Text(order.serviceName,
                      style: const TextStyle(fontSize: 12,
                          color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              )),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${order.status.emoji} ${order.status.label}',
                  style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor),
                ),
              ),
            ]),
          ),

          Container(height: 0.5, color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 14)),

          // ── Info order ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(children: [
              _InfoChip(icon: Icons.calendar_today_outlined,
                  label: order.formattedDate),
              const SizedBox(width: 12),
              _InfoChip(icon: Icons.access_time_rounded,
                  label: order.formattedTime),
              const Spacer(),
              Text(order.formattedPrice,
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ]),
          ),

          // ── Alamat ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Expanded(child: Text(order.address,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.textHint))),
            ]),
          ),

          // ── Tombol aksi ──
          Container(height: 0.5, color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 14)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: _ActionButtons(order: order, isActive: isActive),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 13, color: AppColors.textHint),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12,
          color: AppColors.textSecondary)),
    ]);
  }
}

class _ActionButtons extends StatelessWidget {
  final OrderModel order;
  final bool isActive;
  const _ActionButtons({required this.order, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      // Pesanan selesai → tombol ulasan & pesan lagi
      return Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ReviewScreen(order: order))),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text('Beri Ulasan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text('Pesan Lagi',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ]);
    }

    // Pesanan aktif → tombol tracking & chat
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
          label: const Text('Chat Mitra',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => OrderTrackingScreen(order: order))),
          icon: const Icon(Icons.map_outlined, size: 14),
          label: const Text('Lacak',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    ]);
  }
}

class _EmptyState extends StatelessWidget {
  final String label, sub;
  const _EmptyState({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt_long_outlined,
              size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(fontSize: 15,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(sub, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13,
                color: AppColors.textSecondary, height: 1.5)),
      ]),
    );
  }
}
