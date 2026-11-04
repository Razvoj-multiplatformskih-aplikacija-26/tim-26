import 'package:flutter/material.dart';

class CartMapTitle extends StatelessWidget {
  const CartMapTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shopping_cart, color: color),
        const SizedBox(width: 8),
        Text(
          'CartMap',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 30,
            letterSpacing: 0.5,
            color: color,
          ),
        ),
      ],
    );
  }
}