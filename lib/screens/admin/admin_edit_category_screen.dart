import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/category_model.dart';
import '../../services/database_service.dart';

class AdminEditCategoryScreen extends StatefulWidget {
  final Category? category;

  const AdminEditCategoryScreen({Key? key, this.category}) : super(key: key);

  @override
  _AdminEditCategoryScreenState createState() => _AdminEditCategoryScreenState();
}

class _AdminEditCategoryScreenState extends State<AdminEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();
  static const _uuid = Uuid();

  final _nameController = TextEditingController();
  bool _isAvailable = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _isAvailable = widget.category!.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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

    try {
      final newCategory = Category(
        id: widget.category?.id ?? _uuid.v4(),
        name: _nameController.text,
        isAvailable: _isAvailable,
      );

      if (widget.category == null) {
        await _databaseService.addCategory(newCategory);
      } else {
        await _databaseService.updateCategory(newCategory);
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría guardada exitosamente'), backgroundColor: Colors.green),
      );
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocurrió un error'),
          content: const Text('No se pudo guardar la categoría. Intente de nuevo.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
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
        title: Text(widget.category == null ? 'Añadir Categoría' : 'Editar Categoría', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  _buildTextFormField(controller: _nameController, labelText: 'Nombre de la Categoría', validator: (v) => v!.isEmpty ? 'Este campo es obligatorio.' : null),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Disponible para la venta'),
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
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveForm,
                      icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) : const Icon(Icons.save_alt_outlined),
                      label: Text(_isLoading ? 'Guardando...' : 'Guardar Categoría', style: const TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
}
