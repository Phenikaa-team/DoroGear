import 'package:doro_gear/helpers/formatter.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../localization/app_localizations.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/user_service.dart';
import '../../widgets/shared/appbar_actions.dart';
import '../account/signin_page.dart';
import '../checkout/checkout_page.dart';

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
      setState(() => _quantity++);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _showLoginPrompt() async {
    final t = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t.translate('loginRequired')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(t.translate('loginToProceed')),
                Text(t.translate('doYouWantToLogin')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(t.translate('cancel'), style: const TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(t.translate('signIn')),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _addToCart() {
    if (UserService.isGuest) {
      _showLoginPrompt();
      return;
    }
    for (int i = 0; i < _quantity; i++) {
      Cart.add(widget.product);
    }
    setState(() {});

    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
          t.translate('addedToCart')
              .replaceAll('{quantity}', '$_quantity')
              .replaceAll('{productName}', widget.product.name)
      )),
    );
  }

  void _buyNow() {
    if (UserService.isGuest) {
      _showLoginPrompt();
      return;
    }
    // final t = AppLocalizations.of(context)!;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(t.translate('buyNowAction'))),
    // );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          product: widget.product,
          quantity: _quantity,
        ),
      ),
    );
  }

  void _chatWithShop() {
    if (UserService.isGuest) {
      _showLoginPrompt();
      return;
    }
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.translate('chatAction'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(widget.product.name, style: const TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [const NotificationButton(), CartButton(itemCount: Cart.items.length)],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(context),
                  const SizedBox(height: 8),
                  _buildProductInfo(t),
                  const SizedBox(height: 12),
                  _buildGeneralDetails(t),
                  const SizedBox(height: 8),
                  _buildQuantitySelector(t),
                  const SizedBox(height: 8),
                  _buildSpecsSection(t),
                  const SizedBox(height: 8),
                  _buildDescriptionSection(t),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomActions(t),
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

  Widget _buildProductInfo(AppLocalizations t) {
    final product = widget.product;
    final discount = ((product.originalPrice - product.price) /
        product.originalPrice * 100).toInt();

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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 0),
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
              Text('${product.rating} (${product.soldCount} ${t.translate(
                  'sold')})', style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              Text('${t.translate('remaining')}: ${product.stock}',
                  style: TextStyle(
                      color: product.stock > 10 ? Colors.green : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t.translate('quantity'), style: const TextStyle(fontSize: 16)),
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

  Widget _buildGeneralDetails(AppLocalizations t) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(icon: Icons.business, label: t.translate('brand'), value: widget.product.brand, color: Colors.black87),
          const Divider(height: 16),
          _buildDetailRow(icon: Icons.security, label: t.translate('warranty'), value: widget.product.warranty, color: Colors.black87),
          const Divider(height: 16),
          _buildDetailRow(icon: Icons.inventory, label: t.translate('stock'), value: '${widget.product.stock} ${t.translate('products')}', color: widget.product.stock > 10 ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _buildSpecsSection(AppLocalizations t) {
    if (widget.product.specs.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            t.translate('specs'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 16),
          ...widget.product.specs.entries.map((entry) =>
              _buildSpecRow(entry.key, entry.value)).toList(),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(AppLocalizations t) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.translate('description'),
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

  Widget _buildBottomActions(AppLocalizations t) {
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
              onPressed: _chatWithShop,
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, color: AppColors.primaryColor),
                  Text(t.translate('chat'), style: TextStyle(fontSize: 10, color: AppColors.primaryColor)),
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
                label: Text(t.translate('addToCart'), style: TextStyle(color: Colors.white)),
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
                child: Text(t.translate('buyNow'), style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}