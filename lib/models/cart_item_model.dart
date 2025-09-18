class CartItem {
  final String id;
  final String name;
  final double quantity;
  final double price;
  final String imageUrl;
  final String unit;
  final double? totalPrice; // Add this line

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.unit,
    this.totalPrice, // Add this line
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
      totalPrice: totalPrice ?? this.totalPrice, // Add this line
    );
  }
}
