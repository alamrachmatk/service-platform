import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/order_model.dart';
import '../../../tracking/presentation/screens/tracking_screen.dart';
import '../../../review/presentation/screens/review_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../cancellation/presentation/screens/cancellation_screen.dart';
import '../../../guarantee/presentation/screens/guarantee_claim_screen.dart';

class OrdersScreen extends StatefulWidget {
  final VoidCallback? onSwitchToHome;
  const OrdersScreen({super.key, this.onSwitchToHome});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'Semua';
  static const _filterOptions = ['Semua', 'Selesai', 'Dibatalkan'];

  List<OrderModel> get _active =>
      DummyOrders.all.where((o) => o.status.isActive).toList();

  List<OrderModel> get _done {
    var list = DummyOrders.all.where((o) => !o.status.isActive).toList();
    // Filter status
    if (_filterStatus == 'Selesai') {
      list = list.where((o) => o.status == OrderStatus.completed).toList();
    } else if (_filterStatus == 'Dibatalkan') {
      list = list.where((o) => o.status == OrderStatus.cancelled).toList();
    }
    // Filter pencarian
    if (_searchQuery.isNotEmpty) {
      list = list.where((o) =>
          o.serviceName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.mitraName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
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
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: [
            Tab(text: 'Aktif (${_active.length})'),
            Tab(text: 'Riwayat (${_done.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // ── Tab aktif ──
          _active.isEmpty
              ? _EmptyState(
                  label: 'Belum ada pesanan aktif',
                  sub: 'Yuk pesan jasa pertamamu!',
                  // ✅ Fix #2: tombol menuju beranda
                  actionLabel: 'Cari Layanan',
                  onAction: () {
                    // Kembali ke tab Beranda di MainScreen
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                )
              : _OrderList(orders: _active, isActive: true),

          // ── Tab riwayat ──
          Column(children: [
            // Search bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontSize: 14,
                    color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari layanan atau nama mitra...',
                  hintStyle: const TextStyle(fontSize: 13,
                      color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textHint, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => setState(() {
                            _searchCtrl.clear();
                            _searchQuery = '';
                          }))
                      : null,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
            ),
            // Filter chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Row(children: [
                ..._filterOptions.map((f) {
                  final sel = f == _filterStatus;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterStatus = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel
                                ? AppColors.primary : AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: Text(f, style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: sel
                                ? Colors.white : AppColors.textSecondary)),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                Text('${_done.length} pesanan',
                    style: const TextStyle(fontSize: 11,
                        color: AppColors.textSecondary)),
              ]),
            ),
            const Divider(height: 0),
            Expanded(
              child: _done.isEmpty
                  ? _EmptyState(
                      label: _searchQuery.isNotEmpty
                          ? 'Tidak ditemukan'
                          : 'Belum ada riwayat pesanan',
                      sub: _searchQuery.isNotEmpty
                          ? 'Coba kata kunci lain'
                          : 'Pesanan yang selesai akan muncul di sini',
                    )
                  : _OrderList(orders: _done, isActive: false,
                      onSwitchToHome: widget.onSwitchToHome),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ORDER LIST
// ─────────────────────────────────────────────
class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final bool isActive;
  final VoidCallback? onSwitchToHome;
  const _OrderList({required this.orders, required this.isActive,
      this.onSwitchToHome});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: orders.length,
      itemBuilder: (_, i) => _OrderCard(order: orders[i], isActive: isActive,
          onSwitchToHome: onSwitchToHome),
    );
  }
}

// ─────────────────────────────────────────────
// ORDER CARD
// ─────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isActive;
  final VoidCallback? onSwitchToHome;
  const _OrderCard({required this.order, required this.isActive,
      this.onSwitchToHome});

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            Text(order.serviceEmoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.mitraName,
                    style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(order.serviceName,
                    style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            )),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${order.status.emoji} ${order.status.label}',
                  style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600, color: _statusColor)),
            ),
          ]),
        ),

        Container(height: 0.5, color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 14)),

        // ── Info jadwal & harga ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(children: [
            _InfoChip(icon: Icons.calendar_today_outlined,
                label: order.formattedDate),
            const SizedBox(width: 12),
            _InfoChip(icon: Icons.access_time_rounded,
                label: order.formattedTime),
            const Spacer(),
            Text(order.formattedPrice,
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w700, color: AppColors.primary)),
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
                style: const TextStyle(fontSize: 12, color: AppColors.textHint))),
          ]),
        ),

        // ── Tombol aksi ──
        Container(height: 0.5, color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 14)),
        Padding(
          padding: const EdgeInsets.all(14),
          child: _ActionButtons(order: order, isActive: isActive,
              onSwitchToHome: onSwitchToHome),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final OrderModel order;
  final bool isActive;
  final VoidCallback? onSwitchToHome;
  const _ActionButtons({required this.order, required this.isActive,
      this.onSwitchToHome});

  @override
  Widget build(BuildContext context) {
    // ── Riwayat: Beri Ulasan + Pesan Lagi + Klaim Garansi + Invoice ──
    if (!isActive) {
      return Column(children: [
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ReviewScreen(order: order))),
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
              onPressed: () {
                if (onSwitchToHome != null) {
                  onSwitchToHome!();
                } else {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
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
        ]),
        const SizedBox(height: 8),
        Row(children: [
          // ── Invoice ──
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _InvoiceSheet(order: order),
              ),
              icon: const Icon(Icons.receipt_long_outlined, size: 15),
              label: const Text('Lihat Invoice',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: const BorderSide(color: AppColors.info),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // ── Klaim Garansi ──
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => GuaranteeClaimScreen(order: order))),
              icon: const Icon(Icons.verified_user_outlined, size: 15),
              label: const Text('Klaim Garansi',
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
        ]),
      ]);
    }

    // ── Aktif: Batalkan + Chat + Lacak ──
    return Column(children: [
      Row(children: [
      // ✅ Fix #1: Chat Mitra → buka ChatScreen
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ChatScreen(order: order))),
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
          onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => TrackingScreen(
                mitraName: order.mitraName,
                serviceName: order.serviceName,
                orderId: order.id,
              ))),
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
      ]),
      const SizedBox(height: 8),
      // Tombol batalkan
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => CancellationScreen(order: order))),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text('Batalkan Pesanan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// INFO CHIP
// ─────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 13, color: AppColors.textHint),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(
          fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String label, sub;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.label,
    required this.sub,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(sub, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13,
                  color: AppColors.textSecondary, height: 1.5)),
          // ✅ Fix #2: tombol aksi di empty state
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.search_rounded, size: 18),
              label: Text(actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INVOICE SHEET
// ─────────────────────────────────────────────
class _InvoiceSheet extends StatelessWidget {
  final OrderModel order;
  const _InvoiceSheet({required this.order});

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000) return 'Rp ${(p / 1000).toStringAsFixed(0)}.000';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final invoiceId = 'INV-${order.id.replaceAll('ORD-', '')}';
    final tax = order.price * 0.11;
    final subtotal = order.price - tax;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          // Header invoice
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('INVOICE', style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w800, color: AppColors.primary,
                  letterSpacing: 2)),
              Text(invoiceId, style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('LUNAS', style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: AppColors.success,
                  letterSpacing: 1)),
            ),
          ]),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Info layanan
          _InvRow(label: 'Layanan', value: order.serviceName),
          const SizedBox(height: 6),
          _InvRow(label: 'Mitra', value: order.mitraName),
          const SizedBox(height: 6),
          _InvRow(label: 'Tanggal', value: order.formattedDate),
          const SizedBox(height: 6),
          _InvRow(label: 'ID Pesanan', value: order.id,
              valueColor: AppColors.primary),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Rincian harga
          _InvRow(label: 'Subtotal', value: _fmt(subtotal)),
          const SizedBox(height: 6),
          _InvRow(label: 'Pajak (11%)', value: _fmt(tax)),
          const SizedBox(height: 6),
          _InvRow(label: 'Biaya Layanan', value: 'Rp 2.000'),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL', style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text(_fmt(order.price + 2000), style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          _InvRow(label: 'Metode Bayar', value: 'Transfer Bank'),
          const SizedBox(height: 20),

          // Catatan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Terima kasih telah menggunakan JasaKu! '
              'Invoice ini adalah bukti pembayaran yang sah.',
              style: TextStyle(fontSize: 11,
                  color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Tombol
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Invoice berhasil disalin'),
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                icon: const Icon(Icons.copy_rounded, size: 15),
                label: const Text('Salin ID',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Invoice sedang diunduh...'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                icon: const Icon(Icons.download_rounded, size: 15),
                label: const Text('Unduh PDF',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _InvRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InvRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 13,
          color: AppColors.textSecondary)),
      Text(value, style: TextStyle(fontSize: 13,
          fontWeight: FontWeight.w600,
          color: valueColor ?? AppColors.textPrimary)),
    ],
  );
}
