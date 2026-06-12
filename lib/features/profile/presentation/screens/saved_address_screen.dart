import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/address_model.dart';
import '../../../../shared/widgets/location_picker_sheet.dart';

class SavedAddressScreen extends StatefulWidget {
  const SavedAddressScreen({super.key});

  @override
  State<SavedAddressScreen> createState() => _SavedAddressScreenState();
}

class _SavedAddressScreenState extends State<SavedAddressScreen> {
  final List<_SavedAddr> _addresses = [
    _SavedAddr(label: 'Rumah', icon: Icons.home_outlined,
        address: 'Jl. Merdeka No. 10, RT 02/03\nBogor Tengah, Kota Bogor, Jawa Barat',
        isPrimary: true),
    _SavedAddr(label: 'Kantor', icon: Icons.business_outlined,
        address: 'Jl. Sudirman No. 45, Lt. 3\nBogor Selatan, Kota Bogor, Jawa Barat',
        isPrimary: false),
  ];

  void _openPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationPickerSheet(
        onSelected: (addr) {
          setState(() {
            _addresses.add(_SavedAddr(
              label: 'Lokasi Baru',
              icon: Icons.location_on_outlined,
              address: addr.fullAddress,
              isPrimary: false,
            ));
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Alamat berhasil ditambahkan'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        },
      ),
    );
  }

  void _setPrimary(int index) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _SavedAddr(
          label: _addresses[i].label,
          icon: _addresses[i].icon,
          address: _addresses[i].address,
          isPrimary: i == index,
        );
      }
    });
  }

  void _delete(int index) {
    if (_addresses[index].isPrimary) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Alamat utama tidak bisa dihapus'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _addresses.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Alamat Tersimpan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          ...List.generate(_addresses.length, (i) {
            final addr = _addresses[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: addr.isPrimary
                      ? AppColors.primary.withOpacity(0.4)
                      : AppColors.border,
                  width: addr.isPrimary ? 1.5 : 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(addr.icon, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(addr.label, style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(width: 8),
                      if (addr.isPrimary)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Utama',
                              style: TextStyle(fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      const Spacer(),
                      // Menu opsi
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            color: AppColors.textHint, size: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        onSelected: (val) {
                          if (val == 'primary') _setPrimary(i);
                          if (val == 'delete') _delete(i);
                        },
                        itemBuilder: (_) => [
                          if (!addr.isPrimary)
                            const PopupMenuItem(value: 'primary',
                                child: Row(children: [
                                  Icon(Icons.star_outline_rounded,
                                      size: 18, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('Jadikan Utama'),
                                ])),
                          const PopupMenuItem(value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete_outline_rounded,
                                    size: 18, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Hapus',
                                    style: TextStyle(color: AppColors.error)),
                              ])),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(addr.address, style: const TextStyle(fontSize: 13,
                        color: AppColors.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            );
          }),

          // Tombol tambah alamat
          GestureDetector(
            onTap: _openPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4),
                    style: BorderStyle.solid),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_location_alt_outlined,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Tambah Alamat Baru',
                      style: TextStyle(fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedAddr {
  final String label, address;
  final IconData icon;
  final bool isPrimary;
  const _SavedAddr({required this.label, required this.address,
      required this.icon, required this.isPrimary});
}
