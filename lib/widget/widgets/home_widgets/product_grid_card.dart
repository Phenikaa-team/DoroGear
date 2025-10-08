import 'package:flutter/material.dart';

import '../../constants/Constants.dart';
import '../../constants/app_colors.dart';
import '../../models/product.dart';

class HotProductsRow extends StatelessWidget {
  final List<Product> products;

  const HotProductsRow({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: ProductSection(
              title: 'Sản phẩm HOT',
              accentColor: Colors.red,
              products: products,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProductSection(
              title: 'Bán chạy nhất',
              accentColor: Colors.orange,
              products: products,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSection extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<Product> products;

  const ProductSection({
    super.key,
    required this.title,
    required this.accentColor,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Constants.productSectionHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: accentColor, size: 20),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          ProductCard(product: products[index], accentColor: accentColor),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final Color accentColor;

  const ProductCard({
    super.key,
    required this.product,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          const SizedBox(height: 6),
          _buildName(),
          const SizedBox(height: 4),
          _buildPrices(),
          const SizedBox(height: 4),
          _buildRatingAndSales(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: product.imageUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey[400]),
    );
  }

  Widget _buildName() {
    return Text(
      product.name,
      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPrices() {
    return Row(
      children: [
        Text(
          '₫${product.price}K',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '₫${product.originalPrice}K',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndSales() {
    return Row(
      children: [
        const Icon(Icons.star, size: 12, color: Colors.amber),
        const SizedBox(width: 2),
        Text(
          product.rating.toStringAsFixed(1),
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(width: 4),
        Text('|', style: TextStyle(color: Colors.grey[400])),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Đã bán ${product.soldCount}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ProductGridSection extends StatelessWidget {
  final String title;
  final List<Product> products;

  const ProductGridSection({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(), _buildProductGrid()],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            'Xem thêm >',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length > 6 ? 6 : products.length,
      itemBuilder: (context, index) =>
          ProductGridCard(product: products[index]),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Product product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildName(),
                const SizedBox(height: 4),
                _buildPrices(),
                const SizedBox(height: 4),
                _buildVoucherBanner(),
                const SizedBox(height: 4),
                _buildRatingAndStock(),
                const SizedBox(height: 4),
                _buildBuyButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: product.imageUrl != null
              ? ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            child: Image.network(
              product.imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            ),
          )
              : _buildPlaceholder(),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'HOT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(child: Icon(Icons.memory, size: 50, color: Colors.grey[400]));
  }

  Widget _buildName() {
    return Text(
      product.name,
      style: TextStyle(fontSize: 12, color: Colors.grey[900], height: 1.3),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPrices() {
    final discount =
    ((product.originalPrice - product.price) / product.originalPrice * 100)
        .toInt();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${product.price.toStringAsFixed(3).replaceAll('.', '.')} đ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${product.originalPrice.toStringAsFixed(3).replaceAll(
                  '.', '.')} đ',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                decoration: TextDecoration.lineThrough,
                height: 1.0,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '-$discount%',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoucherBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.cyan[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Giảm thêm 269.000 đ cho hội viên vàng',
        style: TextStyle(
          fontSize: 10,
          color: Colors.cyan[700],
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRatingAndStock() {
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          '${product.rating.toStringAsFixed(1)}/5.0',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.check_circle, size: 14, color: Colors.green),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Sẵn hàng',
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildBuyButton() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: 35,
            height: 28,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[50],
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
                foregroundColor: Colors.orange[300]!,
              ),
              child: Icon(
                  Icons.shopping_cart, color: Colors.orange[700], size: 18),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 28,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: const Text(
                'MUA NGAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
