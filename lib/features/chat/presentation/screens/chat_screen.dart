import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/order_model.dart';

class ChatScreen extends StatefulWidget {
  final OrderModel order;
  const ChatScreen({super.key, required this.order});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl      = TextEditingController();
  final _scrollCtrl   = ScrollController();
  final List<_Msg>    _messages = [];
  bool _mitraTyping   = false;

  @override
  void initState() {
    super.initState();
    // Pesan awal dari sistem
    _messages.addAll([
      _Msg(text: 'Halo! Saya ${widget.order.mitraName}. '
          'Saya sudah menerima pesanan kamu untuk ${widget.order.serviceName}. '
          'Ada yang ingin ditanyakan?',
          isMe: false,
          time: _timeNow(-5)),
    ]);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _timeNow([int minusMinutes = 0]) {
    final now = DateTime.now().subtract(Duration(minutes: minusMinutes));
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Msg(text: text, isMe: true, time: _timeNow()));
      _msgCtrl.clear();
    });

    _scrollToBottom();

    // Simulasi mitra sedang mengetik
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _mitraTyping = true);
      _scrollToBottom();

      // Simulasi balasan mitra
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _mitraTyping = false;
          _messages.add(_Msg(
            text: _autoReply(text),
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
    if (lower.contains('jam') || lower.contains('kapan') || lower.contains('berapa lama')) {
      return 'Saya akan tiba sekitar 15-20 menit lagi. Mohon ditunggu ya!';
    } else if (lower.contains('harga') || lower.contains('biaya')) {
      return 'Harga sudah sesuai yang tertera di pesanan. Jika ada tambahan pekerjaan, akan dikonfirmasi dulu sebelum dikerjakan.';
    } else if (lower.contains('batal') || lower.contains('cancel')) {
      return 'Untuk pembatalan pesanan, silakan hubungi customer service kami ya.';
    } else if (lower.contains('terima kasih') || lower.contains('makasih')) {
      return 'Sama-sama! Saya siap membantu. 😊';
    } else {
      return 'Baik, saya mengerti. Ada lagi yang ingin ditanyakan?';
    }
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
              widget.order.mitraName[0].toUpperCase(),
              style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700, color: Colors.white),
            )),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.order.mitraName,
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text(widget.order.serviceName,
                  style: const TextStyle(fontSize: 11,
                      color: AppColors.textSecondary)),
            ],
          )),
        ]),
        actions: [
          // Tombol telepon
          IconButton(
            icon: const Icon(Icons.phone_rounded,
                color: AppColors.primary, size: 22),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menghubungi mitra...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // ── Info order di atas ──
          _OrderInfoBanner(order: widget.order),

          // ── Pesan ──
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length + (_mitraTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_mitraTyping && i == _messages.length) {
                  return _TypingIndicator(name: widget.order.mitraName);
                }
                return _BubbleChat(msg: _messages[i]);
              },
            ),
          ),

          // ── Quick replies ──
          _QuickReplies(onSelect: (text) {
            _msgCtrl.text = text;
            _send();
          }),

          // ── Input field ──
          _ChatInput(
            controller: _msgCtrl,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ── Model pesan ──
class _Msg {
  final String text, time;
  final bool isMe;
  const _Msg({required this.text, required this.isMe, required this.time});
}

// ── Banner info order ──
class _OrderInfoBanner extends StatelessWidget {
  final OrderModel order;
  const _OrderInfoBanner({required this.order});

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
        Text(order.serviceEmoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.serviceName, style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
            Text('${order.formattedDate} · ${order.formattedTime}',
                style: const TextStyle(fontSize: 11,
                    color: AppColors.textSecondary)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(order.status.label,
              style: const TextStyle(fontSize: 10,
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ── Bubble chat ──
class _BubbleChat extends StatelessWidget {
  final _Msg msg;
  const _BubbleChat({required this.msg});

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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                Text(msg.time,
                    style: const TextStyle(
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

// ── Indikator mitra mengetik ──
class _TypingIndicator extends StatelessWidget {
  final String name;
  const _TypingIndicator({required this.name});

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
          Text('$name sedang mengetik',
              style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
          const SizedBox(width: 8),
          const SizedBox(width: 20, child: _DotAnimation()),
        ]),
      ),
    );
  }
}

class _DotAnimation extends StatefulWidget {
  const _DotAnimation();
  @override
  State<_DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<_DotAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: const Text('...', style: TextStyle(
          fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Quick replies ──
class _QuickReplies extends StatelessWidget {
  final void Function(String) onSelect;
  const _QuickReplies({required this.onSelect});

  static const _replies = [
    'Berapa lama lagi?',
    'Oke, ditunggu ya',
    'Terima kasih',
    'Berapa biayanya?',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _replies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onSelect(_replies[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Center(child: Text(_replies[i],
                style: const TextStyle(fontSize: 12,
                    color: AppColors.primary, fontWeight: FontWeight.w500))),
          ),
        ),
      ),
    );
  }
}

// ── Input chat ──
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
        // Tombol lampiran
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.attach_file_rounded,
                color: AppColors.textSecondary, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        // Input teks
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            maxLines: 4, minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Tulis pesan...',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
              filled: true, fillColor: AppColors.background,
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
        // Tombol kirim
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
