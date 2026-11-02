import 'package:flutter/foundation.dart';
import '../models/wallet_transaction_model.dart';

/// Sumber tunggal saldo & riwayat JasaKu Pay. Dipakai oleh halaman dompet
/// dan halaman pembayaran sehingga keduanya selalu sinkron.
/// TODO: ganti dengan data dari backend saat siap.
class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal() {
    _seed();
  }

  double _balance = 125000;
  final List<WalletTransaction> _txs = [];

  double get balance => _balance;

  /// Terbaru di atas.
  List<WalletTransaction> get transactions => List.unmodifiable(_txs);

  bool canAfford(double amount) => amount > 0 && amount <= _balance;

  void topUp(double amount, {String description = 'Top Up via JasaKu Pay'}) {
    if (amount <= 0) return;
    _balance += amount;
    _record(WalletTxType.topup, amount, description);
  }

  /// Mengembalikan false bila saldo tidak cukup (saldo tidak berubah).
  bool withdraw(double amount, {String description = 'Tarik ke rekening'}) {
    if (!canAfford(amount)) return false;
    _balance -= amount;
    _record(WalletTxType.withdrawal, amount, description);
    return true;
  }

  /// Bayar pesanan memakai saldo. Mengembalikan false bila saldo tidak cukup.
  bool pay(double amount, {required String description}) {
    if (!canAfford(amount)) return false;
    _balance -= amount;
    _record(WalletTxType.payment, amount, description);
    return true;
  }

  void refund(double amount, {required String description}) {
    if (amount <= 0) return;
    _balance += amount;
    _record(WalletTxType.refund, amount, description);
  }

  String get formattedBalance {
    if (_balance >= 1000000) return 'Rp ${(_balance / 1000000).toStringAsFixed(1)}jt';
    if (_balance >= 1000) return 'Rp ${(_balance / 1000).toStringAsFixed(0)}.000';
    return 'Rp ${_balance.toStringAsFixed(0)}';
  }

  void _record(WalletTxType type, double amount, String description) {
    _txs.insert(0, WalletTransaction(
      id: 'WTX-${DateTime.now().microsecondsSinceEpoch}',
      description: description,
      amount: amount,
      type: type,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  // Data awal (dummy) — hapus saat backend siap
  void _seed() {
    final now = DateTime.now();
    _txs.addAll([
      WalletTransaction(id: 'WTX-001', description: 'Top Up via GoPay',
          amount: 100000, type: WalletTxType.topup,
          date: now.subtract(const Duration(hours: 2))),
      WalletTransaction(id: 'WTX-002', description: 'Bayar Servis AC Split',
          amount: 150000, type: WalletTxType.payment,
          date: now.subtract(const Duration(days: 1))),
      WalletTransaction(id: 'WTX-003', description: 'Refund Pesanan ORD-005',
          amount: 75000, type: WalletTxType.refund,
          date: now.subtract(const Duration(days: 2))),
      WalletTransaction(id: 'WTX-004', description: 'Top Up via Transfer BCA',
          amount: 200000, type: WalletTxType.topup,
          date: now.subtract(const Duration(days: 3))),
      WalletTransaction(id: 'WTX-005', description: 'Bayar Bersih-Bersih Rumah',
          amount: 100000, type: WalletTxType.payment,
          date: now.subtract(const Duration(days: 5))),
      WalletTransaction(id: 'WTX-006', description: 'Tarik ke BCA ••4521',
          amount: 50000, type: WalletTxType.withdrawal,
          date: now.subtract(const Duration(days: 7))),
    ]);
  }
}
