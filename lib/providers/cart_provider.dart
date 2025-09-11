
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

// Modelo para un ítem dentro del carrito
class CartItem {
  final String id; // ID único para el ítem del carrito (ej: producto.id)
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  // Método para crear una copia con una cantidad actualizada
  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
      price: price,
      imageUrl: imageUrl,
    );
  }
}

// El "cerebro" del carrito
class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  // CORRECCIÓN: Contar el número total de artículos, no solo los tipos de producto.
  int get itemCount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  // Suma total del precio de los productos en el carrito
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Método para añadir un producto al carrito
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Si el producto ya está, solo aumenta la cantidad
      _items.update(
        product.id,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // Si es un producto nuevo, lo añade al mapa
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: DateTime.now().toString(), // ID único para el ítem
          name: product.name,
          price: product.price,
          quantity: 1,
          imageUrl: product.imageUrl,
        ),
      );
    }
    notifyListeners(); // Notifica a los widgets que están escuchando
  }

  // Método para remover un solo ítem (si la cantidad es > 1)
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      // Si solo hay uno, elimina el producto del mapa
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Método para eliminar completamente un producto del carrito
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Método para limpiar todo el carrito
  void clear() {
    _items = {};
    notifyListeners();
  }
}
