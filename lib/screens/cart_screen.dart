import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../providers/cart_provider.dart';
import '../models/product_model.dart';

class CartScreen extends StatelessWidget {
  // static const routeName = '/cart'; // No longer needed here

  @override
  Widget build(BuildContext context) {
    // We remove the Scaffold and AppBar to make this widget embeddable
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) {
        final cartItems = cart.items.values.toList();
        final productKeys = cart.items.keys.toList();

        if (cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Tu carrito está vacío',
                  style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: <Widget>[
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Chip(
                      label: Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    TextButton(
                      child: Text('COMPRAR AHORA'),
                      onPressed: cart.totalAmount <= 0 ? null : () {
                        // TODO: Lógica de la orden de compra
                        // cart.clear();
                      },
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (ctx, i) => CartListItem(
                  cartItem: cartItems[i],
                  productId: productKeys[i], // Usamos la key correcta
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
  final String productId;

  const CartListItem({Key? key, required this.cartItem, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey(cartItem.id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete, color: Colors.white, size: 40),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('¿Estás seguro?'),
            content: Text('¿Quieres eliminar este artículo del carrito?'),
            actions: <Widget>[
              TextButton(child: Text('No'), onPressed: () => Navigator.of(ctx).pop(false)),
              TextButton(child: Text('Sí'), onPressed: () => Navigator.of(ctx).pop(true)),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        cart.removeItem(productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(cartItem.imageUrl),
              onBackgroundImageError: (exception, stackTrace) => {},
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: FittedBox(
                  child: Text('\$${cartItem.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            title: Text(cartItem.name),
            subtitle: Text('Total: \$${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove, color: Theme.of(context).colorScheme.error, size: 20),
                  onPressed: () => cart.removeSingleItem(productId),
                ),
                Text('${cartItem.quantity} x'),
                IconButton(
                  icon: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 20),
                  onPressed: () {
                    // LÓGICA CORREGIDA
                    final productsBox = Hive.box<Product>('products');
                    final productToAdd = productsBox.get(productId);
                    if (productToAdd != null) {
                      cart.addItem(productToAdd);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
