import 'dart:math';
import 'package:flutter/material.dart';
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
      cart.addItem(widget.product, _quantity);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Añadido al carrito!'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 110),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'VER CARRITO',
            textColor: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
              Navigator.of(context).popUntil((route) => route.isFirst);
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
      body: Stack(
        children: [
          _buildBackgroundImage(context),
          _buildDraggableSheet(context),
          _buildFloatingActions(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned.fill(
      bottom: screenHeight * 0.45, // Show about 55% of the image
      child: Hero(
        tag: widget.product.id,
        child: Image.network(
          widget.product.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 150, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDraggableSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6, // Start at 60% of the screen
      minChildSize: 0.6,
      maxChildSize: 0.9, // Can be dragged up to 90%
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildProductInfo(context),
                  ],
                ),
              ),
              _buildBottomActionBar(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildFloatingActions(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFloatingActionButton(
            context: context,
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          _buildFloatingActionButton(
            context: context,
            child: _buildCartIcon(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required BuildContext context,
    IconData? icon,
    Widget? child,
    VoidCallback? onPressed,
  }) {
    return CircleAvatar(
      backgroundColor: Colors.black.withOpacity(0.5),
      child: child ?? IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, ch) => badges.Badge(
        badgeContent: Text(
          cart.totalQuantity.round().toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        showBadge: cart.totalQuantity > 0,
        position: badges.BadgePosition.topEnd(top: -4, end: -4),
        badgeStyle: badges.BadgeStyle(
          badgeColor: Theme.of(context).primaryColor,
        ),
        child: ch!,
      ),
      child: IconButton(
        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        onPressed: () {
          Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        splashRadius: 20,
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'MXN \$${widget.product.price.toStringAsFixed(2)}',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Descripción',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.black54,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        if (widget.product.brand != null && widget.product.brand!.isNotEmpty) ...[
          Text(
            'Marca',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.brand!,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
        ],
        const SizedBox(height: 100), // Extra space to scroll behind bottom bar
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final theme = Theme.of(context);
    final total = _quantity * widget.product.price;
    final String unitText;
    if (_isVolumetric) {
      unitText = 'Litros';
    } else {
      unitText = (_quantity == 1.0) ? 'Pieza' : 'Piezas';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildQuantitySelector(theme),
          const SizedBox(width: 16),
          Text(
            unitText,
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            ),
            icon: const Icon(Icons.add_shopping_cart, size: 20),
            label: Text('Añadir (MX\$${total.toStringAsFixed(2)})'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: () => _changeQuantity(_isVolumetric ? -0.1 : -1),
            icon: const Icon(Icons.remove, size: 20),
            splashRadius: 20,
            color: Colors.black54,
          ),
          SizedBox(
            width: 45,
            child: TextFormField(
              controller: _textController,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              keyboardType: TextInputType.numberWithOptions(decimal: _isVolumetric),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeQuantity(_isVolumetric ? 0.1 : 1),
            icon: const Icon(Icons.add, size: 20),
            splashRadius: 20,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }
}
