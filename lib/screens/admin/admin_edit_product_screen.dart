
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/product_model.dart';
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
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
      _imageUrlController.text = widget.product!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
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

    final name = _nameController.text;
    final price = double.parse(_priceController.text);
    final description = _descriptionController.text;
    final imageUrl = _imageUrlController.text;

    try {
      if (widget.product == null) {
        // Crear nuevo producto
        final newProduct = Product(
          id: _uuid.v4(), // Generar un ID único
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
        );
        await _databaseService.addProduct(newProduct);
      } else {
        // Actualizar producto existente
        widget.product!.name = name;
        widget.product!.price = price;
        widget.product!.description = description;
        widget.product!.imageUrl = imageUrl;
        await _databaseService.updateProduct(widget.product!);
      }
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocurrió un error'),
          content: Text('No se pudo guardar el producto. Intente de nuevo.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Añadir Producto' : 'Editar Producto'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Muestra un spinner mientras guarda
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nombre del Producto'),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value!.isEmpty ? 'Este campo es obligatorio.' : null,
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Precio'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value!.isEmpty) return 'Este campo es obligatorio.';
                        if (double.tryParse(value) == null) return 'Ingrese un número válido.';
                        if (double.parse(value) <= 0) return 'El precio debe ser mayor a cero.';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Descripción'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) => value!.isEmpty ? 'Este campo es obligatorio.' : null,
                    ),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(labelText: 'URL de la Imagen'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _saveForm(),
                      validator: (value) {
                        if (value!.isEmpty) return 'Este campo es obligatorio.';
                        // Opcional: validación de URL más estricta
                        if (!value.startsWith('http')) return 'Ingrese una URL válida.';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
