import 'package:jarceria_app/models/cart_item_model.dart';

class Order {
  final String id;
  final List<CartItem> products;
  final double totalAmount;
  final DateTime date;
  final String customerName;
  String status;

  Order({
    required this.id,
    required this.products,
    required this.totalAmount,
    required this.date,
    required this.customerName,
    this.status = 'Pendiente',
  });
}
