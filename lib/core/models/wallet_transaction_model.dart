enum WalletTxType { topup, payment, refund, withdrawal }

extension WalletTxTypeX on WalletTxType {
  String get label {
    switch (this) {
      case WalletTxType.topup:      return 'Top Up';
      case WalletTxType.payment:    return 'Pembayaran';
      case WalletTxType.refund:     return 'Refund';
      case WalletTxType.withdrawal: return 'Tarik Saldo';
    }
  }

  String get emoji {
    switch (this) {
      case WalletTxType.topup:      return '💳';
      case WalletTxType.payment:    return '🧾';
      case WalletTxType.refund:     return '↩️';
      case WalletTxType.withdrawal: return '🏦';
    }
  }

  bool get isCredit =>
      this == WalletTxType.topup || this == WalletTxType.refund;
}

class WalletTransaction {
  final String id, description;
  final double amount;
  final WalletTxType type;
  final DateTime date;

  const WalletTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });

  String get formattedAmount {
    final prefix = type.isCredit ? '+' : '-';
    if (amount >= 1000000) return '$prefix Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000)    return '$prefix Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    return '$prefix Rp ${amount.toStringAsFixed(0)}';
  }

  String get formattedDate {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month]} · $h:$m';
  }
}
