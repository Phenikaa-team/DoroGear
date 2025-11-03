import 'package:doro_gear/services/user_service.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../helpers/formatter.dart';
import '../../models/cart.dart';
import '../../models/cart_item.dart';
import '../account/signin_page.dart';
import '../checkout/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  @override
  Widget build(BuildContext context) {
    // final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text("Giỏ hàng", style: const TextStyle(fontSize: 20)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Cart.items.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: Cart.items.length,
              itemBuilder: (context, index) {
                final item = Cart.items[index];
                return _buildCartItemCard(item);
              },
            ),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  void _updateState() {
    setState(() {});
  }

  void _incrementQuantity(CartItem item) {
    Cart.incrementQuantity(item);
    _updateState();
  }

  void _decrementQuantity(CartItem item) {
    Cart.decrementQuantity(item);
    _updateState();
  }

  void _toggleItemSelection(CartItem item) {
    Cart.toggleSelect(item);
    _updateState();
  }

  void _toggleSelectAll(bool? value) {
    if (value == null) return;
    Cart.toggleSelectAll(value);
    _updateState();
  }

  void _removeItem(CartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: const Text('Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Cart.remove(item);
              _updateState();
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  bool _areAllSelected() {
    if (Cart.items.isEmpty) return false;
    return Cart.items.every((item) => item.isSelected);
  }

  Future<void> _checkout() async {
    // final t = AppLocalizations.of(context)!;

    if (UserService.isGuest) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Cần đăng nhập'), // t.translate('loginRequired')
            content: const Text('Vui lòng đăng nhập để tiếp tục thanh toán.'), // t.translate('loginToProceed')
            actions: <Widget>[
              TextButton(
                child: const Text('Đóng'), // t.translate('cancel')
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Đăng nhập'), // t.translate('signIn')
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
      return;
    }

    final selectedItems = Cart.selectedItems;
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 sản phẩm.')),
      );
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage.fromCart(
          itemsToCheckout: selectedItems,
        ),
      ),
    );

    _updateState();
  }

  Widget _buildEmptyCart() {
    // final t = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng của bạn đang trống', // t.translate('cartEmpty')
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: item.isSelected,
              onChanged: (_) => _toggleItemSelection(item),
              activeColor: AppColors.primaryColor,
            ),
            Image.network(
              item.product.image ?? 'https://via.placeholder.com/100',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const SizedBox(width: 80, height: 80, child: Icon(Icons.broken_image)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        PriceFormatter.format(item.product.price.toDouble()),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeItem(item),
                        icon: Icon(Icons.delete_outline, color: Colors.grey[600], size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildQuantitySelector(item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed: () => _decrementQuantity(item),
            color: item.quantity > 1 ? Colors.black87 : Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: () => _incrementQuantity(item),
            color: item.quantity < item.product.stock ? Colors.black87 : Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    // final t = AppLocalizations.of(context)!;
    final total = Cart.totalPrice;
    final hasSelectedItems = total > 0;

    return Container(
      padding: EdgeInsets.fromLTRB(0, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _areAllSelected(),
            onChanged: _toggleSelectAll,
            activeColor: AppColors.primaryColor,
          ),
          const Text('Tất cả'), // t.translate('selectAll')
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Tổng cộng: ', // t.translate('total')
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      PriceFormatter.format(total.toDouble()),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Text(
                  '(Đã bao gồm VAT)', // t.translate('vatIncluded')
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: hasSelectedItems ? _checkout : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text(
              'Mua hàng', // t.translate('checkout')
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}