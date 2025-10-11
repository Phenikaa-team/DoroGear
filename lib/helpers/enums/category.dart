enum ProductCategory {
  cpu(1, 'CPU - Vi xử lý'),
  mainboard(2, 'Mainboard - Bo mạch chủ'),
  ram(3, 'RAM - Bộ nhớ trong'),
  gpu(4, 'GPU - Card màn hình'),
  storage(5, 'Storage- Ổ cứng'),
  psu(6, 'PSU - Nguồn máy tính'),
  cooler(7, 'Cooler - Tản nhiệt'),
  pcCase(8, 'Case - Vỏ máy tính');

  final int priority;
  final String displayName;

  const ProductCategory(this.priority, this.displayName);

  static ProductCategory? fromString(String value) {
    try {
      return ProductCategory.values.firstWhere(
            (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  int compareTo(ProductCategory other) {
    return priority.compareTo(other.priority);
  }

  static List<ProductCategory> getSortedCategories() {
    final categories = ProductCategory.values.toList();
    categories.sort((a, b) => a.compareTo(b));
    return categories;
  }

  String get iconName {
    switch (this) {
      case ProductCategory.cpu:
        return 'memory';
      case ProductCategory.gpu:
        return 'videogame_asset';
      case ProductCategory.mainboard:
        return 'developer_board';
      case ProductCategory.ram:
        return 'storage';
      case ProductCategory.storage:
        return 'sd_storage';
      case ProductCategory.psu:
        return 'power';
      case ProductCategory.cooler:
        return 'ac_unit';
      case ProductCategory.pcCase:
        return 'computer';
    }
  }
}