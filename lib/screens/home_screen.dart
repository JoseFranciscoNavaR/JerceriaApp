import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../screens/admin/admin_login_screen.dart';
import '../widgets/product_grid_item.dart';
import './cart_screen.dart';
import './order_history_screen.dart';
import 'package:badges/badges.dart' as badges;
import '../generated/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutConfirmation),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await authProvider.signOut();
      if (!mounted) return;
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => const HomeScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final List<Widget> widgetOptions = <Widget>[
      const ProductsGrid(),
      const CartScreen(),
      const OrderHistoryScreen(),
    ];

    final List<String> widgetTitles = <String>[
      l10n.products,
      l10n.myCart,
      l10n.orderHistory,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widgetTitles[navigationProvider.selectedIndex],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (navigationProvider.selectedIndex != 1)
            Consumer<CartProvider>(
              builder: (_, cart, ch) => badges.Badge(
                badgeContent: Text(cart.totalQuantity.round().toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
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
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              if (auth.isAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _logout(context),
                  tooltip: AppLocalizations.of(context)!.logout,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              if (auth.isAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => const AdminLoginScreen()));
                  },
                );
              }
              return const SizedBox.shrink();
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
          BottomNavigationBarItem(
            icon: const Icon(Icons.store_outlined),
            activeIcon: const Icon(Icons.store),
            label: l10n.products,
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (_, cart, ch) => badges.Badge(
                badgeContent: Text(cart.totalQuantity.round().toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                showBadge: cart.totalQuantity > 0,
                position: badges.BadgePosition.topEnd(top: -8, end: -8),
                child: ch!,
              ),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: const Icon(Icons.shopping_cart),
            label: l10n.myCart,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_outlined),
            activeIcon: const Icon(Icons.history),
            label: l10n.orderHistory,
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
  ProductsGridState createState() => ProductsGridState();
}

class ProductsGridState extends State<ProductsGrid> {
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchProducts,
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
                  PopupMenuItem<String>(
                    value: 'A-Z',
                    child: ListTile(
                      leading: const Icon(Icons.sort_by_alpha),
                      title: Text(l10n.sortAZ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Z-A',
                    child: ListTile(
                      leading: const Icon(Icons.sort_by_alpha),
                      title: Text(l10n.sortZA),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Precio Menor',
                    child: ListTile(
                      leading: const Icon(Icons.arrow_downward),
                      title: Text(l10n.priceAsc),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Precio Mayor',
                    child: ListTile(
                      leading: const Icon(Icons.arrow_upward),
                      title: Text(l10n.priceDesc),
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
                  PopupMenuItem<int>(
                    value: 2,
                    child: ListTile(
                      leading: const Icon(Icons.view_module),
                      title: Text(l10n.twoPerRow),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 3,
                    child: ListTile(
                      leading: const Icon(Icons.view_comfy),
                      title: Text(l10n.threePerRow),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 4,
                    child: ListTile(
                      leading: const Icon(Icons.view_agenda),
                      title: Text(l10n.fourPerRow),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return Center(child: Text(l10n.somethingWentWrong));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final categoryDocs = snapshot.data!.docs;
              final categories = [
                Category(id: 'all', name: l10n.all),
                ...categoryDocs.map((doc) => Category.fromFirestore(doc)).where((c) => c.isAvailable)
              ];

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategoryId == category.id ||
                      (_selectedCategoryId == null && category.id == 'all');
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategoryId =
                                category.id == 'all' ? null : category.id;
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
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300]!,
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return Center(child: Text(l10n.somethingWentWrong));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var products = snapshot.data!.docs.map((doc) => Product.fromFirestore(doc)).where((p) => p.isAvailable).toList();

              if (_selectedCategoryId != null) {
                products = products
                    .where((p) => p.categoryId == _selectedCategoryId)
                    .toList();
              }

              if (_searchQuery.isNotEmpty) {
                products = products
                    .where((p) => p.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
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
                      Icon(Icons.search_off,
                          size: 100, color: Colors.grey[300]),
                      const SizedBox(height: 20),
                      Text(
                        l10n.noProductsFound,
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w300),
                      ),
                      if (_searchQuery.isNotEmpty)
                        Text(
                          l10n.tryAnotherSearch,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[500]),
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
                  itemBuilder: (ctx, i) =>
                      ProductGridItem(product: products[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
