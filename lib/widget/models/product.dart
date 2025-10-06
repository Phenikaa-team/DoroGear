class Product {
  final String name;
  final int price;
  final int originalPrice;
  final double rating;
  final int soldCount;
  final String? imageUrl;

  const Product({
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.soldCount,
    this.imageUrl,
  });
}
