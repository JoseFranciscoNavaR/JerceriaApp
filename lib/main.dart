import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'models/product_model.dart';
import 'models/category_model.dart';
import 'screens/home_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CategoryAdapter());

  // Clear boxes for fresh start in development
  await Hive.deleteBoxFromDisk('products');
  await Hive.deleteBoxFromDisk('categories');

  // Open boxes
  await Hive.openBox<Product>('products');
  await Hive.openBox<Category>('categories');

  // Add dummy data
  await addDummyCategories();
  await addDummyProducts();

  runApp(const MyApp());
}

Future<void> addDummyCategories() async {
  final categoryBox = Hive.box<Category>('categories');
  const uuid = Uuid();
  final categories = [
    Category(id: uuid.v4(), name: 'Limpieza Hogar'),
    Category(id: uuid.v4(), name: 'Cuidado Ropa'),
    Category(id: uuid.v4(), name: 'Cuidado Personal'),
    Category(id: uuid.v4(), name: 'Automotriz', isAvailable: false),
  ];

  for (var category in categories) {
    await categoryBox.put(category.id, category);
  }
}

Future<void> addDummyProducts() async {
  final productBox = Hive.box<Product>('products');
  final categoryBox = Hive.box<Category>('categories');
  const uuid = Uuid();

  final limpiezaHogar = categoryBox.values.firstWhere((c) => c.name == 'Limpieza Hogar');
  final cuidadoRopa = categoryBox.values.firstWhere((c) => c.name == 'Cuidado Ropa');
  final cuidadoPersonal = categoryBox.values.firstWhere((c) => c.name == 'Cuidado Personal');

  final products = [
    Product(id: uuid.v4(), name: 'Limpiador Multiusos', description: 'Limpia y desinfecta cualquier superficie del hogar.', price: 25.50, imageUrl: 'https://i.imgur.com/6wF4w2G.png', categoryId: limpiezaHogar.id, unit: 'Lt', brand: 'Fabuloso'),
    Product(id: uuid.v4(), name: 'Detergente para Ropa', description: 'Deja tu ropa limpia y con un aroma fresco.', price: 85.00, imageUrl: 'https://i.imgur.com/J8xP3LY.png', categoryId: cuidadoRopa.id, unit: 'Lt', brand: 'Ariel'),
    Product(id: uuid.v4(), name: 'Lavavajillas Líquido', description: 'Arranca la grasa más difícil de tus platos.', price: 30.20, imageUrl: 'https://i.imgur.com/A4E3A9s.png', categoryId: limpiezaHogar.id, unit: 'Lt', brand: 'Salvo'),
    Product(id: uuid.v4(), name: 'Suavizante de Telas', description: 'Ropa suave y perfumada por más tiempo.', price: 35.00, imageUrl: 'https://i.imgur.com/5J2b1Dk.png', categoryId: cuidadoRopa.id, unit: 'Lt', brand: 'Ensueño'),
    Product(id: uuid.v4(), name: 'Limpiavidrios', description: 'Vidrios y espejos relucientes sin marcas.', price: 28.00, imageUrl: 'https://i.imgur.com/vM2fT3a.png', categoryId: limpiezaHogar.id, unit: 'Pz', brand: 'Windex'),
    Product(id: uuid.v4(), name: 'Desinfectante en Aerosol', description: 'Elimina el 99.9% de los gérmenes y bacterias.', price: 40.00, imageUrl: 'https://i.imgur.com/h9x1b8c.png', categoryId: limpiezaHogar.id, unit: 'Pz', brand: 'Lysol'),
    Product(id: uuid.v4(), name: 'Pastillas para Sanitario', description: 'Mantén tu inodoro limpio y fresco con cada descarga.', price: 15.50, imageUrl: 'https://i.imgur.com/sS8EXR6.png', categoryId: limpiezaHogar.id, unit: 'Pz', brand: 'Pato'),
    Product(id: uuid.v4(), name: 'Cera para Pisos', description: 'Brillo y protección para tus pisos de madera.', price: 60.00, imageUrl: 'https://i.imgur.com/7b3E2S1.png', categoryId: limpiezaHogar.id, unit: 'Pz', isAvailable: false),
    Product(id: uuid.v4(), name: 'Cloro Blanqueador', description: 'Desinfecta y blanquea tu ropa y superficies.', price: 22.00, imageUrl: 'https://i.imgur.com/O3iSg3A.png', categoryId: cuidadoRopa.id, unit: 'Lt', brand: 'Cloralex'),
    Product(id: uuid.v4(), name: 'Jabón de Manos', description: 'Limpia y protege tus manos de las bacterias.', price: 18.90, imageUrl: 'https://i.imgur.com/tS5wA3a.png', categoryId: cuidadoPersonal.id, unit: 'Lt'),
  ];

  for (var product in products) {
    await productBox.put(product.id, product);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => NavigationProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jarcería App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(
            secondary: Colors.amber,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        routes: const {},
      ),
    );
  }
}
