import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../home/presentation/widgets/service_card.dart';

class SearchScreen extends StatefulWidget {
  // Opsional: jika diisi, langsung filter kategori ini saat dibuka
  final String? initialCategory;

  const SearchScreen({super.key, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<ServiceModel> _results = DummyServices.all;
  String? _activeCategory;

  @override
  void initState() {
    super.initState();
    // Jika ada kategori awal dari klik kategori di home, langsung filter
    if (widget.initialCategory != null) {
      _activeCategory = widget.initialCategory;
      _filterByCategory(widget.initialCategory!);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _search(String q) {
    setState(() {
      _activeCategory = null; // reset filter kategori saat user ketik
      _results = q.isEmpty
          ? DummyServices.all
          : DummyServices.all.where((s) =>
              s.name.toLowerCase().contains(q.toLowerCase()) ||
              s.category.toLowerCase().contains(q.toLowerCase()) ||
              s.mitra.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _activeCategory = category;
      _ctrl.clear();
      _results = DummyServices.all
          .where((s) => s.category == category)
          .toList();
    });
  }

  void _clearCategory() {
    setState(() {
      _activeCategory = null;
      _results = DummyServices.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Jika dibuka via Navigator.push (dari kategori home),
    // tampilkan tombol back
    final bool pushedFromHome = widget.initialCategory != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: pushedFromHome,
        leading: pushedFromHome
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    size: 18, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Padding(
          padding: EdgeInsets.only(
            left: pushedFromHome ? 0 : 16,
            right: 16,
          ),
          child: TextField(
            controller: _ctrl,
            onChanged: _search,
            autofocus: pushedFromHome, // auto fokus jika dari kategori
            decoration: InputDecoration(
              hintText: _activeCategory != null
                  ? 'Cari di $_activeCategory...'
                  : 'Cari layanan, kategori, atau mitra...',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
              border: InputBorder.none,
              filled: false,
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textHint, size: 20),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _ctrl.clear();
                        _search('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chip kategori aktif ──
          if (_activeCategory != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_activeCategory!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _clearCategory,
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: AppColors.primary),
                    ),
                  ]),
                ),
                const SizedBox(width: 8),
                Text('${_results.length} layanan ditemukan',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),

          // ── Filter kategori horizontal (chip row) ──
          if (_activeCategory == null)
            _CategoryChipRow(
              categories: DummyServices.categories
                  .map((c) => c.$2)
                  .toList(),
              onSelect: _filterByCategory,
            ),

          // ── List hasil ──
          Expanded(
            child: _results.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: _results.length,
                    itemBuilder: (_, i) =>
                        ServiceCard(service: _results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Chip row filter kategori ──
class _CategoryChipRow extends StatelessWidget {
  final List<String> categories;
  final void Function(String) onSelect;
  const _CategoryChipRow({required this.categories, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onSelect(categories[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(categories[i],
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary)),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('😕', style: TextStyle(fontSize: 48)),
        SizedBox(height: 12),
        Text('Layanan tidak ditemukan',
            style: TextStyle(fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        SizedBox(height: 4),
        Text('Coba kata kunci lain',
            style: TextStyle(fontSize: 13,
                color: AppColors.textSecondary)),
      ]),
    );
  }
}
