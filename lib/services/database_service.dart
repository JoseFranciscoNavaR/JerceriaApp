
import 'package:hive/hive.dart';
import '../models/product_model.dart';

class DatabaseService {
  // Obtiene la caja de productos
  final Box<Product> _productBox = Hive.box<Product>('products');

  // Obtener todos los productos
  List<Product> getProducts() {
    return _productBox.values.toList();
  }

  // Añadir un nuevo producto
  Future<void> addProduct(Product product) async {
    // Usamos el id como clave para facilitar la búsqueda y actualización
    await _productBox.put(product.id, product);
  }

  // Actualizar un producto existente
  Future<void> updateProduct(Product product) async {
    await _productBox.put(product.id, product);
  }

  // Eliminar un producto
  Future<void> deleteProduct(String productId) async {
    await _productBox.delete(productId);
  }
}
