import 'package:doro_gear/helpers/formatter.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../widgets/shared/appbar_actions.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  void _incrementQuantity() {
    if (_quantity < widget.product.stock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm $_quantity x ${widget.product.name} vào giỏ hàng!')),
    );
  }

  void _buyNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chuyển đến trang thanh toán (Mua ngay)!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(widget.product.name, style: const TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryColor,
        actions: const [NotificationButton(), CartButton(itemCount: 0)],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Product Image/Carousel
                  _buildProductImage(context),
                  const SizedBox(height: 8),

                  // 2. Product Info (Price, Name, Rating)
                  _buildProductInfo(),
                  const SizedBox(height: 12),

                  // 3. More info
                  _buildGeneralDetails(),
                  const SizedBox(height: 8),

                  // 4. Quantity Selector
                  _buildQuantitySelector(),
                  const SizedBox(height: 8),

                  // 5. Product Specs
                  _buildSpecsSection(),
                  const SizedBox(height: 8),

                  // 6. Product Description
                  _buildDescriptionSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Image.network(
        widget.product.image ?? 'https://via.placeholder.com/400',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
        const Center(child: Icon(Icons.broken_image, size: 100)),
      ),
    );
  }

  Widget _buildProductInfo() {
    final product = widget.product;
    final discount = ((product.originalPrice - product.price) / product.originalPrice * 100).toInt();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                PriceFormatter.format(product.price.toDouble()),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '-$discount%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                  Text(
                    PriceFormatter.format(product.originalPrice.toDouble()),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text('${product.rating.toString()} (${product.soldCount} đã bán)',
                  style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              Text('Còn lại: ${product.stock}', style: TextStyle(
                  color: product.stock > 10 ? Colors.green : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Số lượng', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _decrementQuantity,
                color: _quantity > 1 ? AppColors.primaryColor : Colors.grey,
              ),
              Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _incrementQuantity,
                color: _quantity < widget.product.stock ? AppColors.primaryColor : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralDetails() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.business,
            label: 'Thương hiệu',
            value: widget.product.brand,
            color: Colors.black87,
          ),
          const Divider(height: 16),
          _buildDetailRow(
            icon: Icons.security,
            label: 'Bảo hành',
            value: widget.product.warranty,
            color: Colors.black87,
          ),
          const Divider(height: 16),
          _buildDetailRow(
            icon: Icons.inventory,
            label: 'Kho hàng',
            value: '${widget.product.stock} sản phẩm',
            color: widget.product.stock > 10 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsSection() {
    if (widget.product.specs.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THÔNG SỐ KỸ THUẬT',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 16),
          ...widget.product.specs.entries.map((entry) => _buildSpecRow(entry.key, entry.value)).toList(),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MÔ TẢ SẢN PHẨM',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 16),
          Text(
            widget.product.description,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              key,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hành động: Chat với Shop')),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, color: AppColors.primaryColor),
                  Text('Chat', style: TextStyle(fontSize: 10, color: AppColors.primaryColor)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text('Thêm vào Giỏ hàng', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: _buyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Mua ngay', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}