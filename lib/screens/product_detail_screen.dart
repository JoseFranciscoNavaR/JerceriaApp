import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';

// Enum to manage which input field is active
enum VolumetricInputMode { liters, pesos }

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late TextEditingController _litersController;
  late TextEditingController _pesosController;
  late TextEditingController _discreteController;
  VolumetricInputMode _inputMode = VolumetricInputMode.liters;

  double get _quantity {
    if (_isVolumetric) {
      return double.tryParse(_litersController.text) ?? 0.0;
    } else {
      return double.tryParse(_discreteController.text) ?? 0.0;
    }
  }

  bool get _isVolumetric => widget.product.unit == 'Lt';

  @override
  void initState() {
    super.initState();
    _litersController = TextEditingController(text: '0.5');
    _pesosController = TextEditingController();
    _discreteController = TextEditingController(text: '1');

    if (_isVolumetric) {
      _updatePesosFromLiters();
      _litersController.addListener(_onLitersChanged);
      _pesosController.addListener(_onPesosChanged);
    }
    _discreteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _litersController.dispose();
    _pesosController.dispose();
    _discreteController.dispose();
    super.dispose();
  }

  void _onLitersChanged() {
    if (_inputMode == VolumetricInputMode.liters) {
      _updatePesosFromLiters();
      setState(() {});
    }
  }

  void _onPesosChanged() {
    if (_inputMode == VolumetricInputMode.pesos) {
      _updateLitersFromPesos();
      setState(() {});
    }
  }

  void _updatePesosFromLiters() {
    final liters = double.tryParse(_litersController.text) ?? 0.0;
    final price = liters * widget.product.price;
    if (mounted) {
      _pesosController.text = price.toStringAsFixed(2);
    }
  }

  void _updateLitersFromPesos() {
    final pesos = double.tryParse(_pesosController.text) ?? 0.0;
    final liters = pesos / widget.product.price;
    if (mounted) {
      _litersController.text = liters.toStringAsFixed(3);
    }
  }

  void _addToCart() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (_quantity > 0) {
      cart.addItem(widget.product, _quantity);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 10), // Adjusted bottom margin
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '¡Añadido al carrito!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_isVolumetric ? _quantity.toStringAsFixed(2) : _quantity.toStringAsFixed(0)} x ${widget.product.name}',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white54),
                    ),
                  ),
                  child: const Text('VER'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _changeDiscreteQuantity(double amount) {
    final currentValue = double.tryParse(_discreteController.text) ?? 0.0;
    final newValue = max(1, currentValue + amount);
    _discreteController.text = newValue.toStringAsFixed(0);
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
      bottomNavigationBar: _buildResponsiveBottomActionBar(context),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned.fill(
      bottom: screenHeight * 0.45,
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
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.9,
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
                    if (_isVolumetric) _buildVolumetricCalculator(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildVolumetricCalculator(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        SegmentedButton<VolumetricInputMode>(
          segments: const <ButtonSegment<VolumetricInputMode>>[
            ButtonSegment<VolumetricInputMode>(
                value: VolumetricInputMode.liters,
                label: Text('Por Litros'),
                icon: Icon(Icons.science_outlined)),
            ButtonSegment<VolumetricInputMode>(
                value: VolumetricInputMode.pesos,
                label: Text('Por Pesos'),
                icon: Icon(Icons.attach_money)),
          ],
          selected: <VolumetricInputMode>{_inputMode},
          onSelectionChanged: (Set<VolumetricInputMode> newSelection) {
            setState(() {
              _inputMode = newSelection.first;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildVolumetricInputs(context),
      ],
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
          _isVolumetric
              ? 'MX\$${widget.product.price.toStringAsFixed(2)} / Litro'
              : 'MX\$${widget.product.price.toStringAsFixed(2)}',
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
        // Adjust space depending on the product type
        SizedBox(height: _isVolumetric ? 24 : 100),
      ],
    );
  }
  
  Widget _buildVolumetricInputs(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 120.0), // Space for bottom bar
      child: Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _litersController,
              label: 'Litros',
              prefix: 'Lt',
              theme: theme,
              enabled: _inputMode == VolumetricInputMode.liters,
               onTap: () {
                if (_inputMode != VolumetricInputMode.liters) {
                  setState(() => _inputMode = VolumetricInputMode.liters);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller: _pesosController,
              label: 'Pesos',
              prefix: 'MX\$',
              theme: theme,
              enabled: _inputMode == VolumetricInputMode.pesos,
              onTap: () {
                if (_inputMode != VolumetricInputMode.pesos) {
                  setState(() => _inputMode = VolumetricInputMode.pesos);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String prefix,
    required ThemeData theme,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      onTap: onTap,
      readOnly: !enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: enabled ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.4)),
        prefixText: prefix,
        filled: !enabled,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
         enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: enabled ? theme.primaryColor : Colors.grey.shade300,
            width: enabled ? 2.0 : 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  Widget _buildResponsiveBottomActionBar(BuildContext context) {
    if (_isVolumetric) {
      return _buildVolumetricBottomActionBar(context);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          return _buildCompactBottomActionBar(context);
        } else {
          return _buildWideBottomActionBar(context);
        }
      },
    );
  }

  Widget _buildVolumetricBottomActionBar(BuildContext context) {
    final theme = Theme.of(context);
    final total = double.tryParse(_pesosController.text) ?? 0.0;
    
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
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
          ),
    );
  }


  Widget _buildWideBottomActionBar(BuildContext context) {
    final theme = Theme.of(context);
    final total = _quantity * widget.product.price;
    final String unitText = (_quantity == 1.0) ? 'Pieza' : 'Piezas';

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildDiscreteQuantitySelector(theme),
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

  Widget _buildCompactBottomActionBar(BuildContext context) {
    final theme = Theme.of(context);
    final total = _quantity * widget.product.price;
    final String unitText = (_quantity == 1.0) ? 'Pieza' : 'Piezas';

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _buildDiscreteQuantitySelector(theme),
                Text(
                  unitText,
                  style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
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
          ),
        ],
      ),
    );
  }

  Widget _buildDiscreteQuantitySelector(ThemeData theme) {
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
            onPressed: () => _changeDiscreteQuantity(-1),
            icon: const Icon(Icons.remove, size: 20),
            splashRadius: 20,
            color: Colors.black54,
          ),
          SizedBox(
            width: 45,
            child: TextFormField(
              controller: _discreteController,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeDiscreteQuantity(1),
            icon: const Icon(Icons.add, size: 20),
            splashRadius: 20,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }
}
