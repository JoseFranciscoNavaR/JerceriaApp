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
  _AdminOrderListScreenState createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  String _sortOrder = 'Más Recientes'; 
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
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((order) {
        return order.products.any((product) => product.name.toLowerCase().contains(_searchQuery.toLowerCase()));
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
      if (_sortOrder == 'Más Recientes') {
        return b.date.compareTo(a.date);
      } else {
        return a.date.compareTo(b.date);
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por producto...',
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
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _selectedDateRange = null),
                    tooltip: "Limpiar filtro",
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _sortOrder = value;
                    });
                  },
                  icon: Icon(Icons.sort, color: Colors.grey[600]),
                  tooltip: 'Ordenar por: $_sortOrder',
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Más Recientes',
                      child: Text('Más Recientes'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Más Antiguas',
                      child: Text('Más Antiguas'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? Center(
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
                  )
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
}


class OrderTicketItem extends StatefulWidget {
  final Order order;

  const OrderTicketItem({super.key, required this.order});

  @override
  _OrderTicketItemState createState() => _OrderTicketItemState();
}

class _OrderTicketItemState extends State<OrderTicketItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
              'Total: MX\$${widget.order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm a').format(widget.order.date),
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 28),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_expanded)
            Padding(
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
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                detailsText,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
