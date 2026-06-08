import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/address_model.dart';

class LocationPickerSheet extends StatefulWidget {
  final void Function(AddressModel) onSelected;
  const LocationPickerSheet({super.key, required this.onSelected});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  // Step: 0=provinsi, 1=kota, 2=kecamatan, 3=kelurahan, 4=detail
  int _step = 0;
  String? _province, _city, _district, _village;
  final _detailCtrl    = TextEditingController();
  final _searchCtrl    = TextEditingController();
  String _searchQuery  = '';

  @override
  void dispose() {
    _detailCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _stepTitle {
    switch (_step) {
      case 0: return 'Pilih Provinsi';
      case 1: return 'Pilih Kota / Kabupaten';
      case 2: return 'Pilih Kecamatan';
      case 3: return 'Pilih Kelurahan';
      default: return 'Alamat Detail';
    }
  }

  List<String> get _currentList {
    List<String> list;
    switch (_step) {
      case 0: list = DummyWilayah.provinces;              break;
      case 1: list = DummyWilayah.getCities(_province!);  break;
      case 2: list = DummyWilayah.getDistricts(_city!);   break;
      case 3: list = DummyWilayah.getVillages(_district!);break;
      default: return [];
    }
    if (_searchQuery.isEmpty) return list;
    return list.where((s) =>
        s.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _onSelect(String value) {
    setState(() {
      _searchCtrl.clear();
      _searchQuery = '';
      switch (_step) {
        case 0: _province = value; break;
        case 1: _city     = value; break;
        case 2: _district = value; break;
        case 3: _village  = value; break;
      }
      _step++;
    });
  }

  void _goBack() {
    setState(() {
      _searchCtrl.clear();
      _searchQuery = '';
      _step--;
      switch (_step) {
        case 0: _province = null; break;
        case 1: _city     = null; break;
        case 2: _district = null; break;
        case 3: _village  = null; break;
      }
    });
  }

  void _confirm() {
    if (_detailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Masukkan alamat detail terlebih dahulu'),
        backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
      return;
    }
    final address = AddressModel(
      province: _province!,
      city: _city!,
      district: _district!,
      village: _village!,
      detail: _detailCtrl.text.trim(),
    );
    widget.onSelected(address);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(children: [
            if (_step > 0)
              GestureDetector(
                onTap: _goBack,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary),
                ),
              ),
            Expanded(child: Text(_stepTitle, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
            ),
          ]),
        ),

        // Breadcrumb path
        if (_step > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Wrap(spacing: 4, children: [
              if (_province != null) _Crumb(label: _province!),
              if (_city != null)     _Crumb(label: _city!),
              if (_district != null) _Crumb(label: _district!),
              if (_village != null)  _Crumb(label: _village!),
            ]),
          ),

        const Divider(height: 0),

        // Step 4: isi detail alamat
        if (_step == 4) ...[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20,
                  MediaQuery.of(context).viewInsets.bottom + 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Ringkasan wilayah
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _WilayahRow(icon: Icons.location_city_outlined, label: '$_province'),
                    _WilayahRow(icon: Icons.apartment_outlined, label: '$_city'),
                    _WilayahRow(icon: Icons.holiday_village_outlined, label: '$_district'),
                    _WilayahRow(icon: Icons.home_outlined, label: '$_village', isLast: true),
                  ]),
                ),
                const SizedBox(height: 16),
                const Text('Alamat Detail', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _detailCtrl,
                  maxLines: 3,
                  autofocus: true,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Jl. Merdeka No. 10, RT 02/03',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                    filled: true, fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Gunakan Alamat Ini',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ]),
            ),
          ),
        ] else ...[
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari ${_stepTitle.toLowerCase()}...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                filled: true, fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const Divider(height: 0),
          // Daftar wilayah
          Expanded(
            child: _currentList.isEmpty
                ? const Center(child: Text('Tidak ditemukan',
                    style: TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
                    itemCount: _currentList.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0, indent: 20, endIndent: 20),
                    itemBuilder: (_, i) {
                      final item = _currentList[i];
                      return ListTile(
                        title: Text(item, style: const TextStyle(
                            fontSize: 14, color: AppColors.textPrimary)),
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textHint, size: 18),
                        onTap: () => _onSelect(item),
                      );
                    },
                  ),
          ),
        ],
      ]),
    );
  }
}

class _Crumb extends StatelessWidget {
  final String label;
  const _Crumb({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: const TextStyle(
          fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
    );
  }
}

class _WilayahRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLast;
  const _WilayahRow({required this.icon, required this.label, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      ]),
    );
  }
}
