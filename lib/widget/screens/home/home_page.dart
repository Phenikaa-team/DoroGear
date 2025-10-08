import 'package:flutter/material.dart' hide SearchBar;

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../models/shop_function.dart';
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

  List<Product> _generateProducts(int count) {
    return List.generate(
      count,
      (index) => Product(
        name:
            'CPU Intel Core i5-14400F (Up To 4.60GHz, 10 Nhân 16 Luồng, 20 MB Cache, LGA 1700)',
        price: 1999 + (index * 100),
        originalPrice: 3000 + (index * 150),
        rating: 4.5 + (index * 0.05),
        soldCount: (index + 1) * 50,
      ),
    );
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
      body: _buildBody(),
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
      title: const SearchBar(),
      actions: const [NotificationButton(), CartButton(itemCount: 0)],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          //const SizedBox(height: 12),
          const BannerCarousel(),
          const SizedBox(height: 12),
          ShopFunctionsGrid(functions: _shopFunctions),
          const SizedBox(height: 12),
          HotProductsRow(products: _generateProducts(5)),
          const SizedBox(height: 12),
          ProductGridSection(
            title: 'CPU - Vi xử lý',
            products: _generateProducts(10),
          ),
          const SizedBox(height: 12),
          ProductGridSection(
            title: 'Mainboard - Bo mạch chủ',
            products: _generateProducts(10),
          ),
          const SizedBox(height: 12),
          ProductGridSection(
            title: 'RAM - Bộ nhớ trong',
            products: _generateProducts(10),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
