import 'package:flutter/material.dart';
import 'practica_08_evaluativo.dart'; // Importa el archivo evaluativo

void main() {
  runApp(const MiAppEvaluativo());
}

class MiAppEvaluativo extends StatelessWidget {
  const MiAppEvaluativo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Práctica 08 - Evaluativo GPS',
      home: PuntosInteresPage(), // Clase principal de practica_08_evaluativo.dart
    );
  }
}