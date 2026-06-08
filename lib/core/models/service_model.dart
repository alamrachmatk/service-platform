// ── Sub-layanan dengan harga masing-masing ──
class SubService {
  final String name;
  final String description;
  final double price;
  final String priceUnit;

  const SubService({
    required this.name,
    required this.description,
    required this.price,
    required this.priceUnit,
  });

  String get formattedPrice {
    if (price >= 1000000) return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    if (price >= 1000)    return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${price.toStringAsFixed(0)}';
  }
}

// ── Model utama mitra/penyedia jasa ──
class ServiceModel {
  final String id;
  final String name;       // nama layanan utama (kategori)
  final String category;
  final String mitra;      // nama penyedia / usaha
  final String description;
  final double rating;
  final double distanceKm;
  final int reviewCount;
  final bool isVerified;
  final List<SubService> subServices; // daftar layanan + harga

  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.mitra,
    required this.description,
    required this.rating,
    required this.distanceKm,
    required this.reviewCount,
    this.isVerified = true,
    this.subServices = const [],
  });

  // Helper: emoji per kategori
  String get emoji {
    switch (category) {
      case 'Laundry':    return '👕';
      case 'Kebersihan': return '🧹';
      case 'Elektronik': return '❄️';
      case 'Instalasi':  return '🔧';
      case 'Kesehatan':  return '💆';
      case 'Otomotif':   return '🚗';
      default:           return '🛠️';
    }
  }

  // Harga terendah dari semua sub-layanan (untuk info di detail)
  String get startingPrice {
    if (subServices.isEmpty) return '-';
    final min = subServices
        .map((s) => s.price)
        .reduce((a, b) => a < b ? a : b);
    if (min >= 1000000) return 'Rp ${(min / 1000000).toStringAsFixed(1)}jt';
    if (min >= 1000)    return 'Rp ${(min / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${min.toStringAsFixed(0)}';
  }

  // Tetap ada formattedPrice untuk kompatibilitas booking/payment
  double get price => subServices.isNotEmpty ? subServices.first.price : 0;
  String get priceUnit => subServices.isNotEmpty ? subServices.first.priceUnit : '';
  String get formattedPrice => subServices.isNotEmpty
      ? subServices.first.formattedPrice
      : '-';
}

