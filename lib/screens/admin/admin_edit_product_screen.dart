import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jarceria_app/models/category_model.dart';
import '../../models/product_model.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Product? product;

  const AdminEditProductScreen({super.key, this.product});

  @override
  AdminEditProductScreenState createState() => AdminEditProductScreenState();
}

class AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  File? _imageFile;

  String? _selectedCategoryId;
  bool _isSoldByVolume = false;
  bool _isAvailable = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _brandController.text = widget.product!.brand ?? '';
      _selectedCategoryId = widget.product!.categoryId;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _isSoldByVolume = widget.product!.unit == 'Lt';
      _isAvailable = widget.product!.isAvailable;
    }
     _imageUrlController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrlController.clear();
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child('${DateTime.now().toIso8601String()}.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen: $e')),
      );
      return null;
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos requeridos.')),
      );
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    String? finalImageUrl = _imageUrlController.text;
    if (_imageFile != null) {
      finalImageUrl = await _uploadImage(_imageFile!);
      if (finalImageUrl == null) {
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      final productData = {
        'name': _nameController.text,
        'brand': _brandController.text.isNotEmpty ? _brandController.text : null,
        'categoryId': _selectedCategoryId!,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'imageUrl': finalImageUrl,
        'unit': _isSoldByVolume ? 'Lt' : 'Pz',
        'isAvailable': _isAvailable,
      };

      if (widget.product == null) {
        await FirebaseFirestore.instance.collection('products').add(productData);
      } else {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product!.id)
            .update(productData);
      }
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el producto: $error')),
      );
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.product == null ? 'Añadir Producto' : 'Editar Producto',
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_search),
                    label: const Text('Seleccionar Imagen'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                      controller: _nameController,
                      labelText: 'Nombre del Producto',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                      controller: _brandController, labelText: 'Marca (Opcional)'),
                  const SizedBox(height: 20),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 20),
                   _buildTextFormField(
                    controller: _imageUrlController,
                    labelText: 'URL de la Imagen (Opcional)',
                    onChanged: (value) {
                      setState(() {
                        _imageFile = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                      controller: _descriptionController,
                      labelText: 'Descripción (Opcional)',
                      maxLines: 3),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                      controller: _priceController,
                      labelText: 'Precio',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (double.tryParse(v) == null) return 'Número inválido';
                        if (double.parse(v) <= 0) return '> 0';
                        return null;
                      }),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Vendido por volumen'),
                    subtitle: Text(_isSoldByVolume
                        ? 'La unidad se establecerá en Litros (Lt)'
                        : 'La unidad se establecerá en Piezas (Pz)'),
                    value: _isSoldByVolume,
                    onChanged: (bool value) {
                      setState(() {
                        _isSoldByVolume = value;
                      });
                    },
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade300,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Disponible para la venta'),
                    value: _isAvailable,
                    onChanged: (bool value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade300,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveForm,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3, color: Colors.white))
                          : const Icon(Icons.save_alt_outlined),
                      label: Text(
                          _isLoading ? 'Guardando...' : 'Guardar Producto',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').where('isAvailable', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        var categories = snapshot.data!.docs.map((doc) => Category.fromFirestore(doc)).toList();

        if (_selectedCategoryId == null && categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedCategoryId,
          decoration: InputDecoration(
            labelText: 'Categoría',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          items: categories.map((Category category) {
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
          validator: (value) => value == null ? 'Requerido' : null,
        );
      },
    );
  }

    Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
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
      child: _imageFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_imageFile!, fit: BoxFit.cover),
            )
          : (imageUrl.isNotEmpty)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Vista previa de la imagen',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
    );
  }

}
