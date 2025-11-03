import 'package:doro_gear/localization/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../helpers/enums/category.dart';
import '../../helpers/formatter.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/home_widgets/product_grid_card.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  ProductCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await ProductService.loadProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.brand.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _addProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductFormPage(),
      ),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  void _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormPage(product: product),
      ),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  void _deleteProduct(Product product) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate('confirmDelete')),
        content: Text('${t.translate('deleteProductConfirm')} "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allProducts.removeWhere((p) => p.id == product.id);
                _filterProducts();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.translate('productDeleted'))),
              );
            },
            child: Text(t.translate('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(t.translate('productManagement')),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(t),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? Center(child: Text(t.translate('noProductsFound')))
                : _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(t.translate('addProduct'), style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSearchAndFilter(AppLocalizations t) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: t.translate('searchProduct'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterProducts();
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(t.translate('all'), null, t),
                ...ProductCategory.values.map(
                      (category) => _buildCategoryChip(
                    category.displayName,
                    category,
                    t,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, ProductCategory? category, AppLocalizations t) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
            _filterProducts();
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final t = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _editProduct(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ProductImagePlaceholder(imageUrl: product.image),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PriceFormatter.format(product.price.toDouble()),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.inventory, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${t.translate('stock')}: ${product.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.stock > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editProduct(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(product),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _stockController;
  late TextEditingController _brandController;
  late TextEditingController _warrantyController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;

  ProductCategory _selectedCategory = ProductCategory.cpu;
  final Map<String, TextEditingController> _specControllers = {};

  @override
  void initState() {
    super.initState();
    final product = widget.product;

    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(text: product?.price.toString() ?? '');
    _originalPriceController = TextEditingController(text: product?.originalPrice.toString() ?? '');
    _stockController = TextEditingController(text: product?.stock.toString() ?? '');
    _brandController = TextEditingController(text: product?.brand ?? '');
    _warrantyController = TextEditingController(text: product?.warranty ?? '12 tháng');
    _descriptionController = TextEditingController(text: product?.description ?? '');
    _imageController = TextEditingController(text: product?.image ?? '');

    if (product != null) {
      _selectedCategory = product.category;
      product.specs.forEach((key, value) {
        _specControllers[key] = TextEditingController(text: value);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _warrantyController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _specControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _addSpec() {
    showDialog(
      context: context,
      builder: (context) {
        final keyController = TextEditingController();
        final valueController = TextEditingController();

        return AlertDialog(
          title: const Text('Thêm thông số'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'Tên thông số',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Giá trị',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
                  setState(() {
                    _specControllers[keyController.text] = TextEditingController(text: valueController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final specs = <String, String>{};
      _specControllers.forEach((key, controller) {
        specs[key] = controller.text;
      });

      final _ = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        category: _selectedCategory,
        price: int.parse(_priceController.text),
        originalPrice: int.parse(_originalPriceController.text),
        rating: widget.product?.rating ?? 5.0,
        soldCount: widget.product?.soldCount ?? 0,
        stock: int.parse(_stockController.text),
        brand: _brandController.text,
        warranty: _warrantyController.text,
        description: _descriptionController.text,
        specs: specs,
        image: _imageController.text.isEmpty ? null : _imageController.text,
      );

      Navigator.pop(context, true);

      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product == null
              ? t.translate('productAdded')
              : t.translate('productUpdated')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? t.translate('editProduct') : t.translate('addProduct')),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              title: 'Thông tin cơ bản',
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: t.translate('productName'),
                  validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập tên sản phẩm' : null,
                ),
                const SizedBox(height: 12),
                _buildDropdown(t),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _brandController,
                  label: t.translate('brand'),
                  validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập thương hiệu' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Giá và kho',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _priceController,
                        label: t.translate('price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Vui lòng nhập giá';
                          if (int.tryParse(value!) == null) return 'Giá không hợp lệ';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _originalPriceController,
                        label: 'Giá gốc',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Vui lòng nhập giá gốc';
                          if (int.tryParse(value!) == null) return 'Giá không hợp lệ';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _stockController,
                        label: t.translate('stock'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Vui lòng nhập số lượng';
                          if (int.tryParse(value!) == null) return 'Số lượng không hợp lệ';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _warrantyController,
                        label: t.translate('warranty'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Hình ảnh',
              children: [
                _buildTextField(
                  controller: _imageController,
                  label: 'URL hình ảnh',
                  maxLines: 2,
                ),
                if (_imageController.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ProductImagePlaceholder(imageUrl: _imageController.text),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: t.translate('description'),
              children: [
                _buildTextField(
                  controller: _descriptionController,
                  label: t.translate('description'),
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Thông số kỹ thuật',
              children: [
                ..._specControllers.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: entry.value,
                          label: entry.key,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            entry.value.dispose();
                            _specControllers.remove(entry.key);
                          });
                        },
                      ),
                    ],
                  ),
                )),
                OutlinedButton.icon(
                  onPressed: _addSpec,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm thông số'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEdit ? t.translate('updateProduct') : t.translate('addProduct'),
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown(AppLocalizations t) {
    return DropdownButtonFormField<ProductCategory>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Danh mục',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: ProductCategory.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
        }
      },
    );
  }
}