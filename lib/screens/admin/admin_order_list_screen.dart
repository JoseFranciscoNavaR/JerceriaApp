import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';
import 'package:jarceria_app/providers/order_provider.dart';
import 'package:jarceria_app/models/order_model.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  AdminOrderListScreenState createState() => AdminOrderListScreenState();
}

class AdminOrderListScreenState extends State<AdminOrderListScreen> {
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  String _sortOrder = 'Más Recientes';
  String _statusFilter = 'Todos';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    var orders = orderProvider.orders;

    // Filtering logic
    if (_statusFilter != 'Todos') {
      orders = orders.where((order) => order.status == _statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      orders = orders.where((order) {
        final query = _searchQuery.toLowerCase();
        return order.customerName.toLowerCase().contains(query) ||
               order.products.any((product) => product.name.toLowerCase().contains(query));
      }).toList();
    }

    if (_selectedDateRange != null) {
      orders = orders.where((order) {
        final orderDate = order.date;
        return orderDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
               orderDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sorting logic
    orders.sort((a, b) {
      switch (_sortOrder) {
        case 'Más Recientes':
          return b.date.compareTo(a.date);
        case 'Más Antiguas':
          return a.date.compareTo(b.date);
        case 'Monto (Mayor a Menor)':
          return b.totalAmount.compareTo(a.totalAmount);
        case 'Monto (Menor a Mayor)':
          return a.totalAmount.compareTo(b.totalAmount);
        default:
          return b.date.compareTo(a.date);
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Administrar Órdenes', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
      ),
      body: Column(
        children: [
          _buildSearchBarAndFilters(),
          _buildStatusFilters(),
          Expanded(
            child: orders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) => OrderTicketItem(order: orders[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por cliente o producto...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    _searchQuery = value;
                  });
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: _selectedDateRange == null
                ? 'Filtrar por Fecha'
                : 'Rango: ${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}',
            child: IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: () => _selectDateRange(context),
              color: _selectedDateRange != null ? Theme.of(context).primaryColor : Colors.grey[600],
            ),
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () => setState(() => _selectedDateRange = null),
              tooltip: "Limpiar filtro de fecha",
            ),
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _sortOrder = value),
            icon: Icon(Icons.sort, color: Colors.grey[600]),
            tooltip: 'Ordenar por: $_sortOrder',
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(value: 'Más Recientes', child: Text('Más Recientes')),
              const PopupMenuItem<String>(value: 'Más Antiguas', child: Text('Más Antiguas')),
              const PopupMenuItem<String>(value: 'Monto (Mayor a Menor)', child: Text('Monto (Mayor a Menor)')),
              const PopupMenuItem<String>(value: 'Monto (Menor a Mayor)', child: Text('Monto (Menor a Mayor)')),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['Todos', 'Pendiente', 'Completada', 'Cancelada'].map((status) {
          final isSelected = _statusFilter == status;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _statusFilter = status);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              shape: StadiumBorder(side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!)),

            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No se encontraron órdenes',
            style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otra búsqueda o filtro',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OrderTicketItem extends StatefulWidget {
  final Order order;

  const OrderTicketItem({super.key, required this.order});

  @override
  OrderTicketItemState createState() => OrderTicketItemState();
}

class OrderTicketItemState extends State<OrderTicketItem> {
  var _expanded = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.orange.shade300;
      case 'Completada':
        return Colors.green.shade400;
      case 'Cancelada':
        return Colors.red.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(Icons.receipt_long_outlined, color: theme.primaryColor, size: 36),
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
            title: Text(
              widget.order.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: MX\$${widget.order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd/MM/yyyy hh:mm a').format(widget.order.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(
                    widget.order.status,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(widget.order.status),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 28),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
                _buildActionMenu(orderProvider),
              ],
            ),
          ),
          if (_expanded) _buildExpandedDetails()
        ],
      ),
    );
  }

  Widget _buildActionMenu(OrderProvider orderProvider) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        orderProvider.updateOrderStatus(widget.order.id, value);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Pendiente',
          child: Text('Marcar como Pendiente'),
        ),
        const PopupMenuItem<String>(
          value: 'Completada',
          child: Text('Marcar como Completada'),
        ),
        const PopupMenuItem<String>(
          value: 'Cancelada',
          child: Text('Cancelar Orden'),
        ),
      ],
    );
  }

  Widget _buildExpandedDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          const Divider(thickness: 1, height: 1),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: min(widget.order.products.length * 28.0 + 10, 120),
            child: ListView(
              children: widget.order.products.map((prod) {
                final isVolumetric = prod.unit == 'Lt';
                final String detailsText;

                if (isVolumetric) {
                  final itemTotal = prod.totalPrice ?? (prod.quantity * prod.price);
                  detailsText = '${prod.quantity.toStringAsFixed(3)} ${prod.unit} x MX\$${itemTotal.toStringAsFixed(2)}';
                } else {
                  final itemTotal = prod.price * prod.quantity;
                  detailsText = '${prod.quantity.toStringAsFixed(0)} Pz x MX\$${itemTotal.toStringAsFixed(2)}';
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          prod.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        detailsText,
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
