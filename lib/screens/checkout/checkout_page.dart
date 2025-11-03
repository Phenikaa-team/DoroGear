import 'package:flutter/material.dart';

import '../../helpers/enums/payment_method.dart';
import '../../models/cart.dart';
import '../../models/cart_item.dart';
import '../../models/delivery_address.dart';
import '../../models/product.dart';
import '../../helpers/formatter.dart';
import '../../constants/app_colors.dart';
import '../../services/address_service.dart';
import '../address/delivery_address_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> itemsToCheckout;

  const CheckoutPage.fromCart({
    super.key,
    required this.itemsToCheckout,
  });

  factory CheckoutPage.fromBuyNow({
    required Product product,
    required int quantity,
  }) {
    final tempItem = CartItem(product: product, quantity: quantity, isSelected: true);
    return CheckoutPage.fromCart(itemsToCheckout: [tempItem]);
  }

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod _paymentMethod = PaymentMethod.cod;
  final int _shippingFee = 15000; // Place holder

  DeliveryAddress? _selectedAddress;
  bool _isLoadingAddress = true;

  late int _subtotal;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();

    _subtotal = widget.itemsToCheckout.fold(0, (sum, item) {
      return sum + (item.product.price * item.quantity);
    });
  }

  Future<void> _loadUserAddress() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAddress = true;
    });

    await AddressService.initialize();
    final addresses = AddressService.getAddressesForCurrentUser();

    DeliveryAddress? defaultAddress;
    if (addresses.isNotEmpty) {
      try {
        defaultAddress = addresses.firstWhere((addr) => addr.isDefault);
      } catch (e) {
        defaultAddress = addresses.first;
      }
    }

    if (!mounted) return;
    setState(() {
      _selectedAddress = defaultAddress;
      _isLoadingAddress = false;
    });
  }

  Future<void> _navigateToAddressSelection() async {
    final selected = await Navigator.push<DeliveryAddress>(
      context,
      MaterialPageRoute(
        builder: (context) => const DeliveryAddressPage(isSelecting: true),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedAddress = selected;
      });
    } else if (mounted) {
      _loadUserAddress();
    }
  }

  void _placeOrder() {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đặt hàng thành công'),
          content: Text('Đơn hàng của bạn đã được xác nhận.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Cart.clearSelected();

                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final t = AppLocalizations.of(context)!;
    final total = _subtotal + _shippingFee;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddressSection(),
                  const SizedBox(height: 8),
                  _buildProductList(),
                  const SizedBox(height: 8),
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 8),
                  _buildOrderTotalSection(_subtotal, total),
                ],
              ),
            ),
          ),
          _buildBottomAction(total),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.itemsToCheckout.length,
        itemBuilder: (context, index) {
          final item = widget.itemsToCheckout[index];
          return _buildProductSummary(item);
        },
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 12, endIndent: 12),
      ),
    );
  }

  Widget _buildProductSummary(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Số lượng: ${item.quantity}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            PriceFormatter.format(item.product.price.toDouble()),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    Widget content;
    if (_isLoadingAddress) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_selectedAddress == null) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_location_alt_outlined, size: 32, color: Colors.grey[600]),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng chọn hoặc thêm địa chỉ giao hàng',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      content = Row(
        children: [
          Icon(Icons.location_on_outlined, color: AppColors.primaryColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Địa chỉ nhận hàng',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedAddress!.receiverName} | (${_selectedAddress!.receiverPhone})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_selectedAddress!.details.isNotEmpty ? "${_selectedAddress!.details}, " : ""}${_selectedAddress!.fullAddress}',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      );
    }

    return InkWell(
      onTap: _navigateToAddressSelection,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: content,
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán', // t.translate('paymentMethod')
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          RadioListTile<PaymentMethod>(
            title: const Text('Thanh toán khi nhận hàng (COD)'),
            value: PaymentMethod.cod,
            groupValue: _paymentMethod,
            onChanged: (PaymentMethod? value) {
              if (value != null) {
                setState(() => _paymentMethod = value);
              }
            },
            activeColor: AppColors.primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<PaymentMethod>(
            title: const Text('Thẻ Tín dụng/Ghi nợ'),
            value: PaymentMethod.creditCard,
            groupValue: _paymentMethod,
            onChanged: (PaymentMethod? value) {
              if (value != null) {
                setState(() => _paymentMethod = value);
              }
            },
            activeColor: AppColors.primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotalSection(int subtotal, int total) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng kết đơn hàng', // t.translate('orderSummary')
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildTotalRow(
            'Tạm tính', // t.translate('subtotal')
            PriceFormatter.format(subtotal.toDouble()),
          ),
          const SizedBox(height: 8),
          _buildTotalRow(
            'Phí vận chuyển', // t.translate('shippingFee')
            PriceFormatter.format(_shippingFee.toDouble()),
          ),
          const Divider(height: 20),
          _buildTotalRow(
            'Tổng cộng', // t.translate('total')
            PriceFormatter.format(total.toDouble()),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 17 : 15,
            color: Colors.grey[700],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            color: isTotal ? Colors.red : Colors.black87,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(int total) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tổng thanh toán', // t.translate('totalPayment')
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                PriceFormatter.format(total.toDouble()),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text(
              'Đặt hàng', // t.translate('placeOrder')
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}