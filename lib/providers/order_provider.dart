import 'package:flutter/foundation.dart';
import 'package:jarceria_app/models/cart_item_model.dart';
import 'package:jarceria_app/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  void addOrder(List<CartItem> cartProducts, double total, String customerName) {
    final newOrder = Order(
      id: DateTime.now().toString(),
      products: cartProducts,
      totalAmount: total,
      date: DateTime.now(),
      customerName: customerName,
    );
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex].status = newStatus;
      notifyListeners();
    }
  }
}
