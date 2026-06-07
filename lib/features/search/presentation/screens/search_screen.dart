import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_model.dart';
import '../../../home/presentation/widgets/service_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<ServiceModel> _results = DummyServices.all;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _search(String q) {
    setState(() {
      _results = q.isEmpty
          ? DummyServices.all
          : DummyServices.all.where((s) =>
              s.name.toLowerCase().contains(q.toLowerCase()) ||
              s.category.toLowerCase().contains(q.toLowerCase()) ||
              s.mitra.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _ctrl,
            onChanged: _search,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Cari layanan, kategori, atau mitra...',
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
      body: _results.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _results.length,
              itemBuilder: (_, i) => ServiceCard(service: _results[i]),
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        SizedBox(height: 4),
        Text('Coba kata kunci lain',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }
}
