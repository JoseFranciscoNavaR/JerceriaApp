import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../services/database_service.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Product? product;

  AdminEditProductScreen({this.product});

  @override
  _AdminEditProductScreenState createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();
  final _uuid = Uuid();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isSoldByVolume = false;
  bool _isAvailable = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _brandController.text = widget.product!.brand ?? '';
      _selectedCategoryId = widget.product!.categoryId;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _isSoldByVolume = widget.product!.unit == 'Lt';
      _isAvailable = widget.product!.isAvailable;
    }
    _imageUrlController.addListener(_updateImagePreview);
  }

  Future<void> _loadCategories() async {
    final categories = _databaseService.getCategories();
    setState(() {
      _categories = categories;
      if (widget.product == null && _categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.removeListener(_updateImagePreview);
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImagePreview() {
    setState(() {});
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final newProduct = Product(
        id: widget.product?.id ?? _uuid.v4(),
        name: _nameController.text,
        brand: _brandController.text.isNotEmpty ? _brandController.text : null,
        categoryId: _selectedCategoryId!,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text,
        unit: _isSoldByVolume ? 'Lt' : 'Pz',
        isAvailable: _isAvailable,
      );

      if (widget.product == null) {
        await _databaseService.addProduct(newProduct);
      } else {
        await _databaseService.updateProduct(newProduct);
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto guardado exitosamente'), backgroundColor: Colors.green),
      );
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocurrió un error'),
          content: Text('No se pudo guardar el producto. Intente de nuevo.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.product == null ? 'Añadir Producto' : 'Editar Producto', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildImagePreview(),
                  SizedBox(height: 20),
                  _buildTextFormField(controller: _nameController, labelText: 'Nombre del Producto', validator: (v) => v!.isEmpty ? 'Este campo es obligatorio.' : null),
                  SizedBox(height: 20),
                  _buildTextFormField(controller: _brandController, labelText: 'Marca (Opcional)', validator: (v) => null),
                  SizedBox(height: 20),
                  _buildCategoryDropdown(),
                  SizedBox(height: 20),
                  _buildTextFormField(controller: _descriptionController, labelText: 'Descripción', maxLines: 3, validator: (v) => v!.isEmpty ? 'Este campo es obligatorio.' : null),
                  SizedBox(height: 20),
                  _buildTextFormField(controller: _priceController, labelText: 'Precio', keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Número inválido';
                    if (double.parse(v) <= 0) return '> 0';
                    return null;
                  }),
                  SizedBox(height: 20),
                  _buildTextFormField(controller: _imageUrlController, labelText: 'URL de la Imagen', keyboardType: TextInputType.url, validator: (v) {
                    if (v == null || v.isEmpty) return 'Este campo es obligatorio.';
                    final uri = Uri.tryParse(v);
                    if (uri == null || !uri.isAbsolute) return 'Por favor, introduce una URL válida.';
                    return null;
                  }),
                  SizedBox(height: 20),
                  SwitchListTile(
                    title: Text('Vendido por volumen'),
                    subtitle: Text(_isSoldByVolume ? 'La unidad se establecerá en Litros (Lt)' : 'La unidad se establecerá en Piezas (Pz)'),
                    value: _isSoldByVolume,
                    onChanged: (bool value) {
                      setState(() {
                        _isSoldByVolume = value;
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Colors.grey[300],
                    inactiveThumbColor: Colors.grey[600],
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: Text('Disponible para la venta'),
                    value: _isAvailable,
                    onChanged: (bool value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Colors.grey[300],
                    inactiveThumbColor: Colors.grey[600],
                    contentPadding: EdgeInsets.zero,
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveForm,
                      icon: _isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) : Icon(Icons.save_alt_outlined),
                      label: Text(_isLoading ? 'Guardando...' : 'Guardar Producto', style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Categoría',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      items: _categories.map((Category category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategoryId = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, seleccione una categoría.';
        }
        return null;
      },
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String labelText, int maxLines = 1, TextInputType keyboardType = TextInputType.text, required FormFieldValidator<String> validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final imageUrl = _imageUrlController.text;
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasAbsolutePath == true
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null ? child : Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error_outline, color: Colors.red, size: 50),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 50, color: Colors.grey[400]),
                  SizedBox(height: 8),
                  Text('Vista previa de la imagen', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
    );
  }
}
