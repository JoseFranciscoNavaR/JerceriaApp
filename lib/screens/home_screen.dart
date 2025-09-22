import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../screens/admin/admin_login_screen.dart';
import '../widgets/product_grid_item.dart';
import './cart_screen.dart';
import './order_history_screen.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    final List<Widget> widgetOptions = <Widget>[
      const ProductsGrid(),
      const CartScreen(),
      const OrderHistoryScreen(),
    ];

    final List<String> widgetTitles = <String>[
      'Jarcería Productos',
      'Mi Carrito',
      'Historial de Órdenes',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widgetTitles[navigationProvider.selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (navigationProvider.selectedIndex != 1)
            Consumer<CartProvider>(
              builder: (_, cart, ch) => badges.Badge(
                badgeContent: Text(cart.totalQuantity.round().toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                showBadge: cart.totalQuantity > 0,
                position: badges.BadgePosition.topEnd(top: 0, end: 0),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    navigationProvider.setIndex(1);
                  },
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const AdminLoginScreen()));
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: navigationProvider.selectedIndex,
        children: widgetOptions,
      ),
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (_, cart, ch) => badges.Badge(
                badgeContent: Text(cart.totalQuantity.round().toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                showBadge: cart.totalQuantity > 0,
                position: badges.BadgePosition.topEnd(top: -8, end: -8),
                child: ch!,
              ),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: const Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
        currentIndex: navigationProvider.selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) => navigationProvider.setIndex(index),
        showUnselectedLabels: true,
        unselectedItemColor: Colors.grey[600],
      ),
    );
  }
}

class ProductsGrid extends StatefulWidget {
  const ProductsGrid({super.key});

  @override
  _ProductsGridState createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid> {
  String _searchQuery = '';
  String _sortOrder = 'A-Z';
  int _crossAxisCount = 2;
  String? _selectedCategoryId;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    value: 'A-Z',
                    child: ListTile(
                      leading: Icon(Icons.sort_by_alpha),
                      title: Text('A-Z'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Z-A',
                    child: ListTile(
                      leading: Icon(Icons.sort_by_alpha),
                      title: Text('Z-A'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Precio Menor',
                    child: ListTile(
                      leading: Icon(Icons.arrow_downward),
                      title: Text('Precio Menor'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Precio Mayor',
                    child: ListTile(
                      leading: Icon(Icons.arrow_upward),
                      title: Text('Precio Mayor'),
                    ),
                  ),
                ],
              ),
              PopupMenuButton<int>(
                onSelected: (value) {
                  setState(() {
                    _crossAxisCount = value;
                  });
                },
                icon: Icon(Icons.view_column_outlined, color: Colors.grey[600]),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  const PopupMenuItem<int>(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.view_module),
                      title: Text('2 por fila'),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 3,
                    child: ListTile(
                      leading: Icon(Icons.view_comfy),
                      title: Text('3 por fila'),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 4,
                    child: ListTile(
                      leading: Icon(Icons.view_agenda),
                      title: Text('4 por fila'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: ValueListenableBuilder(
            valueListenable: Hive.box<Category>('categories').listenable(),
            builder: (context, Box<Category> box, _) {
              final categories = [Category(id: 'all', name: 'Todos'), ...box.values.where((c) => c.isAvailable)];
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategoryId == category.id || (_selectedCategoryId == null && category.id == 'all');
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategoryId = category.id == 'all' ? null : category.id;
                          }
                        });
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      backgroundColor: Colors.white,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: Hive.box<Product>('products').listenable(),
            builder: (context, Box<Product> box, _) {
              var products = box.values.toList().cast<Product>();

              if (_selectedCategoryId != null) {
                products = products.where((p) => p.categoryId == _selectedCategoryId).toList();
              }

              if (_searchQuery.isNotEmpty) {
                products = products
                    .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();
              }

              products.sort((a, b) {
                switch (_sortOrder) {
                  case 'Precio Menor':
                    return a.price.compareTo(b.price);
                  case 'Precio Mayor':
                    return b.price.compareTo(a.price);
                  case 'A-Z':
                    return a.name.compareTo(b.name);
                  case 'Z-A':
                    return b.name.compareTo(a.name);
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

              return RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _crossAxisCount,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (ctx, i) => ProductGridItem(product: products[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}