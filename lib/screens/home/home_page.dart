import 'package:doro_gear/helpers/enums/category.dart';
import 'package:flutter/material.dart' hide SearchBar;

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../models/shop_function.dart';
import '../../services/product_service.dart';
import '../../widgets/home_widgets/banner_carousel.dart';
import '../../widgets/home_widgets/product_grid_card.dart';
import '../../widgets/home_widgets/shop_functions_grid.dart';
import '../../widgets/shared/appbar_actions.dart';
import '../../widgets/shared/custom_bottom_nav_bar.dart';
import '../../widgets/shared/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Product> _allProducts = [];
  bool _isLoading = true;

  final List<ShopFunction> _shopFunctions = [
    ShopFunction(
      icon: Icons.flash_on,
      label: 'Flash Sale',
      color: Colors.orange,
    ),
    ShopFunction(
      icon: Icons.local_shipping,
      label: 'Miễn phí ship',
      color: Colors.blue,
    ),
    ShopFunction(
      icon: Icons.card_giftcard,
      label: 'Voucher',
      color: Colors.red,
    ),
    ShopFunction(
      icon: Icons.category,
      label: 'Danh mục',
      color: AppColors.primaryColor,
    ),
    ShopFunction(icon: Icons.star, label: 'Top Deal', color: Colors.amber),
    ShopFunction(
      icon: Icons.local_offer,
      label: 'Giảm giá',
      color: Colors.purple,
    ),
    ShopFunction(
      icon: Icons.new_releases,
      label: 'Hàng mới',
      color: Colors.green,
    ),
    ShopFunction(icon: Icons.more_horiz, label: 'Thêm', color: Colors.grey),
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.loadProducts();
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading products: $e');
    }
  }

  List<Product> _getProductsByCategory(ProductCategory category) {
    return _allProducts.where((p) => p.category == category).toList();
  }

  List<Product> _getHotProducts() {
    final sorted = List<Product>.from(_allProducts);
    sorted.sort((a, b) => b.soldCount.compareTo(a.soldCount));
    return sorted.take(5).toList();
  }

  List<ProductCategory> _getAvailableCategories() {
    final availableCategories = _allProducts
        .map((p) => p.category)
        .toSet()
        .toList();

    availableCategories.sort((a, b) => a.compareTo(b));

    return availableCategories;
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoading() : _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      title: const CustomSearchBar(),
      actions: const [NotificationButton(), CartButton(itemCount: 0)],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBody() {
    final hotProducts = _getHotProducts();
    final categories = _getAvailableCategories();

    return SingleChildScrollView(
      child: Column(
        children: [
          const BannerCarousel(),
          const SizedBox(height: 12),
          ShopFunctionsGrid(functions: _shopFunctions),
          const SizedBox(height: 12),

          if (hotProducts.isNotEmpty) ...[
            HotProductsRow(products: hotProducts),
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