// ── Dummy data ──
class DummyServices {
  static const all = [
    ServiceModel(
      id: '1',
      name: 'Laundry & Setrika',
      category: 'Laundry',
      mitra: 'Bu Sari Laundry',
      description: 'Laundry kiloan berpengalaman 5 tahun. Cuci bersih, harum, dan rapi. Antar jemput gratis radius 3 km.',
      rating: 4.9, distanceKm: 1.2, reviewCount: 128,
      subServices: [
        SubService(name: 'Cuci + Setrika', description: 'Cuci bersih dan setrika rapi per kg', price: 7000, priceUnit: 'kg'),
        SubService(name: 'Cuci Saja', description: 'Cuci tanpa setrika per kg', price: 5000, priceUnit: 'kg'),
        SubService(name: 'Setrika Saja', description: 'Setrika pakaian per kg', price: 4000, priceUnit: 'kg'),
        SubService(name: 'Antar Jemput', description: 'Gratis radius 3 km, lebih dari itu Rp2rb/km', price: 0, priceUnit: 'gratis'),
      ],
    ),
    ServiceModel(
      id: '2',
      name: 'Service AC',
      category: 'Elektronik',
      mitra: 'Pak Dedi Teknik',
      description: 'Teknisi AC berpengalaman 10 tahun. Menangani semua merk AC. Bergaransi 7 hari setelah servis.',
      rating: 4.8, distanceKm: 2.5, reviewCount: 94,
      subServices: [
        SubService(name: 'Cuci AC', description: 'Bersihkan filter dan evaporator', price: 100000, priceUnit: 'unit'),
        SubService(name: 'Perbaikan', description: 'Diagnosa dan perbaikan kerusakan ringan', price: 150000, priceUnit: 'unit'),
        SubService(name: 'Isi Freon', description: 'Isi freon R22/R32/R410', price: 200000, priceUnit: 'unit'),
        SubService(name: 'Instalasi', description: 'Bongkar pasang AC baru', price: 350000, priceUnit: 'unit'),
      ],
    ),
    ServiceModel(
      id: '3',
      name: 'Kebersihan Rumah',
      category: 'Kebersihan',
      mitra: 'Tim CleanPro',
      description: 'Tim profesional 3-5 orang. Bersihkan seluruh area rumah termasuk dapur dan kamar mandi. Peralatan sendiri.',
      rating: 4.7, distanceKm: 3.1, reviewCount: 211,
      subServices: [
        SubService(name: 'Bersih Reguler', description: 'Sapu, pel, dan lap perabotan', price: 150000, priceUnit: 'sesi'),
        SubService(name: 'Bersih Menyeluruh', description: 'Termasuk dapur, kamar mandi, dan jendela', price: 250000, priceUnit: 'sesi'),
        SubService(name: 'Deep Cleaning', description: 'Pembersihan menyeluruh intensif', price: 400000, priceUnit: 'sesi'),
      ],
    ),
    ServiceModel(
      id: '4',
      name: 'Pasang CCTV',
      category: 'Instalasi',
      mitra: 'CV Aman Jaya',
      description: 'Instalasi CCTV indoor dan outdoor. Setting DVR/NVR. Garansi pemasangan 1 bulan.',
      rating: 4.6, distanceKm: 4.0, reviewCount: 57,
      subServices: [
        SubService(name: 'Pasang CCTV Indoor', description: 'Pasang + setting per titik', price: 250000, priceUnit: 'titik'),
        SubService(name: 'Pasang CCTV Outdoor', description: 'Pasang + setting per titik', price: 350000, priceUnit: 'titik'),
        SubService(name: 'Setting DVR/NVR', description: 'Konfigurasi dan remote access', price: 150000, priceUnit: 'unit'),
        SubService(name: 'Perbaikan CCTV', description: 'Diagnosa dan perbaikan sistem', price: 100000, priceUnit: 'kunjungan'),
      ],
    ),
    ServiceModel(
      id: '5',
      name: 'Pijat Panggilan',
      category: 'Kesehatan',
      mitra: 'Terapis Bu Ayu',
      description: 'Terapis bersertifikat dengan pengalaman 8 tahun. Pijat relaksasi dan terapi. Datang ke rumah.',
      rating: 4.9, distanceKm: 1.8, reviewCount: 183,
      subServices: [
        SubService(name: 'Pijat Relaksasi', description: 'Pijat seluruh tubuh 60 menit', price: 120000, priceUnit: 'sesi'),
        SubService(name: 'Pijat Terapi', description: 'Fokus area bermasalah 90 menit', price: 180000, priceUnit: 'sesi'),
        SubService(name: 'Pijat + Bekam', description: 'Kombinasi pijat dan bekam 90 menit', price: 220000, priceUnit: 'sesi'),
      ],
    ),
    ServiceModel(
      id: '6',
      name: 'Servis Motor',
      category: 'Otomotif',
      mitra: 'Bengkel Maju Jaya',
      description: 'Bengkel panggilan berpengalaman. Tune-up, ganti oli, servis rem. Teknisi bersertifikat datang ke lokasi kamu.',
      rating: 4.7, distanceKm: 2.0, reviewCount: 143,
      subServices: [
        SubService(name: 'Tune-Up Ringan', description: 'Cek busi, filter udara, karburator', price: 80000, priceUnit: 'motor'),
        SubService(name: 'Ganti Oli', description: 'Ganti oli mesin + filter oli', price: 60000, priceUnit: 'motor'),
        SubService(name: 'Servis Rem', description: 'Cek dan setel rem depan belakang', price: 70000, priceUnit: 'motor'),
        SubService(name: 'Tune-Up Lengkap', description: 'Servis menyeluruh semua komponen', price: 180000, priceUnit: 'motor'),
      ],
    ),
  ];

  static const categories = [
    ('👕', 'Laundry'),
    ('🧹', 'Kebersihan'),
    ('❄️', 'Elektronik'),
    ('🔧', 'Instalasi'),
    ('💆', 'Kesehatan'),
    ('🚗', 'Otomotif'),
  ];
}
