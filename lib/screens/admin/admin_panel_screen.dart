
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import './admin_edit_product_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final DatabaseService _databaseService = DatabaseService();

  void _navigateToEditScreen(BuildContext context, {Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => AdminEditProductScreen(product: product)),
    );
  }

  void _deleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar este producto?'),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Sí'),
            onPressed: () {
              _databaseService.deleteProduct(productId);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administrador'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToEditScreen(context),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Product>('products').listenable(),
        builder: (context, Box<Product> box, _) {
          final products = box.values.toList().cast<Product>();
          if (products.isEmpty) {
            return Center(
              child: Text('No hay productos. ¡Añade uno!'),
            );
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              final product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  // Lógica de imagen de placeholder mejorada
                  backgroundImage: product.imageUrl.isNotEmpty
                      ? NetworkImage(product.imageUrl)
                      : null,
                  onBackgroundImageError: (_, __) {},
                  child: product.imageUrl.isEmpty ? Icon(Icons.store) : null,
                ),
                title: Text(product.name),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                trailing: Container(
                  width: 100,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _navigateToEditScreen(context, product: product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _navigateToEditScreen(context),
      ),
    );
  }
}
