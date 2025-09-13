import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late TextEditingController _textController;

  double get _quantity => double.tryParse(_textController.text) ?? 0.0;
  bool get _isVolumetric => widget.product.unit == 'Lt';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _isVolumetric ? '0.5' : '1');
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (_quantity > 0) {
      // CORRECTED: Pass both product and quantity to the provider
      cart.addItem(widget.product, _quantity);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Añadido al carrito!'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(24, 0, 24, 110), // Adjust for bottom bar
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'VER CARRITO',
            textColor: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              // Navigate to cart screen using the navigation provider
              Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
              Navigator.of(context).pop(); // Go back from detail screen
            },
          ),
        ),
      );
    }
  }

  void _changeQuantity(double amount) {
    final currentValue = _quantity;
    double newValue;
    if (_isVolumetric) {
      newValue = max(0.1, currentValue + amount);
      _textController.text = newValue.toStringAsFixed(1);
    } else {
      newValue = max(1, currentValue + amount);
      _textController.text = newValue.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildProductInfo(),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 400.0,
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      foregroundColor: Colors.black87,
      surfaceTintColor: Colors.white,
      actions: [_buildCartIcon(context)],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
        centerTitle: false,
        title: Text(
          widget.product.name,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        background: Hero(
          tag: widget.product.id,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.product.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.15), BlendMode.darken),
                onError: (_, __) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 150), // Bottom padding for content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.brand != null && widget.product.brand!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  widget.product.brand!.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600], letterSpacing: 1.5),
                ),
              ),
            Text(
              widget.product.description,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Consumer<CartProvider>(
        builder: (_, cart, ch) => badges.Badge(
          badgeContent: Text(cart.totalQuantity.round().toString(), style: TextStyle(color: Colors.white, fontSize: 12)),
          showBadge: cart.totalQuantity > 0,
          position: badges.BadgePosition.topEnd(top: 0, end: 3),
          child: ch!,
        ),
        child: IconButton(
          icon: Icon(Icons.shopping_cart_outlined),
          onPressed: () {
            Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final theme = Theme.of(context);
    final total = _quantity * widget.product.price;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantitySelector(theme),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 56),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            child: Text('Añadir por \$${total.toStringAsFixed(2)}'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Cantidad:',
          style: theme.textTheme.titleMedium,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: <Widget>[
              IconButton(onPressed: () => _changeQuantity(_isVolumetric ? -0.1 : -1), icon: Icon(Icons.remove, size: 20), splashRadius: 24, color: Colors.black54),
              SizedBox(
                width: 60,
                child: Text(
                  '${_textController.text} ${widget.product.unit}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(onPressed: () => _changeQuantity(_isVolumetric ? 0.1 : 1), icon: Icon(Icons.add, size: 20), splashRadius: 24, color: Colors.black54),
            ],
          ),
        ),
      ],
    );
  }
}
