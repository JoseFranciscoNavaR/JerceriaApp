import 'package:hive/hive.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class DatabaseService {
  // Boxes for data storage
  final Box<Product> _productBox = Hive.box<Product>('products');
  final Box<Category> _categoryBox = Hive.box<Category>('categories');

  // Product-related methods
  List<Product> getProducts() {
    return _productBox.values.toList();
  }

  Future<void> addProduct(Product product) async {
    await _productBox.put(product.id, product);
  }

  Future<void> updateProduct(Product product) async {
    await _productBox.put(product.id, product);
  }

  Future<void> deleteProduct(String productId) async {
    await _productBox.delete(productId);
  }

  // Category-related methods
  List<Category> getCategories() {
    return _categoryBox.values.toList();
  }

  Future<void> addCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> updateCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> updateCategoryAvailability(String categoryId, bool isAvailable) async {
    final category = _categoryBox.get(categoryId);
    if (category != null) {
      category.isAvailable = isAvailable;
      await _categoryBox.put(categoryId, category);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoryBox.delete(categoryId);
  }
}
