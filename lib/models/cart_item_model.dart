class CartItem {
  final String id;
  final String name;
  final double quantity;
  final double price;
  final String imageUrl;
  final String unit;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.unit,
  });

  CartItem copyWith({
    double? quantity,
  }) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      imageUrl: imageUrl,
      unit: unit,
      quantity: quantity ?? this.quantity,
    );
  }
}
