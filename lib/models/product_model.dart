import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String name;
  String? description;
  double price;
  String imageUrl;
  bool isAvailable;
  String unit;
  String? brand;
  String categoryId;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.imageUrl,
    this.isAvailable = true,
    this.unit = 'Pz',
    this.brand,
    required this.categoryId,
  });

  // Convert a Product object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'unit': unit,
      'brand': brand,
      'categoryId': categoryId,
    };
  }

  // Create a Product object from a Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      unit: data['unit'] ?? 'Pz',
      brand: data['brand'],
      categoryId: data['categoryId'] ?? '',
    );
  }
}
