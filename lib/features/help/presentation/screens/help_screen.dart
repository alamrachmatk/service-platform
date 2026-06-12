import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ── Model FAQ ──
class FaqModel {
  final String question, answer, category;
  FaqModel({required this.question, required this.answer, required this.category});
}

final _faqs = [
  FaqModel(category: 'Pemesanan',
      question: 'Bagaimana cara memesan layanan?',
      answer: 'Pilih kategori layanan di beranda → pilih mitra → tambah layanan yang dibutuhkan → isi jadwal dan alamat → lakukan pembayaran. Pesanan akan dikonfirmasi mitra dalam 15 menit.'),
  FaqModel(category: 'Pemesanan',
      question: 'Apakah bisa memilih jadwal sendiri?',
      answer: 'Ya! Kamu bisa memilih tanggal dan waktu sesuai kebutuhan saat proses booking. Pilih jadwal minimal 1 hari ke depan agar mitra bisa mempersiapkan diri.'),
  FaqModel(category: 'Pemesanan',
      question: 'Bagaimana jika mitra tidak datang?',
      answer: 'Jika mitra tidak datang dalam 30 menit dari jadwal tanpa konfirmasi, kamu bisa membatalkan pesanan dan mendapat refund 100%. Hubungi CS kami jika butuh bantuan.'),
  FaqModel(category: 'Pembayaran',
      question: 'Metode pembayaran apa yang tersedia?',
      answer: 'Kami menerima QRIS, GoPay, OVO, DANA, transfer BCA, Mandiri, BNI, dan bayar di tempat (COD). Dana kamu aman — hanya diteruskan ke mitra setelah pekerjaan selesai.'),
  FaqModel(category: 'Pembayaran',
      question: 'Apakah pembayaran aman?',
      answer: 'Sistem kami menggunakan escrow — dana kamu ditahan platform dan baru diteruskan ke mitra setelah pekerjaan dikonfirmasi selesai. Jika ada masalah, dana bisa dikembalikan.'),
  FaqModel(category: 'Pembayaran',
      question: 'Berapa lama proses refund?',
      answer: 'Refund diproses dalam 1-3 hari kerja ke metode pembayaran asal. Jika belum masuk setelah 3 hari kerja, hubungi CS kami dengan menyertakan nomor pesanan.'),
  FaqModel(category: 'Mitra',
      question: 'Apakah mitra sudah terverifikasi?',
      answer: 'Ya. Semua mitra di JasaKu telah melalui proses verifikasi identitas (KTP), pengecekan portofolio, dan wawancara sebelum bergabung. Mitra berverifikasi ditandai dengan badge khusus.'),
  FaqModel(category: 'Mitra',
      question: 'Bagaimana jika hasil kerja tidak memuaskan?',
      answer: 'Jangan konfirmasi selesai jika hasil tidak memuaskan. Sampaikan keluhan via chat kepada mitra atau hubungi CS kami. Kami akan mediasi dan mencarikan solusi terbaik.'),
  FaqModel(category: 'Akun',
      question: 'Bagaimana cara mengubah nomor HP?',
      answer: 'Buka Profil → Edit Profil → ubah nomor HP → verifikasi OTP ke nomor baru. Pastikan nomor baru aktif dan bisa menerima WhatsApp.'),
  FaqModel(category: 'Akun',
      question: 'Bagaimana jika lupa akun atau tidak bisa masuk?',
      answer: 'Di halaman login, masukkan nomor HP lama kamu dan minta OTP. Jika nomor sudah tidak aktif, hubungi CS kami dengan menyertakan bukti identitas untuk pemulihan akun.'),
];

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchCtrl   = TextEditingController();
  String _searchQuery = '';
  String _activeCategory = 'Semua';
  final Set<int> _expanded = {};

  static const _categories = ['Semua', 'Pemesanan', 'Pembayaran', 'Mitra', 'Akun'];

  List<FaqModel> get _filtered {
    return _faqs.where((f) {
      final matchCat = _activeCategory == 'Semua' || f.category == _activeCategory;
      final matchQ   = _searchQuery.isEmpty ||
          f.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchQ;
    }).toList();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

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
        title: const Text('Bantuan & CS',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(children: [
        // ── Header + search ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Ada yang bisa kami bantu?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() {
                _searchQuery = v;
                _expanded.clear();
              }),
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan...',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textHint, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            size: 18, color: AppColors.textHint),
                        onPressed: () => setState(() {
                          _searchCtrl.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
                filled: true, fillColor: AppColors.background,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ]),
        ),

        // ── Kontak CS ──
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Hubungi Kami Langsung',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _ContactBtn(
                icon: Icons.chat_rounded,
                label: 'WhatsApp CS',
                sublabel: 'Respon cepat',
                color: const Color(0xFF25D366),
                onTap: () => _showContactSnack(context, 'WhatsApp CS'),
              )),
              const SizedBox(width: 10),
              Expanded(child: _ContactBtn(
                icon: Icons.email_outlined,
                label: 'Email',
                sublabel: 'cs@jasaku.id',
                color: AppColors.info,
                onTap: () => _showContactSnack(context, 'Email CS'),
              )),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(children: [
                Icon(Icons.access_time_rounded, size: 14, color: AppColors.textHint),
                SizedBox(width: 6),
                Text('Jam operasional: Senin–Minggu, 08.00–21.00 WIB',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ),
          ]),
        ),

        const SizedBox(height: 12),

        // ── Filter kategori ──
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final selected = _activeCategory == cat;
              return GestureDetector(
                onTap: () => setState(() {
                  _activeCategory = cat;
                  _expanded.clear();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(cat,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // ── FAQ list ──
        Expanded(
          child: _filtered.isEmpty
              ? const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('🔍', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 12),
                    Text('Tidak ada hasil ditemukan',
                        style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Coba kata kunci lain atau hubungi CS',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.textSecondary)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final faq = _filtered[i];
                    final isOpen = _expanded.contains(i);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isOpen
                              ? AppColors.primary.withOpacity(0.3)
                              : AppColors.border,
                          width: 0.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          childrenPadding: const EdgeInsets.fromLTRB(
                              14, 0, 14, 14),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          onExpansionChanged: (open) {
                            setState(() {
                              if (open) _expanded.add(i);
                              else _expanded.remove(i);
                            });
                          },
                          title: Text(faq.question,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isOpen
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isOpen
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              )),
                          trailing: Icon(
                            isOpen
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: isOpen
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Text(faq.answer,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.6)),
                            const SizedBox(height: 10),
                            // Badge kategori
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(faq.category,
                                  style: const TextStyle(fontSize: 10,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  void _showContactSnack(BuildContext context, String channel) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Membuka $channel...'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

// ── Tombol kontak ──
class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final Color color;
  final VoidCallback onTap;
  const _ContactBtn({required this.icon, required this.label,
      required this.sublabel, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: color)),
              Text(sublabel, style: const TextStyle(fontSize: 10,
                  color: AppColors.textSecondary)),
            ],
          )),
          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
        ]),
      ),
    );
  }
}
