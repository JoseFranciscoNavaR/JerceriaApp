import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import './admin_edit_product_screen.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({Key? key}) : super(key: key);

  @override
  _AdminProductListScreenState createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String _searchQuery = '';
  String _sortOrder = 'name_asc';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _navigateToEditScreen(BuildContext context, {Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => AdminEditProductScreen(product: product)),
    );
  }

  void _showDisableConfirmationDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Deshabilitación'),
        content: const Text('¿Estás seguro de que quieres deshabilitar este producto?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Sí, Deshabilitar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () {
              product.isAvailable = false;
              _databaseService.updateProduct(product);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Producto deshabilitado exitosamente'), backgroundColor: Colors.orange),
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
        title: const Text('Administrar Productos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          _searchQuery = value;
                        });
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _sortOrder = value;
                    });
                  },
                  icon: Icon(Icons.sort, color: Colors.grey[600]),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'name_asc',
                      child: Text('Ordenar por nombre (A-Z)'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'name_desc',
                      child: Text('Ordenar por nombre (Z-A)'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'price_asc',
                      child: Text('Ordenar por precio (menor a mayor)'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'price_desc',
                      child: Text('Ordenar por precio (mayor a menor)'),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => _navigateToEditScreen(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Product>('products').listenable(),
              builder: (context, Box<Product> box, _) {
                var products = box.values.toList().cast<Product>();

                if (_searchQuery.isNotEmpty) {
                  products = products.where((product) => product.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                }

                products.sort((a, b) {
                  switch (_sortOrder) {
                    case 'name_asc':
                      return a.name.compareTo(b.name);
                    case 'name_desc':
                      return b.name.compareTo(a.name);
                    case 'price_asc':
                      return a.price.compareTo(b.price);
                    case 'price_desc':
                      return b.price.compareTo(a.price);
                    default:
                      return a.name.compareTo(b.name);
                  }
                });

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 100, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        Text(
                          'No se encontraron productos',
                          style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w300),
                        ),
                        if (_searchQuery.isNotEmpty)
                          Text(
                            'Intenta con otra búsqueda',
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
                          backgroundColor: Colors.grey[200],
                          child: product.imageUrl.isEmpty ? const Icon(Icons.store, size: 30) : null,
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
                              inactiveTrackColor: Colors.grey[300],
                              inactiveThumbColor: Colors.grey[600],
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
                              onPressed: () => _navigateToEditScreen(context, product: product),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                              onPressed: () => _showDisableConfirmationDialog(context, product),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
