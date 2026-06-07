enum OrderStatus {
  pending,
  confirmed,
  onTheWay,
  inProgress,
  completed,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:     return 'Menunggu konfirmasi';
      case OrderStatus.confirmed:   return 'Dikonfirmasi';
      case OrderStatus.onTheWay:    return 'Mitra dalam perjalanan';
      case OrderStatus.inProgress:  return 'Sedang dikerjakan';
      case OrderStatus.completed:   return 'Selesai';
      case OrderStatus.cancelled:   return 'Dibatalkan';
    }
  }

  String get emoji {
    switch (this) {
      case OrderStatus.pending:     return '⏳';
      case OrderStatus.confirmed:   return '✅';
      case OrderStatus.onTheWay:    return '🚗';
      case OrderStatus.inProgress:  return '🔧';
      case OrderStatus.completed:   return '🎉';
      case OrderStatus.cancelled:   return '❌';
    }
  }

  bool get isActive =>
      this != OrderStatus.completed && this != OrderStatus.cancelled;
}

class OrderModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String serviceEmoji;
  final String mitraName;
  final String mitraPhone;
  final double price;
  final String priceUnit;
  final DateTime scheduledAt;
  final String address;
  final OrderStatus status;
  final String? notes;
  final String? paymentMethod;
  final bool isPaid;

  const OrderModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.serviceEmoji,
    required this.mitraName,
    required this.mitraPhone,
    required this.price,
    required this.priceUnit,
    required this.scheduledAt,
    required this.address,
    this.status = OrderStatus.pending,
    this.notes,
    this.paymentMethod,
    this.isPaid = false,
  });

  OrderModel copyWith({
    OrderStatus? status,
    String? paymentMethod,
    bool? isPaid,
  }) =>
      OrderModel(
        id: id,
        serviceId: serviceId,
        serviceName: serviceName,
        serviceEmoji: serviceEmoji,
        mitraName: mitraName,
        mitraPhone: mitraPhone,
        price: price,
        priceUnit: priceUnit,
        scheduledAt: scheduledAt,
        address: address,
        notes: notes,
        status: status ?? this.status,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        isPaid: isPaid ?? this.isPaid,
      );

  String get formattedPrice {
    if (price >= 1000000) return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    if (price >= 1000) return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  String get formattedDate {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${scheduledAt.day} ${months[scheduledAt.month]} ${scheduledAt.year}';
  }

  String get formattedTime {
    final h = scheduledAt.hour.toString().padLeft(2, '0');
    final m = scheduledAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Dummy orders untuk development ──
class DummyOrders {
  static List<OrderModel> get all => [
        OrderModel(
          id: 'ORD-001',
          serviceId: '2',
          serviceName: 'Servis AC Split',
          serviceEmoji: '❄️',
          mitraName: 'Pak Dedi Teknik',
          mitraPhone: '081234567890',
          price: 150000,
          priceUnit: 'unit',
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
          address: 'Jl. Merdeka No. 10, Bogor Tengah',
          status: OrderStatus.onTheWay,
          paymentMethod: 'QRIS',
          isPaid: true,
        ),
        OrderModel(
          id: 'ORD-002',
          serviceId: '3',
          serviceName: 'Bersih-Bersih Rumah',
          serviceEmoji: '🧹',
          mitraName: 'Tim CleanPro',
          mitraPhone: '082345678901',
          price: 200000,
          priceUnit: 'sesi',
          scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
          address: 'Jl. Pahlawan No. 5, Bogor Utara',
          status: OrderStatus.completed,
          paymentMethod: 'GoPay',
          isPaid: true,
        ),
        OrderModel(
          id: 'ORD-003',
          serviceId: '1',
          serviceName: 'Cuci & Setrika Baju',
          serviceEmoji: '👕',
          mitraName: 'Bu Sari',
          mitraPhone: '083456789012',
          price: 7000,
          priceUnit: 'kg',
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          address: 'Jl. Sudirman No. 20, Bogor Selatan',
          status: OrderStatus.confirmed,
          paymentMethod: 'Transfer Bank',
          isPaid: false,
        ),
      ];
}
