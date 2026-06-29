enum RecurringFrequency { weekly, biweekly, monthly }

extension RecurringFrequencyX on RecurringFrequency {
  String get label {
    switch (this) {
      case RecurringFrequency.weekly:   return 'Setiap Minggu';
      case RecurringFrequency.biweekly: return 'Setiap 2 Minggu';
      case RecurringFrequency.monthly:  return 'Setiap Bulan';
    }
  }

  String get shortLabel {
    switch (this) {
      case RecurringFrequency.weekly:   return 'Mingguan';
      case RecurringFrequency.biweekly: return '2 Mingguan';
      case RecurringFrequency.monthly:  return 'Bulanan';
    }
  }

  int get intervalDays {
    switch (this) {
      case RecurringFrequency.weekly:   return 7;
      case RecurringFrequency.biweekly: return 14;
      case RecurringFrequency.monthly:  return 30;
    }
  }

  String get desc {
    switch (this) {
      case RecurringFrequency.weekly:   return 'Cocok untuk kebersihan rumah rutin';
      case RecurringFrequency.biweekly: return 'Cocok untuk perawatan berkala';
      case RecurringFrequency.monthly:  return 'Cocok untuk servis AC, maintenance';
    }
  }
}

enum RecurringStatus { active, paused, cancelled }

extension RecurringStatusX on RecurringStatus {
  String get label {
    switch (this) {
      case RecurringStatus.active:    return 'Aktif';
      case RecurringStatus.paused:    return 'Dijeda';
      case RecurringStatus.cancelled: return 'Dibatalkan';
    }
  }
}

class RecurringScheduleModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String serviceEmoji;
  final String mitraName;
  final double price;
  final String priceUnit;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final TimeOfDayModel time;
  final String address;
  final RecurringStatus status;
  final int completedCount;
  final DateTime? nextDate;

  const RecurringScheduleModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.serviceEmoji,
    required this.mitraName,
    required this.price,
    required this.priceUnit,
    required this.frequency,
    required this.startDate,
    required this.time,
    required this.address,
    this.status = RecurringStatus.active,
    this.completedCount = 0,
    this.nextDate,
  });

  String get formattedPrice {
    if (price >= 1000000) return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    if (price >= 1000) return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  String get formattedNextDate {
    if (nextDate == null) return '-';
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${nextDate!.day} ${months[nextDate!.month]} ${nextDate!.year}';
  }
}

// Helper kecil agar tidak perlu import material untuk TimeOfDay di model layer
class TimeOfDayModel {
  final int hour, minute;
  const TimeOfDayModel({required this.hour, required this.minute});

  String get formatted {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Dummy data jadwal rutin ──
class DummyRecurring {
  static List<RecurringScheduleModel> get all => [
        RecurringScheduleModel(
          id: 'RCR-001',
          serviceId: '3',
          serviceName: 'Bersih-Bersih Rumah',
          serviceEmoji: '🧹',
          mitraName: 'Tim CleanPro',
          price: 200000,
          priceUnit: 'sesi',
          frequency: RecurringFrequency.weekly,
          startDate: DateTime.now().subtract(const Duration(days: 14)),
          time: const TimeOfDayModel(hour: 9, minute: 0),
          address: 'Jl. Merdeka No. 10, Bogor Tengah',
          status: RecurringStatus.active,
          completedCount: 2,
          nextDate: DateTime.now().add(const Duration(days: 3)),
        ),
        RecurringScheduleModel(
          id: 'RCR-002',
          serviceId: '2',
          serviceName: 'Servis AC Split',
          serviceEmoji: '❄️',
          mitraName: 'Pak Dedi Teknik',
          price: 150000,
          priceUnit: 'unit',
          frequency: RecurringFrequency.monthly,
          startDate: DateTime.now().subtract(const Duration(days: 60)),
          time: const TimeOfDayModel(hour: 14, minute: 0),
          address: 'Jl. Merdeka No. 10, Bogor Tengah',
          status: RecurringStatus.paused,
          completedCount: 2,
          nextDate: DateTime.now().add(const Duration(days: 10)),
        ),
      ];
}
