import 'package:flutter/material.dart';

import '../../constants/Constants.dart';
import '../../constants/app_colors.dart';
import '../../constants/assets.dart';
import '../../helpers/formatter.dart';
import '../../localization/app_localizations.dart';
import '../../models/product.dart';
import '../../screens/product/product_detail_page.dart';

class ProductImagePlaceholder extends StatelessWidget {
  final double? size;
  final String? imageUrl;
  const ProductImagePlaceholder({super.key, this.size = 40, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primaryColor,
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildFallback(context),
      );
    }

    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return Assets.placeHolder.isNotEmpty
        ? Image.asset(Assets.placeHolder, fit: BoxFit.contain)
        : Center(
      child: Icon(Icons.shopping_bag, size: size, color: Colors.grey[400]),
    );
  }
}

class ProductSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final String? actionText;
  final VoidCallback? onActionTap;

  const ProductSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
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

  Widget _buildImage() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: product.image != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.image!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ProductImagePlaceholder(size: 40),
        ),
      )
          : const ProductImagePlaceholder(size: 40),
    );
  }


  Widget _buildPrices() {
    final discount = ((product.originalPrice - product.price) / product.originalPrice * 100).toInt();
    final isDiscounted = product.price < product.originalPrice && product.originalPrice > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDiscounted)
          Text(
            PriceFormatter.format(product.originalPrice.toDouble()),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              decoration: TextDecoration.lineThrough,
              height: 1.0,
            ),
          ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              PriceFormatter.format(product.price.toDouble()),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: accentColor,
                height: 1.0,
              ),
            ),

            const SizedBox(width: 6),

            if (isDiscounted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Text(
                  '-$discount%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.red,
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

  Widget _buildRatingAndSales(BuildContext context) {
    final t = AppLocalizations.of(context)!;
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
            "${t.translate('sold')} ${product.soldCount}",
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
      ),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            const SizedBox(height: 6),
            Text(
              product.name,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _buildPrices(),
            const SizedBox(height: 4),
            _buildRatingAndSales(context),
          ],
        ),
      ),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Product product;

  const ProductGridCard({super.key, required this.product});

  Widget _buildImage(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Container(
          height: 130,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: product.image != null
              ? ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              product.image!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const ProductImagePlaceholder(),
            ),
          )
              : const ProductImagePlaceholder(),
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
            child: Text(
              t.translate('hot'),
              style: const TextStyle(
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

  Widget _buildPrices() {
    final discount = ((product.originalPrice - product.price) / product.originalPrice * 100).toInt();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            PriceFormatter.format(product.price.toDouble()),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.red,
              height: 1.0,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              PriceFormatter.format(product.originalPrice.toDouble()),
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

  Widget _buildVoucherBanner(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: Colors.cyan[50], borderRadius: BorderRadius.circular(4)),
      child: Text(
        t.translate('voucherBannerExample'),
        style: TextStyle(fontSize: 10, color: Colors.cyan[700], fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRatingAndStock(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          '${product.rating.toStringAsFixed(1)}/5.0',
          style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.check_circle, size: 14, color: Colors.green),
        const SizedBox(width: 4),
        Expanded(child: Text(t.translate('inStock'), style: TextStyle(fontSize: 11, color: Colors.grey[700]))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async => await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey[900], height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildPrices(),
                  const SizedBox(height: 4),
                  _buildVoucherBanner(context),
                  const SizedBox(height: 4),
                  _buildRatingAndStock(context),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildProductList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          ProductCard(product: products[index], accentColor: accentColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Constants.productSectionHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductSectionHeader(
            title: title,
            icon: Icons.local_fire_department,
            iconColor: accentColor,
          ),
          SizedBox(
              height: Constants.productSectionHeight - 48, child: _buildProductList()),
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

class ProductGridSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final String viewMoreText;

  const ProductGridSection({
    super.key,
    required this.title,
    required this.products,
    required this.viewMoreText,
  });

  Widget _buildProductGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double targetItemWidth = 175.0;
        final double availableWidth = constraints.maxWidth - 24;
        final int crossAxisCount =
        (availableWidth / targetItemWidth).floor().clamp(2, 2);

        const double cardHeight = 250.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: cardHeight,
            crossAxisSpacing: 5,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length > 6 ? 6 : products.length,
          itemBuilder: (context, index) =>
              ProductGridCard(product: products[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductSectionHeader(
              title: title,
              actionText: viewMoreText,
            ),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }
}