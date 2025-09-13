import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartItem {
  final String id;
  final String name;
  final double quantity;
  final double price;
  final String imageUrl;
  final String unit;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.unit,
  });

  CartItem copyWith({double? quantity}) {
    return CartItem(
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
      price: price,
      imageUrl: imageUrl,
      unit: unit,
    );
  }
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    return _items.length;
  }

  double get totalQuantity {
      double total = 0;
      _items.forEach((key, cartItem) {
        total += cartItem.quantity;
      });
      return total;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product, double quantity) {
    if (quantity <= 0) return;

    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity + quantity,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: product.id,
          name: product.name,
          price: product.price,
          quantity: quantity,
          imageUrl: product.imageUrl,
          unit: product.unit,
        ),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    final existingItem = _items[productId]!;
    final isVolumetric = existingItem.unit == 'Lt';
    final double decrementAmount = isVolumetric ? 0.1 : 1.0;
    final double newQuantity = existingItem.quantity - decrementAmount;

    if (newQuantity > 0.001) { // Use tolerance for float comparison
      _items.update(productId, (item) => item.copyWith(quantity: newQuantity));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void updateItemQuantity(String productId, double newQuantity) {
    if (!_items.containsKey(productId)) return;

    if (newQuantity > 0) {
      _items.update(productId, (item) => item.copyWith(quantity: newQuantity));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
