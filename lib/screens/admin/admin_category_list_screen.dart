import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jarceria_app/models/category_model.dart';
import './admin_edit_category_screen.dart';

class AdminCategoryListScreen extends StatefulWidget {
  const AdminCategoryListScreen({super.key});

  @override
  AdminCategoryListScreenState createState() => AdminCategoryListScreenState();
}

class AdminCategoryListScreenState extends State<AdminCategoryListScreen> {
  String _searchQuery = '';
  String _sortOrder = 'name_asc'; // Default sort order

  void _navigateToEditScreen(BuildContext context, {Category? category}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AdminEditCategoryScreen(category: category),
      ),
    );
  }

  Future<void> _updateCategoryAvailability(Category category, bool isAvailable) async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(category.id)
          .update({'isAvailable': isAvailable});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAvailable ? 'Categoría Habilitada' : 'Categoría Deshabilitada'),
          backgroundColor: isAvailable ? Colors.green : Colors.orangeAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar esta categoría? Esta acción es permanente y no se puede deshacer. Los productos de esta categoría no serán eliminados, pero quedarán sin categoría.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Sí, Eliminar',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('categories')
                    .doc(category.id)
                    .delete();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Categoría eliminada permanentemente.'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                 Navigator.of(ctx).pop();
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
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
        title: const Text('Administrar Categorías',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                      setState(() {
                        _searchQuery = value;
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
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'name_asc',
                      child: Text('Ordenar por nombre (A-Z)'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'name_desc',
                      child: Text('Ordenar por nombre (Z-A)'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'available_first',
                      child: Text('Disponibles primero'),
                    ),
                     const PopupMenuItem<String>(
                      value: 'disabled_first',
                      child: Text('Deshabilitados primero'),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      color: primaryColor, size: 28),
                  onPressed: () => _navigateToEditScreen(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar los datos'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay categorías. ¡Añade una!'),
                  );
                }

                var categories = snapshot.data!.docs
                    .map((doc) => Category.fromFirestore(doc))
                    .toList();

                if (_searchQuery.isNotEmpty) {
                  categories = categories
                      .where((category) => category.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                // Sorting logic
                categories.sort((a, b) {
                  switch (_sortOrder) {
                    case 'name_asc':
                      return a.name.compareTo(b.name);
                    case 'name_desc':
                      return b.name.compareTo(a.name);
                    case 'available_first':
                       if (a.isAvailable && !b.isAvailable) return -1;
                       if (!a.isAvailable && b.isAvailable) return 1;
                       return a.name.compareTo(b.name);
                    case 'disabled_first':
                       if (!a.isAvailable && b.isAvailable) return -1;
                       if (a.isAvailable && !b.isAvailable) return 1;
                       return a.name.compareTo(b.name);
                    default:
                      return a.name.compareTo(b.name);
                  }
                });

                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 100, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        Text('No se encontraron categorías', style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w300)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: categories.length,
                  itemBuilder: (ctx, index) {
                    final category = categories[index];
                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: category.isAvailable
                              ? primaryColor.withAlpha(26)
                              : Colors.grey[200],
                          child: Icon(
                            Icons.category,
                            size: 30,
                            color: category.isAvailable
                                ? primaryColor
                                : Colors.grey[500],
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: category.isAvailable
                                ? Colors.black87
                                : Colors.grey[500],
                            decoration: !category.isAvailable
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: category.isAvailable,
                              onChanged: (value) {
                                _updateCategoryAvailability(category, value);
                              },
                              activeThumbColor: primaryColor,
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.grey.shade300,
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined,
                                  color: Colors.grey[600]),
                              onPressed: () =>
                                  _navigateToEditScreen(context, category: category),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error),
                              onPressed: () =>
                                  _showDeleteConfirmationDialog(context, category),
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
