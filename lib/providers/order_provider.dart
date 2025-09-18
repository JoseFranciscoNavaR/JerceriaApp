import 'package:flutter/foundation.dart';
import 'package:jarceria_app/models/cart_item_model.dart';
import 'package:jarceria_app/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  void addOrder(List<CartItem> cartProducts, double total) {
    final newOrder = Order(
      id: DateTime.now().toString(),
      products: cartProducts,
      totalAmount: total,
      date: DateTime.now(),
    );
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  void markOrderAsRead(String orderId) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex].isNew = false;
      notifyListeners();
    }
  }
}
