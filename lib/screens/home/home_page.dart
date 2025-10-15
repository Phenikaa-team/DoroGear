import 'package:doro_gear/helpers/enums/category.dart';
import 'package:doro_gear/localization/app_localizations.dart';
import 'package:flutter/material.dart' hide SearchBar;

import '../../constants/app_colors.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../models/shop_function.dart';
import '../../services/product_service.dart';
import '../../widgets/home_widgets/banner_carousel.dart';
import '../../widgets/home_widgets/product_grid_card.dart';
import '../../widgets/home_widgets/shop_functions_grid.dart';
import '../../widgets/shared/appbar_actions.dart';
import '../../widgets/shared/custom_bottom_nav_bar.dart';
import '../../widgets/shared/search_bar.dart';
import '../account/account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Product> _allProducts = [];
  bool _isLoading = true;

  List<ShopFunction> _shopFunctions = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeShopFunctions();
  }

  void _initializeShopFunctions() {
    final t = AppLocalizations.of(context)!;
    _shopFunctions = [
      ShopFunction(icon: Icons.computer, label: t.translate('buildPC'), color: Colors.blueAccent),
      ShopFunction(icon: Icons.card_giftcard, label: t.translate('vouchers'), color: Colors.red),
      ShopFunction(icon: Icons.category, label: t.translate('categories'), color: AppColors.primaryColor),
      ShopFunction(icon: Icons.star, label: t.translate('topDeals'), color: Colors.amber),
      //ShopFunction(icon: Icons.flash_on, label: t.translate('flashSale'), color: Colors.orange),
      //ShopFunction(icon: Icons.local_shipping, label: t.translate('freeShip'), color: Colors.blue),
      //ShopFunction(icon: Icons.local_offer, label: t.translate('discounts'), color: Colors.purple),
      //ShopFunction(icon: Icons.new_releases, label: t.translate('newArrivals'), color: Colors.green),
      //ShopFunction(icon: Icons.more_horiz, label: t.translate('more'), color: Colors.grey),
    ];
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.loadProducts();
      if (mounted) {
        setState(() {
          _allProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading products: $e');
    }
  }

  List<Product> _getProductsByCategory(ProductCategory category) =>
      _allProducts.where((p) => p.category == category).toList();

  List<Product> _getHotProducts() {
    final sorted = List<Product>.from(_allProducts)
      ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
    return sorted.take(5).toList();
  }

  List<ProductCategory> _getAvailableCategories() {
    return _allProducts.map((p) => p.category).toSet().toList()
      ..sort((a, b) => a.compareTo(b));
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildContent(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final t = AppLocalizations.of(context)!;
    if (_selectedIndex == 4) {
      return AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(t.translate('account'), style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      );
    }
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      title: CustomSearchBar(hintText: t.translate('searchProductHint')),
      actions: [const NotificationButton(), CartButton(itemCount: Cart.items.length)],
    );
  }

  Widget _buildContent() {
    final List<Widget> pages = [
      _buildHomeBody(),
      _buildHomeBody(),
      _buildHomeBody(),
      _buildHomeBody(),
      const AccountPage(),
    ];
    return pages[_selectedIndex];
  }

  Widget _buildHomeBody() {
    final hotProducts = _getHotProducts();
    final categories = _getAvailableCategories();
    final t = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        children: [
          const BannerCarousel(),
          const SizedBox(height: 12),
          ShopFunctionsGrid(functions: _shopFunctions),
          const SizedBox(height: 12),
          if (hotProducts.isNotEmpty) ...[
            HotProductsRow(
              hotProducts: hotProducts,
              bestSellingProducts: hotProducts.reversed.toList(),
            ),
            const SizedBox(height: 12),
          ],
          ...categories.map((category) {
            final products = _getProductsByCategory(category);
            if (products.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                ProductGridSection(
                  title: category.displayName,
                  products: products,
                  viewMoreText: t.translate('viewMore'),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class HotProductsRow extends StatelessWidget {
  final List<Product> hotProducts;
  final List<Product> bestSellingProducts;

  const HotProductsRow({
    super.key,
    required this.hotProducts,
    required this.bestSellingProducts,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          ProductSection(
            title: t.translate('hotProducts'),
            accentColor: Colors.red,
            products: hotProducts,
          ),
          const SizedBox(height: 12),
          ProductSection(
            title: t.translate('bestSelling'),
            accentColor: Colors.orange,
            products: bestSellingProducts,
          ),
        ],
      ),
    );
  }
}