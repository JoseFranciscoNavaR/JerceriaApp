
import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child; // El widget sobre el cual se mostrará la insignia (ej. un Icon)
  final String value; // El texto que se mostrará en la insignia (ej. la cantidad)
  final Color? color;  // El color de fondo de la insignia

  const Badge({
    Key? key,
    required this.child,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child, // El widget principal (icono)
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: color ?? Theme.of(context).colorScheme.secondary, // Usa el color de acento si no se especifica
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white, // El texto de la insignia será blanco
              ),
            ),
          ),
        ),
      ],
    );
  }
}
