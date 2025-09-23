import 'package:flutter/foundation.dart';
import 'package:jarceria_app/models/product_model.dart';
import 'package:jarceria_app/models/cart_item_model.dart';

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
      // For items sold by piece ('Pz'), always calculate price * quantity
      if (cartItem.unit == 'Pz') {
        total += cartItem.price * cartItem.quantity;
      } else {
        // For volumetric items ('Lt'), use the pre-calculated totalPrice if available
        total += cartItem.totalPrice ?? (cartItem.price * cartItem.quantity);
      }
    });
    return total;
  }

  void addItem(Product product, double quantity, {double? totalPrice}) {
    if (quantity <= 0) return;

    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) {
          final newQuantity = existingCartItem.quantity + quantity;
          double? newTotalPrice;

          // Only calculate and update totalPrice for volumetric items
          if (existingCartItem.unit == 'Lt') {
            newTotalPrice = (existingCartItem.totalPrice ?? (existingCartItem.price * existingCartItem.quantity)) +
                            (totalPrice ?? (product.price * quantity));
          }
          
          return existingCartItem.copyWith(
            quantity: newQuantity,
            // Keep totalPrice null for non-volumetric items
            totalPrice: existingCartItem.unit == 'Lt' ? newTotalPrice : null,
          );
        },
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
          // Only set totalPrice for volumetric items on initial add
          totalPrice: product.unit == 'Lt' ? totalPrice : null,
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
      _items.update(productId, (item) {
        return item.copyWith(
          quantity: newQuantity,
          // For non-volumetric items, the total is calculated in totalAmount getter
          // For volumetric, let's recalculate based on new quantity for consistency
          totalPrice: isVolumetric ? (item.price * newQuantity) : null,
        );
      });
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void updateItemQuantity(String productId, double newQuantity) {
    if (!_items.containsKey(productId)) return;

    if (newQuantity > 0) {
      _items.update(productId, (item) {
        return item.copyWith(
          quantity: newQuantity,
          // Recalculate totalPrice only for volumetric items
          totalPrice: item.unit == 'Lt' ? (item.price * newQuantity) : null,
        );
      });
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
