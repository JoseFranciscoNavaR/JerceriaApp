import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'models/product_model.dart';
import 'screens/home_screen.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Clear the old box to fix the data format error
  await Hive.deleteBoxFromDisk('products');

  Hive.registerAdapter(ProductAdapter());
  await Hive.openBox<Product>('products');

  // Function to add dummy products
  await addDummyProducts();

  runApp(MyApp());
}

Future<void> addDummyProducts() async {
  final productBox = Hive.box<Product>('products');

  // We always clear and re-add dummy data in this development version
  await productBox.clear();

  final products = [
      Product(id: Uuid().v4(), name: 'Limpiador Multiusos', description: 'Limpia y desinfecta cualquier superficie.', price: 25.50, imageUrl: 'https://i.imgur.com/example1.png', unit: 'Botella 1L'),
      Product(id: Uuid().v4(), name: 'Detergente para Ropa', description: 'Deja tu ropa limpia y con un aroma fresco.', price: 45.00, imageUrl: 'https://i.imgur.com/example2.png', unit: 'Bolsa 3kg'),
      Product(id: Uuid().v4(), name: 'Lavavajillas Líquido', description: 'Arranca la grasa más difícil de tus platos.', price: 30.20, imageUrl: 'https://i.imgur.com/example3.png', unit: 'Botella 750ml'),
      Product(id: Uuid().v4(), name: 'Suavizante de Telas', description: 'Ropa suave y perfumada por más tiempo.', price: 35.00, imageUrl: 'https://i.imgur.com/example4.png', unit: 'Botella 1.5L'),
      Product(id: Uuid().v4(), name: 'Limpiavidrios', description: 'Vidrios y espejos relucientes sin marcas.', price: 28.00, imageUrl: 'https://i.imgur.com/example5.png', unit: 'Botella 500ml'),
      Product(id: Uuid().v4(), name: 'Desinfectante en Aerosol', description: 'Elimina el 99.9% de los gérmenes y bacterias.', price: 40.00, imageUrl: 'https://i.imgur.com/example6.png', unit: 'Lata 400ml'),
      Product(id: Uuid().v4(), name: 'Pastillas para Sanitario', description: 'Mantén tu inodoro limpio y fresco con cada descarga.', price: 15.50, imageUrl: 'https://i.imgur.com/example7.png', unit: 'Paquete 2un'),
      Product(id: Uuid().v4(), name: 'Cera para Pisos', description: 'Brillo y protección para tus pisos de madera.', price: 60.00, imageUrl: 'https://i.imgur.com/example8.png', unit: 'Lata 900g'),
      Product(id: Uuid().v4(), name: 'Cloro Blanqueador', description: 'Desinfecta y blanquea tu ropa y superficies.', price: 22.00, imageUrl: 'https://i.imgur.com/example9.png', unit: 'Botella 2L'),
      Product(id: Uuid().v4(), name: 'Jabón de Manos', description: 'Limpia y protege tus manos de las bacterias.', price: 18.90, imageUrl: 'https://i.imgur.com/example10.png', unit: 'Botella 250ml'),
    ];

  for (var product in products) {
    await productBox.put(product.id, product);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CartProvider(),
      child: MaterialApp(
        title: 'Jarcería App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(
            secondary: Colors.amber,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
        routes: {},
      ),
    );
  }
}
