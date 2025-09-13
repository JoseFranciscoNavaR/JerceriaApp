import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  double price;

  @HiveField(4)
  String imageUrl;

  @HiveField(5)
  bool isAvailable;

  @HiveField(6)
  String unit;

  @HiveField(7)
  String? brand; // Opcional

  @HiveField(8)
  String categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isAvailable = true,
    this.unit = 'Pz',
    this.brand,
    required this.categoryId,
  });
}
