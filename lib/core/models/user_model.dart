class UserModel {
  final String name;
  final String phone;
  final String? email;

  const UserModel({
    required this.name,
    required this.phone,
    this.email,
  });

  String get displayId => phone.isNotEmpty ? '+62 $phone' : (email ?? '-');
  String get initials   => name.isNotEmpty ? name[0].toUpperCase() : 'U';
  String get firstName  => name.split(' ').first;
}
