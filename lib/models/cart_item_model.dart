class CartItem {
  final String id;
  final String name;
  final double quantity;
  final double price;
  final String imageUrl;
  final String unit;
  final double? totalPrice;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.unit,
    this.totalPrice,
  });

  CartItem copyWith({
    double? quantity,
    double? totalPrice,
  }) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      imageUrl: imageUrl,
      unit: unit,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'unit': unit,
      'totalPrice': totalPrice,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      unit: json['unit'],
      totalPrice: json['totalPrice'],
    );
  }
}
