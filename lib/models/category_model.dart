import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String name;
  bool isAvailable;

  Category({
    required this.id,
    required this.name,
    this.isAvailable = true,
  });

  // Convert a Category object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isAvailable': isAvailable,
    };
  }

  // Create a Category object from a Firestore document
  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
    );
  }
}
