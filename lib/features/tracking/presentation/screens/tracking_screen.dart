import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ── Warna brand ──
class _C {
  static const primary     = Color(0xFF00897B);
  static const primaryLight= Color(0xFF4DB6AC);
  static const bg          = Color(0xFFF5F5F5);
  static const border      = Color(0xFFE0E0E0);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint    = Color(0xFFBDBDBD);
  static const success     = Color(0xFF43A047);
  static const warning     = Color(0xFFFFA726);
  static const error       = Color(0xFFE53935);
  static const info        = Color(0xFF1E88E5);
}

// ── Model posisi ──
class _LatLng {
  final double lat, lng;
  const _LatLng(this.lat, this.lng);

  _LatLng lerp(_LatLng other, double t) => _LatLng(
    lat + (other.lat - lat) * t,
    lng + (other.lng - lng) * t,
  );

  double distanceTo(_LatLng other) {
    final dlat = (other.lat - lat).abs();
    final dlng = (other.lng - lng).abs();
    return sqrt(dlat * dlat + dlng * dlng) * 111;
  }
}

// ── Status tracking ──
enum TrackingStatus { onTheWay, arrived, inProgress, done }

extension TrackingStatusX on TrackingStatus {
  String get label {
    switch (this) {
      case TrackingStatus.onTheWay:   return 'Mitra dalam perjalanan';
      case TrackingStatus.arrived:    return 'Mitra sudah tiba';
      case TrackingStatus.inProgress: return 'Pengerjaan berlangsung';
      case TrackingStatus.done:       return 'Selesai!';
    }
  }

  String get emoji {
    switch (this) {
      case TrackingStatus.onTheWay:   return '🚗';
      case TrackingStatus.arrived:    return '📍';
      case TrackingStatus.inProgress: return '🔧';
      case TrackingStatus.done:       return '✅';
    }
  }

  Color get color {
    switch (this) {
      case TrackingStatus.onTheWay:   return _C.info;
      case TrackingStatus.arrived:    return _C.warning;
      case TrackingStatus.inProgress: return _C.primary;
      case TrackingStatus.done:       return _C.success;
    }
  }
}

class TrackingScreen extends StatefulWidget {
  final String mitraName;
  final String serviceName;
  final String orderId;

