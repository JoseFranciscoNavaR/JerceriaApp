import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:jarceria_app/models/cart_item_model.dart';
import 'package:jarceria_app/models/order_model.dart';
import 'package:jarceria_app/services/database_service.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Order> _orders = [];
  late StreamSubscription _ordersSubscription;

  OrderProvider() {
    _ordersSubscription = _db.getOrders().listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ordersSubscription.cancel();
    super.dispose();
  }

  List<Order> get orders => [..._orders];

  Future<void> addOrder(
      List<CartItem> cartProducts, double total, String customerName) async {
    final newOrder = Order(
      id: DateTime.now().toString(), // Firestore will generate a proper ID
      products: cartProducts,
      totalAmount: total,
      date: DateTime.now(),
      customerName: customerName,
    );
    await _db.addOrder(newOrder);
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final orderToUpdate = _orders[orderIndex];
      orderToUpdate.status = newStatus;
      await _db.updateOrder(orderToUpdate);
      notifyListeners(); // Notify for immediate UI update
    }
  }
}
