// ── Item detail dalam satu sub-layanan ──
class ServiceItem {
  final String name;
  final String description;
  final double price;
  final double? originalPrice; // harga coret jika ada diskon

  const ServiceItem({
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
  });

  String get formattedPrice {
    if (price >= 1000000) return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    if (price >= 1000)    return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  String? get formattedOriginalPrice {
    if (originalPrice == null) return null;
    if (originalPrice! >= 1000000) return 'Rp ${(originalPrice! / 1000000).toStringAsFixed(1)}jt';
    if (originalPrice! >= 1000)    return 'Rp ${(originalPrice! / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${originalPrice!.toStringAsFixed(0)}';
  }
}

// ── Sub-layanan (kategori) dengan daftar item ──
class SubService {
  final String name;
  final String description;
  final List<ServiceItem> items; // item detail yang bisa dipilih

  const SubService({
    required this.name,
    required this.description,
    required this.items,
  });

  // Harga terendah dari semua item
  double get minPrice => items.isEmpty ? 0 :
      items.map((i) => i.price).reduce((a, b) => a < b ? a : b);

  String get formattedMinPrice {
    if (minPrice >= 1000000) return 'Rp ${(minPrice / 1000000).toStringAsFixed(1)}jt';
    if (minPrice >= 1000)    return 'Rp ${(minPrice / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${minPrice.toStringAsFixed(0)}';
  }
}

// ── Model utama mitra/penyedia jasa ──
class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String mitra;
  final String description;
  final double rating;
  final double distanceKm;
  final int reviewCount;
  final bool isVerified;
  final List<SubService> subServices;

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

  // Untuk kompatibilitas booking/payment
  double get price => subServices.isNotEmpty && subServices.first.items.isNotEmpty
      ? subServices.first.items.first.price : 0;
  String get priceUnit => 'layanan';
  String get formattedPrice {
    if (price >= 1000000) return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    if (price >= 1000)    return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${price.toStringAsFixed(0)}';
  }
}

// ── Model untuk item yang sudah dipilih pelanggan ──
class SelectedItem {
  final SubService subService;
  final ServiceItem item;
  int qty;

  SelectedItem({
    required this.subService,
    required this.item,
    this.qty = 1,
  });

  double get subtotal => item.price * qty;

  String get formattedSubtotal {
    if (subtotal >= 1000000) return 'Rp ${(subtotal / 1000000).toStringAsFixed(1)}jt';
    if (subtotal >= 1000)    return 'Rp ${(subtotal / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${subtotal.toStringAsFixed(0)}';
  }
}