  const TrackingScreen({
    super.key,
    this.mitraName = 'Budi Santoso',
    this.serviceName = 'Servis AC Split',
    this.orderId = 'ORD-001',
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  // Posisi simulasi (koordinat relatif untuk peta custom)
  static const _customerPos = _LatLng(-6.5971, 106.8060);
  static const _mitraStart  = _LatLng(-6.6120, 106.7900);
  static const _mitraEnd    = _LatLng(-6.5985, 106.8055);

  late _LatLng _mitraPos;
  TrackingStatus _status = TrackingStatus.onTheWay;
  double _progress = 0.0;
  int _etaMinutes  = 12;
  bool _mapExpanded = false;

  Timer? _timer;
  late AnimationController _pulseCtrl;
  late AnimationController _markerCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _markerBounce;

  @override
  void initState() {
    super.initState();
    _mitraPos = _mitraStart;

    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _pulseAnim = Tween(begin: 0.0, end: 1.0).animate(_pulseCtrl);

    _markerCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _markerBounce = Tween(begin: 0.0, end: -6.0).animate(
        CurvedAnimation(parent: _markerCtrl, curve: Curves.easeInOut));

    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (!mounted) return;
      setState(() {
        _progress = (_progress + 0.012).clamp(0.0, 1.0);
        _mitraPos = _mitraStart.lerp(_mitraEnd, _progress);

        // Update ETA
        _etaMinutes = (12 * (1 - _progress)).round();

        // Update status
        if (_progress >= 1.0) {
          _status = TrackingStatus.done;
          _timer?.cancel();
        } else if (_progress >= 0.85) {
          _status = TrackingStatus.inProgress;
        } else if (_progress >= 0.72) {
          _status = TrackingStatus.arrived;
        } else {
          _status = TrackingStatus.onTheWay;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _markerCtrl.dispose();
    super.dispose();
  }

  double _fmtDist() {
    return double.parse(
        (_mitraPos.distanceTo(_customerPos)).toStringAsFixed(1));
  }

  // Convert koordinat ke posisi pixel di widget peta
  Offset _toPixel(_LatLng pos, Size mapSize) {
    const minLat = -6.625, maxLat = -6.585;
    const minLng = 106.780, maxLng = 106.820;
    final x = ((pos.lng - minLng) / (maxLng - minLng)) * mapSize.width;
    final y = ((maxLat - pos.lat) / (maxLat - minLat)) * mapSize.height;
    return Offset(x.clamp(0, mapSize.width), y.clamp(0, mapSize.height));
  }

  @override
  Widget build(BuildContext context) {
    final mapH = _mapExpanded ? 380.0 : 260.0;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: _C.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Lacak Mitra',
            style: TextStyle(fontSize: 17,
                fontWeight: FontWeight.w600, color: _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: _C.primary, size: 22),
            onPressed: () {
              setState(() {
                _progress = 0.0;
                _mitraPos = _mitraStart;
                _status = TrackingStatus.onTheWay;
                _etaMinutes = 12;
                _timer?.cancel();
              });
              _startSimulation();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      ),
      body: Column(children: [

        // ── Status banner ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: _status.color.withOpacity(0.1),
          child: Row(children: [
            Text(_status.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_status.label, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: _status.color)),
                if (_status == TrackingStatus.onTheWay)
                  Text('Estimasi tiba: $_etaMinutes menit lagi',
                      style: const TextStyle(fontSize: 12,
                          color: _C.textSecondary)),
              ],
            )),
            if (_status != TrackingStatus.done)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _status.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _status == TrackingStatus.onTheWay
                      ? '$_etaMinutes mnt'
                      : _status == TrackingStatus.inProgress
                          ? 'Sedang dikerjakan'
                          : 'Tiba!',
                  style: const TextStyle(fontSize: 11,
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
          ]),
        ),

        // ── Peta simulasi ──
        GestureDetector(
          onTap: () => setState(() => _mapExpanded = !_mapExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: mapH,
            child: LayoutBuilder(builder: (ctx, cst) {
              final sz = Size(cst.maxWidth, mapH);
              final mitraPx  = _toPixel(_mitraPos, sz);
              final custPx   = _toPixel(_customerPos, sz);
              final startPx  = _toPixel(_mitraStart, sz);

              return Stack(children: [
                // Grid peta
                CustomPaint(size: sz, painter: _MapPainter(
                  mitraPos: mitraPx, customerPos: custPx,
                  startPos: startPx, progress: _progress,
                )),

                // Pulse ring di lokasi pelanggan
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Positioned(
                    left: custPx.dx - 30 * _pulseAnim.value,
                    top: custPx.dy - 30 * _pulseAnim.value,
                    child: Opacity(
                      opacity: (1 - _pulseAnim.value).clamp(0, 1),
                      child: Container(
                        width: 60 * _pulseAnim.value,
                        height: 60 * _pulseAnim.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _C.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),

                // Marker lokasi pelanggan
                Positioned(
                  left: custPx.dx - 18,
                  top: custPx.dy - 18,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _C.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [BoxShadow(
                        color: _C.primary.withOpacity(0.4),
                        blurRadius: 8,
                      )],
                    ),
                    child: const Icon(Icons.home_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),

                // Marker mitra bergerak (dengan bounce)
                AnimatedBuilder(
                  animation: _markerBounce,
                  builder: (_, __) => AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    left: mitraPx.dx - 22,
                    top: mitraPx.dy - 44 + _markerBounce.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nama mitra bubble
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                            )],
                          ),
                          child: Text(
                            widget.mitraName.split(' ').first,
                            style: const TextStyle(fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Marker ikon mitra
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: _C.info,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [BoxShadow(
                              color: _C.info.withOpacity(0.4),
                              blurRadius: 8,
                            )],
                          ),
                          child: const Icon(Icons.directions_car_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tombol expand/collapse peta
                Positioned(
                  right: 12, bottom: 12,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _mapExpanded = !_mapExpanded),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                        )],
                      ),
                      child: Icon(
                        _mapExpanded
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: _C.primary, size: 20,
                      ),
                    ),
                  ),
                ),

                // Info jarak
                Positioned(
                  left: 12, bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      )],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.route_rounded,
                          size: 14, color: _C.primary),
                      const SizedBox(width: 5),
                      Text('${_fmtDist()} km',
                          style: const TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrimary)),
                    ]),
                  ),
                ),

                // Label legenda
                Positioned(
                  left: 12, top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: _C.info),
                        SizedBox(width: 4),
                        Text('Mitra  ', style: TextStyle(fontSize: 10)),
                        Icon(Icons.circle, size: 8, color: _C.primary),
                        SizedBox(width: 4),
                        Text('Kamu', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ]);
            }),
          ),
        ),

        // ── Progress bar perjalanan ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.circle, size: 8, color: _C.info),
              Expanded(child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: _C.border,
                    valueColor:
                        const AlwaysStoppedAnimation(_C.primary),
                    minHeight: 4,
                  ),
                ),
              )),
              const Icon(Icons.home_rounded, size: 12, color: _C.primary),
            ]),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lokasi mitra',
                    style: TextStyle(fontSize: 10, color: _C.textHint)),
                Text('${(_progress * 100).toInt()}% perjalanan',
                    style: const TextStyle(fontSize: 10,
                        color: _C.textSecondary,
                        fontWeight: FontWeight.w600)),
                const Text('Rumahmu',
                    style: TextStyle(fontSize: 10, color: _C.textHint)),
              ],
            ),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [

            // ── Info mitra ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border, width: 0.5),
              ),
              child: Row(children: [
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_C.primary, _C.primaryLight]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(
                    widget.mitraName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 20,
                        fontWeight: FontWeight.w700, color: Colors.white),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.mitraName, style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                    const SizedBox(height: 2),
                    Text(widget.serviceName, style: const TextStyle(
                        fontSize: 12, color: _C.textSecondary)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Color(0xFFFFA726)),
                      const Text(' 4.8 · ',
                          style: TextStyle(fontSize: 11, color: _C.textSecondary)),
                      const Icon(Icons.verified_rounded,
                          size: 12, color: _C.primary),
                      const Text(' Terverifikasi',
                          style: TextStyle(fontSize: 11, color: _C.primary)),
                    ]),
                  ],
                )),
                Column(children: [
                  _ActionBtn(
                    icon: Icons.chat_rounded,
                    color: _C.primary,
                    label: 'Chat',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membuka chat mitra...'),
                          behavior: SnackBarBehavior.floating)),
                  ),
                  const SizedBox(height: 8),
                  _ActionBtn(
                    icon: Icons.phone_rounded,
                    color: _C.success,
                    label: 'Telepon',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menghubungi mitra...'),
                          behavior: SnackBarBehavior.floating)),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Timeline status ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status Perjalanan', style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
                  const SizedBox(height: 14),
                  _TimelineItem(
                    label: 'Pesanan dikonfirmasi',
                    time: '09:00',
                    isDone: true,
                    isActive: false,
                  ),
                  _TimelineItem(
                    label: 'Mitra dalam perjalanan',
                    time: _status == TrackingStatus.onTheWay
                        ? 'Sekarang' : '09:05',
                    isDone: _status != TrackingStatus.onTheWay,
                    isActive: _status == TrackingStatus.onTheWay,
                  ),
                  _TimelineItem(
                    label: 'Mitra tiba di lokasi',
                    time: _status.index >= TrackingStatus.arrived.index
                        ? '~09:17' : '--:--',
                    isDone: _status.index > TrackingStatus.arrived.index,
                    isActive: _status == TrackingStatus.arrived,
                  ),
                  _TimelineItem(
                    label: 'Pengerjaan berlangsung',
                    time: _status.index >= TrackingStatus.inProgress.index
                        ? '~09:18' : '--:--',
                    isDone: _status == TrackingStatus.done,
                    isActive: _status == TrackingStatus.inProgress,
                  ),
                  _TimelineItem(
                    label: 'Selesai',
                    time: _status == TrackingStatus.done ? '~10:00' : '--:--',
                    isDone: _status == TrackingStatus.done,
                    isActive: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Info order ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border, width: 0.5),
              ),
              child: Column(children: [
                _InfoRow(label: 'ID Pesanan', value: widget.orderId),
                const Divider(height: 16),
                _InfoRow(label: 'Layanan', value: widget.serviceName),
                const Divider(height: 16),
                _InfoRow(label: 'Alamat', value: 'Jl. Padjajaran No. 12, Bogor'),
                const Divider(height: 16),
                _InfoRow(
                  label: 'ETA',
                  value: _status == TrackingStatus.onTheWay
                      ? '$_etaMinutes menit lagi'
                      : _status == TrackingStatus.done
                          ? 'Selesai'
                          : 'Sudah tiba',
                  valueColor: _status.color,
                ),
              ]),
            ),
            const SizedBox(height: 80),
          ]),
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// CUSTOM MAP PAINTER
// ─────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  final Offset mitraPos, customerPos, startPos;
  final double progress;

  const _MapPainter({
    required this.mitraPos, required this.customerPos,
    required this.startPos, required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background peta
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFE8F0E0));

    // Grid jalan horizontal
    final roadPaint = Paint()..color = Colors.white..strokeWidth = 14;
    final roadBorder = Paint()..color = const Color(0xFFCCCCCC)..strokeWidth = 16;

    for (double y = 60; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadBorder);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }

    // Grid jalan vertikal
    for (double x = 60; x < size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadBorder);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    // Blok bangunan simulasi
    final buildingPaint = Paint()..color = const Color(0xFFD4E3C2);
    final buildings = [
      Rect.fromLTWH(10, 10, 45, 45),
      Rect.fromLTWH(70, 10, 25, 45),
      Rect.fromLTWH(165, 10, 55, 45),
      Rect.fromLTWH(10, 70, 45, 35),
      Rect.fromLTWH(70, 70, 55, 35),
      Rect.fromLTWH(165, 70, 30, 35),
      Rect.fromLTWH(10, 120, 45, 45),
      Rect.fromLTWH(70, 120, 30, 45),
      Rect.fromLTWH(200, 120, 45, 45),
    ];
    for (final b in buildings) {
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(3)),
          buildingPaint);
    }

    // Garis rute (trail)
    final routePaint = Paint()
      ..color = const Color(0xFF00897B).withOpacity(0.3)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(startPos, customerPos, routePaint);

    // Garis rute yang sudah dilalui
    final donePaint = Paint()
      ..color = const Color(0xFF00897B)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(startPos, mitraPos, donePaint);

    // Titik awal mitra
    canvas.drawCircle(startPos, 5,
        Paint()..color = const Color(0xFF90A4AE));
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.mitraPos != mitraPos || old.progress != progress;
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color,
      required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label, time;
  final bool isDone, isActive, isLast;
  const _TimelineItem({required this.label, required this.time,
      required this.isDone, required this.isActive, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: isDone ? _C.primary : isActive
                ? _C.warning : _C.border,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check_rounded : isActive
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: Colors.white, size: 13,
          ),
        ),
        if (!isLast) Container(width: 2, height: 30, color: _C.border),
      ]),
      const SizedBox(width: 12),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(top: 3, bottom: 12),
        child: Row(children: [
          Expanded(child: Text(label, style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? _C.warning
                  : isDone ? _C.textPrimary : _C.textHint))),
          Text(time, style: TextStyle(
              fontSize: 11,
              color: isActive ? _C.warning : _C.textSecondary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
        ]),
      )),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(label, style: const TextStyle(
          fontSize: 13, color: _C.textSecondary))),
      Text(value, style: TextStyle(fontSize: 13,
          fontWeight: FontWeight.w600,
          color: valueColor ?? _C.textPrimary)),
    ]);
  }
}
