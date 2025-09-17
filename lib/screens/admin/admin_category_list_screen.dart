import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jarceria_app/models/category_model.dart';
import 'package:jarceria_app/services/database_service.dart';
import './admin_edit_category_screen.dart';

class AdminCategoryListScreen extends StatefulWidget {
  const AdminCategoryListScreen({Key? key}) : super(key: key);

  @override
  _AdminCategoryListScreenState createState() => _AdminCategoryListScreenState();
}

class _AdminCategoryListScreenState extends State<AdminCategoryListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String _searchQuery = '';
  String _sortOrder = 'available_first'; // Default sort order
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _navigateToEditScreen(BuildContext context, {Category? category}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => AdminEditCategoryScreen(category: category)),
    );
  }

  void _showDisableConfirmationDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Deshabilitación'),
        content: const Text('¿Estás seguro de que quieres deshabilitar esta categoría? Los productos asociados no serán visibles para los clientes.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Sí, Deshabilitar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () {
              _databaseService.updateCategoryAvailability(category.id, false);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Categoría deshabilitada.'),
                  backgroundColor: Colors.orangeAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Administrar Categorías', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
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
                      hintText: 'Buscar categorías...',
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
                      value: 'available_first',
                      child: Text('Ordenar por disponibilidad'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'name_asc',
                      child: Text('Ordenar por nombre (A-Z)'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'name_desc',
                      child: Text('Ordenar por nombre (Z-A)'),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: primaryColor, size: 28),
                  onPressed: () => _navigateToEditScreen(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Category>('categories').listenable(),
              builder: (context, Box<Category> box, _) {
                //var categories = box.values.where((c) => c != null).toList().cast<Category>();
                var categories = box.values.whereType<Category>().toList();
                if (_searchQuery.isNotEmpty) {
                  categories = categories.where((category) => category.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                }

                // Sorting logic based on _sortOrder
                categories.sort((a, b) {
                  switch (_sortOrder) {
                    case 'available_first':
                      if (a.isAvailable && !b.isAvailable) return -1;
                      if (!a.isAvailable && b.isAvailable) return 1;
                      return a.name.compareTo(b.name);
                    case 'name_asc':
                      return a.name.compareTo(b.name);
                    case 'name_desc':
                      return b.name.compareTo(a.name);
                    default:
                      return a.name.compareTo(b.name);
                  }
                });

                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined, size: 100, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        Text(
                          _searchQuery.isEmpty ? 'No hay categorías' : 'No se encontraron categorías',
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
                  key: const PageStorageKey<String>('category_list'), // Preserve scroll position
                  padding: const EdgeInsets.all(8.0),
                  itemCount: categories.length,
                  itemBuilder: (ctx, index) {
                    final category = categories[index];
                    return Card(
                      key: ValueKey(category.id), // Essential for stateful updates in lists
                      elevation: category.isAvailable ? 2.0 : 0.5,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: category.isAvailable ? Colors.white : Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: category.isAvailable ? primaryColor.withOpacity(0.1) : Colors.grey[200],
                          child: Icon(
                            Icons.category,
                            size: 30,
                            color: category.isAvailable ? primaryColor : Colors.grey[500],
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: category.isAvailable ? Colors.black87 : Colors.grey[500],
                            decoration: !category.isAvailable ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: category.isAvailable,
                              onChanged: (value) {
                                _databaseService.updateCategoryAvailability(category.id, value);
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                              inactiveTrackColor: Colors.grey[300],
                              inactiveThumbColor: Colors.grey[600],
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
                              onPressed: () => _navigateToEditScreen(context, category: category),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                              onPressed: () => _showDisableConfirmationDialog(context, category),
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
