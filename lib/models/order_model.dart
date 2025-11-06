import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Add this method to convert an Order object to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((product) => product.toJson()).toList(),
      'totalAmount': totalAmount,
      'date': Timestamp.fromDate(date),
      'customerName': customerName,
      'status': status,
    };
  }

  // Add this factory constructor to create an Order object from a Firestore document
  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      products: (data['products'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: data['totalAmount'],
      date: (data['date'] as Timestamp).toDate(),
      customerName: data['customerName'],
      status: data['status'],
    );
  }
}
