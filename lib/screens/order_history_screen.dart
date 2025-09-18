import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:jarceria_app/providers/order_provider.dart';
import 'package:jarceria_app/models/order_model.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OrderProvider>(
        builder: (ctx, orderData, child) {
          if (orderData.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text(
                    'No tienes órdenes aún',
                    style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tus compras aparecerán aquí',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            itemCount: orderData.orders.length,
            itemBuilder: (ctx, i) => OrderTicketItem(order: orderData.orders[i]),
          );
        },
      ),
    );
  }
}

class OrderTicketItem extends StatefulWidget {
  final Order order;

  const OrderTicketItem({Key? key, required this.order}) : super(key: key);

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
            contentPadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
            title: Text(
              'Total: \$${widget.order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm a').format(widget.order.date),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.order.isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Nuevo',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 28),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                    if (widget.order.isNew) {
                      Provider.of<OrderProvider>(context, listen: false)
                          .markOrderAsRead(widget.order.id);
                    }
                  },
                ),
              ],
            ),
          ),
          if (_expanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              height: min(widget.order.products.length * 28.0 + 10, 120),
              child: ListView(
                children: widget.order.products
                    .map(
                      (prod) => Padding(
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
                              '${prod.quantity} x \$${prod.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
        ],
      ),
    );
  }
}
