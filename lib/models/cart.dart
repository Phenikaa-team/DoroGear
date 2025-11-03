import 'cart_item.dart';
import 'product.dart';

class Cart {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  static List<CartItem> get selectedItems {
    return _items.where((item) => item.isSelected).toList();
  }

  static int get totalItemCount {
    if (_items.isEmpty) return 0;
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  static int get totalPrice {
    if (_items.isEmpty) return 0;
    return _items.fold(0, (sum, item) {
      return item.isSelected ? sum + (item.product.price * item.quantity) : sum;
    });
  }

  static void add(Product product, [int quantity = 1]) {
    try {
      final existingItem = _items.firstWhere(
            (item) => item.product.id == product.id,
      );
      existingItem.quantity += quantity;
    } catch (e) {
      _items.add(CartItem(product: product, quantity: quantity, isSelected: true));
    }
  }

  static void remove(CartItem item) {
    _items.remove(item);
  }

  static void incrementQuantity(CartItem item) {
    if (item.quantity < item.product.stock) {
      item.quantity++;
    }
  }

  static void decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      remove(item);
    }
  }

  static void toggleSelect(CartItem item) {
    item.isSelected = !item.isSelected;
  }

  static void toggleSelectAll(bool select) {
    for (var item in _items) {
      item.isSelected = select;
    }
  }

  static void clearSelected() {
    _items.removeWhere((item) => item.isSelected);
  }

  static void clearAll() {
    _items.clear();
  }
}