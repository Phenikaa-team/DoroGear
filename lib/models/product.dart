import '../helpers/enums/category.dart';

class Product {
  final String id;
  final String name;
  final ProductCategory category;
  final int price;
  final int originalPrice;
  final double rating;
  final int soldCount;
  final int stock;
  final String? image;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.soldCount,
    required this.stock,
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
    );
  }

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
  };
}