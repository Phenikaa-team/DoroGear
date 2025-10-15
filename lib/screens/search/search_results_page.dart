import 'package:doro_gear/localization/app_localizations.dart';
import 'package:doro_gear/models/product.dart';
import 'package:doro_gear/widgets/home_widgets/product_grid_card.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class SearchResultsPage extends StatelessWidget {
  final String searchQuery;
  final List<Product> allProducts;

  const SearchResultsPage({
    super.key,
    required this.searchQuery,
    required this.allProducts,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final List<Product> results = allProducts
        .where((product) => product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          t.translate('searchResultsFor').replaceAll('{query}', searchQuery),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Container(
            color: AppColors.secondaryColor,
            padding: const EdgeInsets.only(bottom: 8),
            alignment: Alignment.center,
            child: Text(
              t.translate('resultsFound').replaceAll('{count}', results.length.toString()),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
      body: results.isEmpty
          ? _buildEmptyState(t)
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 260.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) => ProductGridCard(product: results[index]),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            t.translate('noResultsFound'),
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}