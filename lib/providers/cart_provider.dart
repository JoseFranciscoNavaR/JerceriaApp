import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jarceria_app/models/product_model.dart';
import 'package:jarceria_app/models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, CartItem> _items = {};
  StreamSubscription? _cartSubscription;
  String? _userId;

  CartProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _cartSubscription?.cancel();
    if (user == null) {
      _userId = null;
      _items = {};
      notifyListeners();
    } else {
      _userId = user.uid;
      _cartSubscription = _db
          .collection('carts')
          .doc(_userId)
          .collection('items')
          .snapshots()
          .listen((snapshot) {
        _items = {
          for (var doc in snapshot.docs) doc.id: CartItem.fromJson(doc.data())
        };
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalQuantity {
    return _items.values.fold(0.0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) {
      if (item.unit == 'Pz') {
        return sum + (item.price * item.quantity);
      } else {
        return sum + (item.totalPrice ?? (item.price * item.quantity));
      }
    });
  }

  Future<void> addItem(Product product, double quantity,
      {double? totalPrice}) async {
    if (_userId == null || quantity <= 0) return;

    final cartItemRef =
        _db.collection('carts').doc(_userId).collection('items').doc(product.id);

    if (_items.containsKey(product.id)) {
      final existingItem = _items[product.id]!;
      final newQuantity = existingItem.quantity + quantity;
      double? newTotalPrice;

      if (existingItem.unit == 'Lt') {
        newTotalPrice =
            (existingItem.totalPrice ?? (existingItem.price * existingItem.quantity)) +
                (totalPrice ?? (product.price * quantity));
      }

      await cartItemRef.update({
        'quantity': newQuantity,
        'totalPrice': newTotalPrice,
      });
    } else {
      final newItem = CartItem(
        id: product.id,
        name: product.name,
        price: product.price,
        quantity: quantity,
        imageUrl: product.imageUrl,
        unit: product.unit,
        totalPrice: product.unit == 'Lt' ? totalPrice : null,
      );
      await cartItemRef.set(newItem.toJson());
    }
  }

  Future<void> removeSingleItem(String productId) async {
    if (_userId == null || !_items.containsKey(productId)) return;

    final cartItemRef =
        _db.collection('carts').doc(_userId).collection('items').doc(productId);
    final existingItem = _items[productId]!;

    if (existingItem.unit != 'Lt' && existingItem.quantity <= 1) {
      await cartItemRef.delete();
    } else {
      final isVolumetric = existingItem.unit == 'Lt';
      final double decrementAmount = isVolumetric ? 0.1 : 1.0;
      final double newQuantity = existingItem.quantity - decrementAmount;

      if (newQuantity > 0.001) {
        await cartItemRef.update({
          'quantity': newQuantity,
          'totalPrice': isVolumetric ? (existingItem.price * newQuantity) : null,
        });
      } else {
        await cartItemRef.delete();
      }
    }
  }

  Future<void> removeItem(String productId) async {
    if (_userId == null || !_items.containsKey(productId)) return;
    await _db
        .collection('carts')
        .doc(_userId)
        .collection('items')
        .doc(productId)
        .delete();
  }

  Future<void> clear() async {
    if (_userId == null) return;

    final batch = _db.batch();
    final snapshot =
        await _db.collection('carts').doc(_userId).collection('items').get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> updateItemQuantity(String productId, double newQuantity) async {
    if (_userId == null || !_items.containsKey(productId)) return;

    final cartItemRef =
        _db.collection('carts').doc(_userId).collection('items').doc(productId);

    if (newQuantity > 0) {
      final item = _items[productId]!;
      await cartItemRef.update({
        'quantity': newQuantity,
        'totalPrice': item.unit == 'Lt' ? (item.price * newQuantity) : null,
      });
    } else {
      await cartItemRef.delete();
    }
  }
}
