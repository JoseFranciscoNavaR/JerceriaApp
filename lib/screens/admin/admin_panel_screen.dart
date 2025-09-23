import 'package:flutter/material.dart';
import '../home_screen.dart';
import './admin_product_list_screen.dart';
import './admin_category_list_screen.dart'; 
import './admin_order_list_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Panel de Administrador', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false, // No muestra la flecha de regreso
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              // Regresa a la pantalla de inicio y limpia el historial de navegación
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAdminCard(
            context,
            icon: Icons.store_outlined,
            title: 'Administrar Productos',
            subtitle: 'Editar, agregar o eliminar productos',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AdminProductListScreen()),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.category_outlined,
            title: 'Administrar Categorías',
            subtitle: 'Organizar productos en categorías',
            onTap: () {
              // Navigate to the new category list screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AdminCategoryListScreen()),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'Administrar Órdenes',
            subtitle: 'Ver y gestionar los pedidos de los clientes',
            onTap: () {
               Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AdminOrderListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}
