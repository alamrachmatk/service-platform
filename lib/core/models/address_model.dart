// ── Model wilayah Indonesia ──
class AddressModel {
  final String province;
  final String city;
  final String district;   // kecamatan
  final String village;    // kelurahan
  final String detail;     // alamat lengkap
  final String? label;     // Rumah / Kantor

  const AddressModel({
    required this.province,
    required this.city,
    required this.district,
    required this.village,
    required this.detail,
    this.label,
  });

  String get fullAddress =>
      '$detail, $village, $district, $city, $province';

  String get shortAddress => '$district, $city';
}

// ── Dummy data wilayah (sebagian) ──
class DummyWilayah {
  static const provinces = [
    'DKI Jakarta', 'Jawa Barat', 'Jawa Tengah', 'Jawa Timur',
    'Banten', 'Bali', 'Sumatera Utara', 'Sulawesi Selatan',
  ];

  static const Map<String, List<String>> cities = {
    'DKI Jakarta':     ['Jakarta Pusat', 'Jakarta Selatan', 'Jakarta Barat', 'Jakarta Timur', 'Jakarta Utara'],
    'Jawa Barat':      ['Kota Bogor', 'Kabupaten Bogor', 'Kota Bandung', 'Kota Bekasi', 'Kota Depok', 'Kota Cimahi'],
    'Jawa Tengah':     ['Kota Semarang', 'Kota Solo', 'Kota Yogyakarta', 'Kota Magelang'],
    'Jawa Timur':      ['Kota Surabaya', 'Kota Malang', 'Kota Kediri', 'Kota Blitar'],
    'Banten':          ['Kota Tangerang', 'Kota Tangerang Selatan', 'Kota Serang', 'Kabupaten Tangerang'],
    'Bali':            ['Kota Denpasar', 'Kabupaten Badung', 'Kabupaten Gianyar'],
    'Sumatera Utara':  ['Kota Medan', 'Kota Binjai', 'Kota Tebing Tinggi'],
    'Sulawesi Selatan':['Kota Makassar', 'Kota Parepare', 'Kota Palopo'],
  };

  static const Map<String, List<String>> districts = {
    'Kota Bogor':      ['Bogor Tengah', 'Bogor Selatan', 'Bogor Timur', 'Bogor Utara', 'Bogor Barat', 'Tanah Sareal'],
    'Kabupaten Bogor': ['Cibinong', 'Bojonggede', 'Depok', 'Gunung Putri', 'Cileungsi', 'Tajur Halang'],
    'Kota Bandung':    ['Bandung Kulon', 'Bandung Wetan', 'Cicendo', 'Cidadap', 'Coblong', 'Sukasari'],
    'Jakarta Selatan': ['Kebayoran Baru', 'Kebayoran Lama', 'Pesanggrahan', 'Cilandak', 'Pasar Minggu'],
    'Jakarta Pusat':   ['Gambir', 'Sawah Besar', 'Kemayoran', 'Senen', 'Cempaka Putih', 'Menteng'],
    'Kota Tangerang Selatan': ['Ciputat', 'Ciputat Timur', 'Pamulang', 'Pondok Aren', 'Serpong'],
  };

  static const Map<String, List<String>> villages = {
    'Bogor Tengah':    ['Cibogor', 'Ciwaringin', 'Gudang', 'Kebon Kelapa', 'Paledang', 'Pabaton'],
    'Bogor Selatan':   ['Batutulis', 'Bondongan', 'Cipaku', 'Empang', 'Lawanggintung'],
    'Cibinong':        ['Cibinong', 'Cirimekar', 'Pondok Rajeg', 'Sukahati', 'Tengah'],
    'Tajur Halang':    ['Citayam', 'Kalisuren', 'Nanggerang', 'Sasak Panjang', 'Sukmajaya', 'Tajur Halang', 'Tonjong'],
    'Kebayoran Baru':  ['Cipete Utara', 'Gandaria Utara', 'Kramat Pela', 'Melawai', 'Pulo', 'Rawa Barat'],
    'Pamulang':        ['Bambu Apus', 'Benda Baru', 'Pamulang Barat', 'Pamulang Timur', 'Pondok Benda'],
  };

  static List<String> getCities(String province) =>
      cities[province] ?? [];

  static List<String> getDistricts(String city) =>
      districts[city] ?? ['Kecamatan 1', 'Kecamatan 2', 'Kecamatan 3'];

  static List<String> getVillages(String district) =>
      villages[district] ?? ['Kelurahan 1', 'Kelurahan 2', 'Kelurahan 3'];
}
