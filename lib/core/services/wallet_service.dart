// Wallet service — saldo global yang bisa diakses dari payment & wallet screen
class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  double _balance = 125000;

  double get balance => _balance;

  void topUp(double amount) => _balance += amount;
  void deduct(double amount) => _balance -= amount;

  String get formattedBalance {
    if (_balance >= 1000000) return 'Rp ${(_balance/1000000).toStringAsFixed(1)}jt';
    if (_balance >= 1000) return 'Rp ${(_balance/1000).toStringAsFixed(0)}.000';
    return 'Rp ${_balance.toStringAsFixed(0)}';
  }
}
