class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String mitra;
  final String description;
  final double price;
  final double rating;
  final double distanceKm;
  final int reviewCount;
  final String priceUnit;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.mitra,
    required this.description,
    required this.price,
    required this.rating,
    required this.distanceKm,
    required this.reviewCount,
    required this.priceUnit,
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

  // Helper: format harga
  String get formattedPrice {
    if (price >= 1000000) return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    if (price >= 1000)    return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${price.toStringAsFixed(0)}';
  }
}

// ── Dummy data (nanti diganti dari API) ──
class DummyServices {
  static const all = [
    ServiceModel(id: '1', name: 'Cuci & Setrika Baju', category: 'Laundry',
        mitra: 'Bu Sari', description: 'Cuci setrika bersih rapi, antar jemput tersedia.',
        price: 7000, rating: 4.9, distanceKm: 1.2, reviewCount: 128, priceUnit: 'kg'),
    ServiceModel(id: '2', name: 'Servis AC Split', category: 'Elektronik',
        mitra: 'Pak Dedi Teknik', description: 'Bersih AC, isi freon, perbaikan ringan oleh teknisi berpengalaman.',
        price: 150000, rating: 4.8, distanceKm: 2.5, reviewCount: 94, priceUnit: 'unit'),
    ServiceModel(id: '3', name: 'Bersih-Bersih Rumah', category: 'Kebersihan',
        mitra: 'Tim CleanPro', description: 'Kebersihan menyeluruh dapur, kamar mandi, dan ruang tamu.',
        price: 200000, rating: 4.7, distanceKm: 3.1, reviewCount: 211, priceUnit: 'sesi'),
    ServiceModel(id: '4', name: 'Pasang CCTV', category: 'Instalasi',
        mitra: 'CV Aman Jaya', description: 'Pasang CCTV indoor/outdoor, setting DVR, garansi pemasangan 1 bulan.',
        price: 350000, rating: 4.6, distanceKm: 4.0, reviewCount: 57, priceUnit: 'titik'),
    ServiceModel(id: '5', name: 'Pijat Panggilan', category: 'Kesehatan',
        mitra: 'Terapis Bu Ayu', description: 'Pijat relaksasi oleh terapis bersertifikat, datang ke rumah.',
        price: 120000, rating: 4.9, distanceKm: 1.8, reviewCount: 183, priceUnit: 'jam'),
    ServiceModel(id: '6', name: 'Servis Motor', category: 'Otomotif',
        mitra: 'Bengkel Maju Jaya', description: 'Tune-up, ganti oli, servis rem, teknisi datang ke lokasi.',
        price: 80000, rating: 4.7, distanceKm: 2.0, reviewCount: 143, priceUnit: 'kunjungan'),
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