// ─────────────────────────────────────────────
// DUMMY DATA
// ─────────────────────────────────────────────
class DummyServices {
  static const all = [
    ServiceModel(
      id: '1', name: 'Laundry & Setrika', category: 'Laundry',
      mitra: 'Bu Sari Laundry',
      description: 'Laundry kiloan berpengalaman 5 tahun. Cuci bersih, harum, dan rapi. Antar jemput gratis radius 3 km.',
      rating: 4.9, distanceKm: 1.2, reviewCount: 128,
      subServices: [
        SubService(name: 'Cuci + Setrika', description: 'Pilih jenis pakaian yang akan dicuci',
          items: [
            ServiceItem(name: 'Cuci Setrika Reguler', description: 'Pakaian harian per kg', price: 7000),
            ServiceItem(name: 'Cuci Setrika Express', description: 'Selesai dalam 6 jam', price: 12000, originalPrice: 15000),
            ServiceItem(name: 'Cuci Setrika Bed Cover', description: 'Per lembar ukuran single-king', price: 25000),
          ]),
        SubService(name: 'Cuci Saja', description: 'Tanpa setrika',
          items: [
            ServiceItem(name: 'Cuci Reguler', description: 'Per kg, diambil keesokan hari', price: 5000),
            ServiceItem(name: 'Cuci Express', description: 'Per kg, selesai 4 jam', price: 9000),
          ]),
        SubService(name: 'Setrika Saja', description: 'Pakaian sudah dicuci',
          items: [
            ServiceItem(name: 'Setrika Reguler', description: 'Per kg pakaian kering', price: 4000),
            ServiceItem(name: 'Setrika Kemeja/Jas', description: 'Per lembar', price: 8000),
          ]),
      ],
    ),
    ServiceModel(
      id: '2', name: 'Service AC', category: 'Elektronik',
      mitra: 'Pak Dedi Teknik',
      description: 'Teknisi AC berpengalaman 10 tahun. Menangani semua merk. Bergaransi 7 hari.',
      rating: 4.8, distanceKm: 2.5, reviewCount: 94,
      subServices: [
        SubService(name: 'Cuci AC', description: 'Pilih kapasitas dan tipe AC',
          items: [
            ServiceItem(name: 'Cuci AC 0.5 - 1 PK', description: 'Standar, bersih filter & evaporator', price: 85000, originalPrice: 100000),
            ServiceItem(name: 'Cuci AC 1.5 - 2 PK', description: 'Kapasitas besar', price: 100000),
            ServiceItem(name: 'Cuci AC Inverter 0.5 - 2 PK', description: 'Khusus AC inverter', price: 130000),
            ServiceItem(name: 'Cuci AC Cassette / Standing', description: 'AC tipe komersial', price: 200000),
          ]),
        SubService(name: 'Perbaikan', description: 'Diagnosa dan perbaikan kerusakan',
          items: [
            ServiceItem(name: 'Perbaikan Ringan', description: 'Kerusakan minor, tidak termasuk spare part', price: 100000),
            ServiceItem(name: 'Perbaikan Sedang', description: 'Termasuk penggantian komponen kecil', price: 200000),
            ServiceItem(name: 'Overhaul Lengkap', description: 'Perbaikan menyeluruh semua komponen', price: 350000),
          ]),
        SubService(name: 'Isi Freon', description: 'Pilih jenis freon AC kamu',
          items: [
            ServiceItem(name: 'Isi Freon R22 (0.5 - 1 PK)', description: 'Freon standar lama', price: 175000),
            ServiceItem(name: 'Isi Freon R32 (0.5 - 1 PK)', description: 'Freon ramah lingkungan', price: 200000),
            ServiceItem(name: 'Isi Freon R410 (0.5 - 1 PK)', description: 'Freon premium inverter', price: 250000),
          ]),
        SubService(name: 'Instalasi', description: 'Pasang AC baru atau pindah lokasi',
          items: [
            ServiceItem(name: 'Pasang Baru 0.5 - 1 PK', description: 'Termasuk pipa 3 meter', price: 300000),
            ServiceItem(name: 'Pasang Baru 1.5 - 2 PK', description: 'Termasuk pipa 3 meter', price: 400000),
            ServiceItem(name: 'Bongkar Pasang Pindah', description: 'Pindah unit ke lokasi lain', price: 350000),
          ]),
      ],
    ),
    ServiceModel(
      id: '3', name: 'Kebersihan Rumah', category: 'Kebersihan',
      mitra: 'Tim CleanPro',
      description: 'Tim profesional 3-5 orang. Bersihkan seluruh area rumah. Peralatan sendiri.',
      rating: 4.7, distanceKm: 3.1, reviewCount: 211,
      subServices: [
        SubService(name: 'Kebersihan Reguler', description: 'Pilih luas area rumah',
          items: [
            ServiceItem(name: 'Rumah < 60 m²', description: 'Sapu, pel, lap perabotan', price: 150000),
            ServiceItem(name: 'Rumah 60 - 100 m²', description: 'Sapu, pel, lap perabotan', price: 200000),
            ServiceItem(name: 'Rumah > 100 m²', description: 'Sapu, pel, lap perabotan', price: 280000),
          ]),
        SubService(name: 'Deep Cleaning', description: 'Pembersihan intensif menyeluruh',
          items: [
            ServiceItem(name: 'Deep Clean < 60 m²', description: 'Termasuk dapur, kamar mandi, jendela', price: 350000, originalPrice: 400000),
            ServiceItem(name: 'Deep Clean 60 - 100 m²', description: 'Termasuk dapur, kamar mandi, jendela', price: 500000),
            ServiceItem(name: 'Deep Clean > 100 m²', description: 'Termasuk dapur, kamar mandi, jendela', price: 700000),
          ]),
      ],
    ),
    ServiceModel(
      id: '4', name: 'Pasang CCTV', category: 'Instalasi',
      mitra: 'CV Aman Jaya',
      description: 'Instalasi CCTV indoor dan outdoor. Setting DVR/NVR. Garansi pemasangan 1 bulan.',
      rating: 4.6, distanceKm: 4.0, reviewCount: 57,
      subServices: [
        SubService(name: 'Pasang CCTV', description: 'Pilih tipe pemasangan',
          items: [
            ServiceItem(name: 'CCTV Indoor per titik', description: 'Kamera dalam ruangan', price: 250000),
            ServiceItem(name: 'CCTV Outdoor per titik', description: 'Kamera luar ruangan, tahan cuaca', price: 350000),
            ServiceItem(name: 'CCTV PTZ per titik', description: 'Kamera rotasi 360 derajat', price: 500000),
          ]),
        SubService(name: 'Setting & Konfigurasi', description: 'Setting sistem CCTV',
          items: [
            ServiceItem(name: 'Setting DVR/NVR', description: 'Konfigurasi rekaman dan remote access', price: 150000),
            ServiceItem(name: 'Setting Remote Viewing', description: 'Akses CCTV dari HP', price: 100000),
          ]),
      ],
    ),
    ServiceModel(
      id: '5', name: 'Pijat Panggilan', category: 'Kesehatan',
      mitra: 'Terapis Bu Ayu',
      description: 'Terapis bersertifikat 8 tahun pengalaman. Pijat relaksasi dan terapi. Datang ke rumah.',
      rating: 4.9, distanceKm: 1.8, reviewCount: 183,
      subServices: [
        SubService(name: 'Pijat Relaksasi', description: 'Pilih durasi pijat',
          items: [
            ServiceItem(name: 'Pijat 60 Menit', description: 'Relaksasi seluruh tubuh', price: 120000),
            ServiceItem(name: 'Pijat 90 Menit', description: 'Relaksasi intensif', price: 170000),
            ServiceItem(name: 'Pijat 120 Menit', description: 'Relaksasi premium + kepala', price: 220000),
          ]),
        SubService(name: 'Pijat + Bekam', description: 'Kombinasi pijat dan bekam',
          items: [
            ServiceItem(name: 'Bekam 5 titik', description: 'Bekam ringan + pijat 30 menit', price: 180000),
            ServiceItem(name: 'Bekam 10 titik', description: 'Bekam lengkap + pijat 60 menit', price: 280000),
          ]),
      ],
    ),
    ServiceModel(
      id: '6', name: 'Servis Motor', category: 'Otomotif',
      mitra: 'Bengkel Maju Jaya',
      description: 'Bengkel panggilan berpengalaman. Teknisi bersertifikat datang ke lokasi kamu.',
      rating: 4.7, distanceKm: 2.0, reviewCount: 143,
      subServices: [
        SubService(name: 'Tune-Up', description: 'Pilih paket perawatan',
          items: [
            ServiceItem(name: 'Tune-Up Ringan', description: 'Cek busi, filter udara, angin ban', price: 80000),
            ServiceItem(name: 'Tune-Up Lengkap', description: 'Servis semua komponen + ganti oli', price: 180000, originalPrice: 200000),
          ]),
        SubService(name: 'Ganti Oli', description: 'Pilih jenis oli',
          items: [
            ServiceItem(name: 'Oli Mineral', description: 'Ganti oli mineral standar', price: 55000),
            ServiceItem(name: 'Oli Semi Sintetik', description: 'Performa lebih baik', price: 75000),
            ServiceItem(name: 'Oli Full Sintetik', description: 'Oli premium terbaik', price: 120000),
          ]),
        SubService(name: 'Servis Rem', description: 'Pilih jenis servis rem',
          items: [
            ServiceItem(name: 'Setel Rem', description: 'Penyetelan rem depan belakang', price: 50000),
            ServiceItem(name: 'Ganti Kampas Rem', description: 'Per roda, belum termasuk kampas', price: 70000),
          ]),
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
