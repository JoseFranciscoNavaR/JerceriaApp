import 'package:jarceria_app/models/cart_item_model.dart';

class Order {
  final String id;
  final List<CartItem> products;
  final double totalAmount;
  final DateTime date;
  bool isNew;

  Order({
    required this.id,
    required this.products,
    required this.totalAmount,
    required this.date,
    this.isNew = true,
  });
}
