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
  String? _activeCategory;
  bool _todayOnly = false; // ── Same Day Service filter ──

  List<ServiceModel> get _baseList {
    var list = DummyServices.all;
    if (_activeCategory != null) {
      list = list.where((s) => s.category == _activeCategory).toList();
    }
    if (_ctrl.text.isNotEmpty) {
      final q = _ctrl.text.toLowerCase();
      list = list.where((s) =>
          s.name.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q) ||
          s.mitra.toLowerCase().contains(q)).toList();
    }
    if (_todayOnly) {
      list = list.where((s) => s.isAvailableToday).toList();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _activeCategory = widget.initialCategory;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _filterByCategory(String category) {
    setState(() {
      _activeCategory = category;
      _ctrl.clear();
    });
  }

  void _clearCategory() => setState(() => _activeCategory = null);

  @override
  Widget build(BuildContext context) {
    final bool pushedFromHome = widget.initialCategory != null;
    final results = _baseList;
    final todayCount = DummyServices.all.where((s) => s.isAvailableToday).length;

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
          padding: EdgeInsets.only(left: pushedFromHome ? 0 : 16, right: 16),
          child: TextField(
            controller: _ctrl,
            onChanged: (_) => setState(() {}),
            autofocus: pushedFromHome,
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
                        setState(() {});
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
          // ── Filter Same Day Service ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: () => setState(() => _todayOnly = !_todayOnly),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _todayOnly
                      ? AppColors.warning.withOpacity(0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _todayOnly
                        ? AppColors.warning
                        : AppColors.border,
                    width: _todayOnly ? 1.5 : 0.5,
                  ),
                ),
                child: Row(children: [
                  Icon(Icons.bolt_rounded,
                      size: 18,
                      color: _todayOnly
                          ? AppColors.warning
                          : AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tersedia Hari Ini',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _todayOnly
                                ? AppColors.warning
                                : AppColors.textPrimary,
                          )),
                      Text('$todayCount mitra bisa datang hari ini juga',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint)),
                    ],
                  )),
                  Switch(
                    value: _todayOnly,
                    onChanged: (v) => setState(() => _todayOnly = v),
                    activeColor: AppColors.warning,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ]),
              ),
            ),
          ),

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
                Text('${results.length} layanan ditemukan',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),

          // ── Filter kategori horizontal (chip row) ──
          if (_activeCategory == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _CategoryChipRow(
                categories: DummyServices.categories.map((c) => c.$2).toList(),
                onSelect: _filterByCategory,
              ),
            ),

          // ── List hasil ──
          Expanded(
            child: results.isEmpty
                ? _EmptyState(todayOnly: _todayOnly)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: results.length,
                    itemBuilder: (_, i) =>
                        ServiceCard(service: results[i]),
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
  final bool todayOnly;
  const _EmptyState({required this.todayOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(todayOnly ? '⚡' : '😕', style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
            todayOnly
                ? 'Belum ada mitra tersedia hari ini'
                : 'Layanan tidak ditemukan',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(
            todayOnly
                ? 'Coba nonaktifkan filter atau cari kategori lain'
                : 'Coba kata kunci lain',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }
}
