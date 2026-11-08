import 'package:flutter/material.dart';
import 'practica_08_guiado.dart'; // Importa el archivo guiado

void main() {
  runApp(const MiAppGuiado());
}

class MiAppGuiado extends StatelessWidget {
  const MiAppGuiado({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Práctica 08 - Guiado GPS',
      home: UbicacionPage(), // Clase principal de practica_08_guiado.dart
    );
  }
}