import 'package:doro_gear/constants/app_colors.dart';
import 'package:doro_gear/localization/app_localizations.dart';
import 'package:doro_gear/models/product.dart';
import 'package:doro_gear/services/search_history_service.dart';
import 'package:flutter/material.dart';

import '../../helpers/formatter.dart';
import '../product/product_detail_page.dart';
import 'search_results_page.dart';

class SearchPage extends StatefulWidget {
  final List<Product> allProducts;
  const SearchPage({super.key, required this.allProducts});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<Product> _suggestions = [];
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await SearchHistoryService.getHistory();
    if (mounted) {
      setState(() => _history = history);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _suggestions = [];
      } else {
        _suggestions = widget.allProducts
            .where((p) => p.name.toLowerCase().contains(query))
            .take(10)
            .toList();
      }
    });
  }

  Future<void> _onSearchSubmitted(String query) async {
    query = query.trim();
    if (query.isEmpty) return;

    await SearchHistoryService.addTerm(query);
    _loadHistory();
    FocusScope.of(context).unfocus();

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(
            searchQuery: query,
            allProducts: widget.allProducts,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final showHistory = _searchController.text.isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: t.translate('searchHint'),
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
              },
            )
                : null,
          ),
          onSubmitted: _onSearchSubmitted,
        ),
        actions: [
          TextButton(
            onPressed: () => _onSearchSubmitted(_searchController.text),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(t.translate('search')),
          ),
        ],
      ),
      body: showHistory
          ? _buildHistoryList(t)
          : _buildSuggestionList(t),
    );
  }

  Widget _buildHistoryList(AppLocalizations t) {
    if (_history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.translate('recentSearches'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () async {
                  await SearchHistoryService.clearHistory();
                  _loadHistory();
                },
                child: Text(t.translate('clearHistory'), style: const TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _history.map((term) => ActionChip(
            label: Text(term),
            onPressed: () {
              _searchController.text = term;
              _onSearchSubmitted(term);
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionList(AppLocalizations t) {
    return ListView.separated(
      itemCount: _suggestions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = _suggestions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (product.image != null && product.image!.isNotEmpty)
                ? NetworkImage(product.image!)
                : null,
            child: (product.image == null || product.image!.isEmpty)
                ? const Icon(Icons.shopping_bag_outlined)
                : null,
          ),
          title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(PriceFormatter.format(product.price.toDouble()), style: const TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
            );
          },
        );
      },
    );
  }
}