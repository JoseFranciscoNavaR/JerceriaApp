import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../models/product_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Consumer widget will listen to CartProvider changes and rebuild the UI
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) {
        final cartItems = cart.items.values.toList();

        if (cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.remove_shopping_cart_outlined, size: 100, color: Colors.grey[300]),
                const SizedBox(height: 20),
                Text(
                  'Tu carrito está vacío',
                  style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 8),
                Text(
                  'Añade productos para verlos aquí',
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: <Widget>[
            // Summary Card
            Card(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: cart.totalAmount <= 0 ? null : () {
                        // TODO: Implement order logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Función de compra no implementada todavía.'))
                        );
                        // cart.clear();
                      },
                      child: const Text('COMPRAR'),
                    )
                  ],
                ),
              ),
            ),
            // List of items
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (ctx, i) => CartListItem(
                  cartItem: cartItems[i],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class CartListItem extends StatelessWidget {
  final CartItem cartItem;

  const CartListItem({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final theme = Theme.of(context);

    // Helper to format quantity
    String formatQuantity(CartItem item) {
      if (item.unit == 'Lt') {
        return item.quantity.toStringAsFixed(1);
      }
      return item.quantity.toStringAsFixed(0);
    }

    return Dismissible(
      key: ValueKey(cartItem.id),
      background: Container(
        color: theme.colorScheme.error.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('¿Estás seguro?'),
            content: Text('¿Quieres eliminar "${cartItem.name}" del carrito?'),
            actions: <Widget>[
              TextButton(child: const Text('No'), onPressed: () => Navigator.of(ctx).pop(false)),
              TextButton(child: const Text('Sí'), onPressed: () => Navigator.of(ctx).pop(true)),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        cart.removeItem(cartItem.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 1.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(cartItem.imageUrl),
              onBackgroundImageError: (exception, stackTrace) => {},
              backgroundColor: Colors.grey[200],
            ),
            title: Text(cartItem.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Total: \$${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.remove, color: theme.colorScheme.error, size: 18),
                    onPressed: () => cart.removeSingleItem(cartItem.id),
                    splashRadius: 20,
                  ),
                  Text(
                    '${formatQuantity(cartItem)} ${cartItem.unit}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: theme.primaryColor, size: 18),
                    onPressed: () {
                      final product = Hive.box<Product>('products').get(cartItem.id);
                      if (product != null) {
                        final increment = product.unit == 'Lt' ? 0.1 : 1.0;
                        cart.addItem(product, increment);
                      }
                    },
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
