import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';

// ── Model pesan ──
class _ChatMsg {
  final String text, time;
  final bool isMe;
  const _ChatMsg({required this.text, required this.isMe, required this.time});
}

class PreOrderChatScreen extends StatefulWidget {
  final ServiceModel service;
  const PreOrderChatScreen({super.key, required this.service});

  @override
  State<PreOrderChatScreen> createState() => _PreOrderChatScreenState();
}

class _PreOrderChatScreenState extends State<PreOrderChatScreen> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMsg> _messages = [];
  bool _mitraTyping = false;
  bool _chatStarted = false;

  @override
  void initState() {
    super.initState();
    // Pesan sambutan otomatis dari mitra
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _mitraTyping = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _mitraTyping = false;
          _messages.add(_ChatMsg(
            text: 'Halo! Saya ${widget.service.mitra} 👋\n'
                'Ada yang bisa saya bantu terkait layanan '
                '${widget.service.name}?',
            isMe: false,
            time: _timeNow(),
          ));
          _chatStarted = true;
        });
        _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _timeNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _send([String? text]) {
    final msg = (text ?? _msgCtrl.text).trim();
    if (msg.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg(text: msg, isMe: true, time: _timeNow()));
      _msgCtrl.clear();
    });
    _scrollToBottom();

    // Simulasi mitra mengetik dan membalas
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _mitraTyping = true);
      _scrollToBottom();

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _mitraTyping = false;
          _messages.add(_ChatMsg(
            text: _autoReply(msg),
            isMe: false,
            time: _timeNow(),
          ));
        });
        _scrollToBottom();
      });
    });
  }

  String _autoReply(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('harga') || lower.contains('biaya') || lower.contains('tarif')) {
      final items = widget.service.subServices.isNotEmpty &&
          widget.service.subServices.first.items.isNotEmpty
          ? widget.service.subServices.first.items
          : null;
      if (items != null) {
        final minPrice = items.map((i) => i.price).reduce((a, b) => a < b ? a : b);
        final fmtMin = minPrice >= 1000
            ? 'Rp ${(minPrice / 1000).toStringAsFixed(0)}rb'
            : 'Rp ${minPrice.toStringAsFixed(0)}';
        return 'Untuk harga, dimulai dari $fmtMin tergantung jenis layanan yang kamu butuhkan. '
            'Kamu bisa lihat detail harga lengkapnya di halaman layanan ini ya 😊';
      }
      return 'Harga kami kompetitif dan transparan. Silakan cek detail di halaman layanan.';
    }
    if (lower.contains('tersedia') || lower.contains('available') ||
        lower.contains('hari ini') || lower.contains('kapan')) {
      if (widget.service.isAvailableToday) {
        return 'Saya tersedia hari ini! ⚡ Kamu bisa langsung pesan dan saya '
            'siap datang dalam 1-2 jam ke depan.';
      }
      return 'Untuk hari ini jadwal saya sudah penuh, tapi tersedia mulai besok. '
          'Silakan pilih tanggal saat booking ya 😊';
    }
    if (lower.contains('pengalaman') || lower.contains('lama') || lower.contains('berapa tahun')) {
      return 'Saya sudah berpengalaman lebih dari 5 tahun di bidang ini. '
          'Sudah menangani ratusan pelanggan dengan rating ${widget.service.rating} ⭐';
    }
    if (lower.contains('garansi') || lower.contains('jaminan')) {
      return 'Tentu ada garansi! Jika hasil tidak memuaskan, saya siap '
          'kembali untuk memperbaiki tanpa biaya tambahan. '
          'JasaKu juga punya Jaminan Kepuasan Pelanggan 🛡️';
    }
    if (lower.contains('bayar') || lower.contains('pembayaran') || lower.contains('transfer')) {
      return 'Pembayaran melalui platform JasaKu ya — bisa QRIS, GoPay, OVO, DANA, '
          'atau transfer bank. Dana aman dengan sistem escrow 🔐';
    }
    if (lower.contains('lokasi') || lower.contains('area') || lower.contains('jangkauan')) {
      return 'Saya melayani area ${widget.service.distanceKm} km dari lokasi kamu saat ini. '
          'Bisa dikonfirmasi saat kamu input alamat di form pemesanan 📍';
    }
    if (lower.contains('terima kasih') || lower.contains('makasih') || lower.contains('ok')) {
      return 'Sama-sama! Jangan ragu bertanya lagi ya. '
          'Klik tombol "Pilih Layanan" jika siap pesan 😊';
    }
    return 'Baik, terima kasih pertanyaannya! '
        'Ada yang lain yang ingin kamu tanyakan sebelum memesan?';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          // Avatar mitra
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight]),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(
              widget.service.emoji,
              style: const TextStyle(fontSize: 18),
            )),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.service.mitra,
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Row(children: [
                Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text('Online • Konsultasi Pra-Order',
                    style: TextStyle(fontSize: 11,
                        color: AppColors.textSecondary)),
              ]),
            ],
          )),
        ]),
        actions: [
          // Info konsultasi gratis
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('GRATIS',
                style: TextStyle(fontSize: 11, color: AppColors.success,
                    fontWeight: FontWeight.w700)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(children: [
        // ── Banner info layanan ──
        _ServiceBanner(service: widget.service),

        // ── Area pesan ──
        Expanded(
          child: _messages.isEmpty && !_mitraTyping
              ? _WelcomeView(service: widget.service, onTap: () {})
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: _messages.length + (_mitraTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_mitraTyping && i == _messages.length) {
                      return _TypingBubble(name: widget.service.mitra);
                    }
                    return _MessageBubble(msg: _messages[i]);
                  },
                ),
        ),

        // ── Quick questions ──
        if (_chatStarted || _mitraTyping)
          _QuickQuestions(
            service: widget.service,
            onSelect: _send,
          ),

        // ── Input chat ──
        _ChatInput(
          controller: _msgCtrl,
          onSend: () => _send(),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET HELPERS
// ─────────────────────────────────────────────

class _ServiceBanner extends StatelessWidget {
  final ServiceModel service;
  const _ServiceBanner({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(children: [
        Text(service.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.name, style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.secondary, size: 12),
              Text(' ${service.rating} · ${service.reviewCount} ulasan',
                  style: const TextStyle(fontSize: 11,
                      color: AppColors.textSecondary)),
            ]),
          ],
        )),
        const Icon(Icons.info_outline_rounded,
            color: AppColors.textHint, size: 16),
      ]),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;
  const _WelcomeView({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(service.emoji,
                style: const TextStyle(fontSize: 34))),
          ),
          const SizedBox(height: 16),
          Text(service.mitra, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text(
            'Tanyakan apapun sebelum memesan.\nKonsultasi gratis, tanpa komitmen.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13,
                color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
          const _LoadingDots(),
        ]),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: const Text('Menghubungkan ke mitra...',
          style: TextStyle(fontSize: 12, color: AppColors.textHint)),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment: msg.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                  bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                ),
                border: msg.isMe
                    ? null
                    : Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(msg.text,
                  style: TextStyle(
                    fontSize: 14, height: 1.4,
                    color: msg.isMe ? Colors.white : AppColors.textPrimary,
                  )),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg.time, style: const TextStyle(
                    fontSize: 10, color: AppColors.textHint)),
                if (msg.isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all_rounded,
                      size: 14, color: AppColors.primary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  final String name;
  const _TypingBubble({required this.name});
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('${widget.name} sedang mengetik',
              style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic)),
          const SizedBox(width: 6),
          FadeTransition(
            opacity: _anim,
            child: const Text('•••',
                style: TextStyle(fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

class _QuickQuestions extends StatelessWidget {
  final ServiceModel service;
  final void Function(String) onSelect;
  const _QuickQuestions({required this.service, required this.onSelect});

  List<String> get _questions => [
    'Berapa harganya?',
    if (service.isAvailableToday) 'Tersedia hari ini?',
    'Ada garansi?',
    'Berapa lama pengerjaannya?',
    'Metode pembayaran apa?',
    'Area layanan kamu?',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _questions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => onSelect(_questions[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Center(child: Text(_questions[i],
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500))),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textPrimary),
            maxLines: 4, minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Tanyakan sesuatu sebelum pesan...',
              hintStyle: const TextStyle(
                  fontSize: 14, color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
            ),
            onSubmitted: (_) => onSend(),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSend,
          child: Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
