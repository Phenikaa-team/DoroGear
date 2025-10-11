import '../helpers/enums/category.dart';
import 'model_interfaces.dart';

class Product implements IModel {
  final String id;
  final String name;
  final ProductCategory category;
  final int price;
  final int originalPrice;
  final double rating;
  final int soldCount;
  final int stock;
  final String? image;

  final String brand;
  final String warranty;
  final String description;
  final Map<String, String> specs;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.soldCount,
    required this.stock,
    required this.brand,
    required this.warranty,
    required this.description,
    required this.specs,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final categoryStr = json['category'] as String;
    final category = ProductCategory.fromString(categoryStr) ?? ProductCategory.cpu;

    return Product(
      id: json['id'],
      name: json['name'],
      category: category,
      price: json['price'],
      originalPrice: json['originalPrice'],
      rating: (json['rating'] as num).toDouble(),
      soldCount: json['soldCount'],
      stock: json['stock'],
      image: json['image'],
      brand: json['brand'] as String? ?? 'Chưa rõ',
      warranty: json['warranty'] as String? ?? '12 tháng',
      description: json['description'] as String? ?? 'Sản phẩm chất lượng cao.',
      specs: Map<String, String>.from(json['specs'] ?? {}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'price': price,
    'originalPrice': originalPrice,
    'rating': rating,
    'soldCount': soldCount,
    'stock': stock,
    'image': image,
    'brand': brand,
    'warranty': warranty,
    'description': description,
    'specs': specs,
  };
}