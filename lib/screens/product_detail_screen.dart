
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenemos acceso al CartProvider
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              child: Hero(
                tag: product.id,
                child: Image.asset(
                  'assets/images/product-placeholder.png',
                  fit: BoxFit.cover,
                  /*errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    );
                  },*/
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50),
              child: Text(
                product.description,
                textAlign: TextAlign.justify,
                softWrap: true,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Usamos el provider para añadir el ítem
          cart.addItem(product);
          
          // Mostramos una confirmación con SnackBar
          ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Oculta la anterior si existe
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Añadido al carrito!'),
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                label: 'DESHACER',
                textColor: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  // Lógica para deshacer (remover el ítem)
                  cart.removeSingleItem(product.id);
                },
              ),
            ),
          );
        },
        label: Text('Añadir al Carrito'),
        icon: Icon(Icons.add_shopping_cart),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
