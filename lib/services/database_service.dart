import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart' as model;

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Product-related methods
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // Category-related methods
  Stream<List<Category>> getCategories() {
    return _db.collection('categories').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  Future<void> addCategory(Category category) async {
    await _db.collection('categories').add(category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    await _db.collection('categories').doc(category.id).update(category.toMap());
  }

  Future<void> updateCategoryAvailability(String categoryId, bool isAvailable) async {
    await _db.collection('categories').doc(categoryId).update({'isAvailable': isAvailable});
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }

  // Order-related methods
  Stream<List<model.Order>> getOrders() {
    return _db.collection('orders').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => model.Order.fromFirestore(doc)).toList());
  }
  
  Future<void> addOrder(model.Order order) async {
    await _db.collection('orders').add(order.toJson());
  }

  Future<void> updateOrder(model.Order order) async {
    await _db.collection('orders').doc(order.id).update(order.toJson());
  }
}
