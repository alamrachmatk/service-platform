import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ── Model notifikasi ──
class NotifModel {
  final String id, title, body, time;
  final NotifType type;
  bool isRead;

  NotifModel({required this.id, required this.title, required this.body,
      required this.time, required this.type, this.isRead = false});
}

enum NotifType { order, promo, system }

extension NotifTypeX on NotifType {
  String get label {
    switch (this) {
      case NotifType.order:  return 'Pesanan';
      case NotifType.promo:  return 'Promo';
      case NotifType.system: return 'Sistem';
    }
  }

  IconData get icon {
    switch (this) {
      case NotifType.order:  return Icons.receipt_long_outlined;
      case NotifType.promo:  return Icons.local_offer_outlined;
      case NotifType.system: return Icons.info_outline_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotifType.order:  return AppColors.primary;
      case NotifType.promo:  return AppColors.warning;
      case NotifType.system: return const Color(0xFF1976D2);
    }
  }
}

// ── Dummy data notifikasi ──
final _dummyNotifs = [
  NotifModel(id: '1', type: NotifType.order,
      title: 'Mitra dalam perjalanan 🚗',
      body: 'Pak Dedi Teknik sedang menuju lokasi kamu. Estimasi tiba 10 menit lagi.',
      time: '5 menit lalu'),
  NotifModel(id: '2', type: NotifType.promo,
      title: 'Promo Akhir Pekan! 🎉',
      body: 'Diskon 25% untuk semua layanan kebersihan. Berlaku Sabtu-Minggu. Gunakan kode WEEKEND25.',
      time: '1 jam lalu'),
  NotifModel(id: '3', type: NotifType.order,
      title: 'Pesanan dikonfirmasi ✅',
      body: 'Bu Sari Laundry telah mengonfirmasi pesanan cuci setrika kamu pada 9 Jun 2026, 14:00.',
      time: '2 jam lalu'),
  NotifModel(id: '4', type: NotifType.system,
      title: 'Verifikasi akun berhasil',
      body: 'Akun JasaKu kamu telah terverifikasi. Kamu bisa menikmati semua fitur platform.',
      time: '1 hari lalu', isRead: true),
  NotifModel(id: '5', type: NotifType.promo,
      title: 'Voucher ulang tahun 🎂',
      body: 'Selamat ulang tahun! Kami berikan voucher spesial Rp50.000 untuk pesanan berikutnya.',
      time: '2 hari lalu', isRead: true),
  NotifModel(id: '6', type: NotifType.order,
      title: 'Pesanan selesai 🎉',
      body: 'Tim CleanPro telah menyelesaikan pesanan bersih-bersih rumah kamu. Berikan ulasan!',
      time: '3 hari lalu', isRead: true),
  NotifModel(id: '7', type: NotifType.system,
      title: 'Pembaruan kebijakan privasi',
      body: 'Kami memperbarui kebijakan privasi per 1 Juni 2026. Silakan baca perubahan yang ada.',
      time: '5 hari lalu', isRead: true),
  NotifModel(id: '8', type: NotifType.promo,
      title: 'Ajak teman, dapat Rp25.000! 👥',
      body: 'Bagikan kode referral kamu. Setiap teman yang bergabung, kamu dapat kredit Rp25.000.',
      time: '1 minggu lalu', isRead: true),
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late List<NotifModel> _notifs;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    // Deep copy agar bisa update isRead
    _notifs = _dummyNotifs.map((n) => NotifModel(
      id: n.id, title: n.title, body: n.body,
      time: n.time, type: n.type, isRead: n.isRead,
    )).toList();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  int get _unreadCount => _notifs.where((n) => !n.isRead).length;

  List<NotifModel> _filtered(NotifType? type) =>
      type == null ? _notifs : _notifs.where((n) => n.type == type).toList();

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) { n.isRead = true; }
    });
  }

  void _markRead(String id) {
    setState(() {
      final n = _notifs.firstWhere((n) => n.id == id);
      n.isRead = true;
    });
  }

  void _delete(String id) {
    setState(() => _notifs.removeWhere((n) => n.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Notifikasi',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: AppColors.error,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('$_unreadCount',
                  style: const TextStyle(fontSize: 11, color: Colors.white,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Baca Semua',
                  style: TextStyle(fontSize: 13, color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pesanan'),
            Tab(text: 'Promo'),
            Tab(text: 'Sistem'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _NotifList(notifs: _filtered(null), onRead: _markRead, onDelete: _delete),
          _NotifList(notifs: _filtered(NotifType.order), onRead: _markRead, onDelete: _delete),
          _NotifList(notifs: _filtered(NotifType.promo), onRead: _markRead, onDelete: _delete),
          _NotifList(notifs: _filtered(NotifType.system), onRead: _markRead, onDelete: _delete),
        ],
      ),
    );
  }
}

// ── List notifikasi ──
class _NotifList extends StatelessWidget {
  final List<NotifModel> notifs;
  final void Function(String) onRead;
  final void Function(String) onDelete;

  const _NotifList({required this.notifs, required this.onRead, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (notifs.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.notifications_none_rounded, size: 52, color: AppColors.textHint),
          SizedBox(height: 12),
          Text('Tidak ada notifikasi', style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text('Notifikasi akan muncul di sini', style: TextStyle(
              fontSize: 13, color: AppColors.textSecondary)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: notifs.length,
      itemBuilder: (_, i) => _NotifCard(
        notif: notifs[i],
        onTap: () => onRead(notifs[i].id),
        onDelete: () => onDelete(notifs[i].id),
      ),
    );
  }
}

// ── Kartu notifikasi ──
class _NotifCard extends StatelessWidget {
  final NotifModel notif;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotifCard({required this.notif, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead ? Colors.white : AppColors.primary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notif.isRead ? AppColors.border : AppColors.primary.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Ikon tipe
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: notif.type.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notif.type.icon, color: notif.type.color, size: 20),
            ),
            const SizedBox(width: 12),

            // Konten
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  // Badge tipe
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: notif.type.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(notif.type.label,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                            color: notif.type.color)),
                  ),
                  const Spacer(),
                  Text(notif.time, style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
                  // Dot belum dibaca
                  if (!notif.isRead) ...[
                    const SizedBox(width: 6),
                    Container(width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle)),
                  ],
                ]),
                const SizedBox(height: 6),
                Text(notif.title,
                    style: TextStyle(fontSize: 14,
                        fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(notif.body,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary, height: 1.4)),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}
