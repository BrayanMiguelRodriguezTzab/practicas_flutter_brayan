import 'package:flutter/material.dart';

class ContadorCard extends StatelessWidget {
  final int valor;
  const ContadorCard({super.key, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Valor del Contador:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '$valor',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}