import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
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

  runApp(const MyApp());
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
