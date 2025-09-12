import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import './admin_edit_product_screen.dart';

class AdminProductListScreen extends StatefulWidget {
  @override
  _AdminProductListScreenState createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  final DatabaseService _databaseService = DatabaseService();

  void _navigateToEditScreen(BuildContext context, {Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => AdminEditProductScreen(product: product)),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar este producto? Esta acción no se puede deshacer.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Sí, Eliminar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () {
              _databaseService.deleteProduct(product.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Producto eliminado exitosamente'), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Administrar Productos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[300]),
                  SizedBox(height: 20),
                  Text(
                    'No hay productos',
                    style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '¡Añade uno para empezar!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              final product = products[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: product.imageUrl.isNotEmpty
                        ? NetworkImage(product.imageUrl)
                        : null,
                    onBackgroundImageError: (_, __) {},
                    child: product.imageUrl.isEmpty ? Icon(Icons.store, size: 30) : null,
                    backgroundColor: Colors.grey[200],
                  ),
                  title: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: !product.isAvailable ? TextDecoration.lineThrough : null,
                      color: !product.isAvailable ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)} / ${product.unit}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: product.isAvailable,
                        onChanged: (value) {
                          product.isAvailable = value;
                          _databaseService.updateProduct(product);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
                        onPressed: () => _navigateToEditScreen(context, product: product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _showDeleteConfirmationDialog(context, product),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _navigateToEditScreen(context),
      ),
    );
  }
}
