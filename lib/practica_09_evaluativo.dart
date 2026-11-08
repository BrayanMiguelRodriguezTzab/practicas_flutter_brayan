import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BitacoraInspeccionPage(),
    ));

class TarjetaEvidencia {
  final String id;
  final String titulo;
  final String rutaImagen;
  final DateTime fechaHora;
  final String acelerometro;
  final String giroscopio;

  TarjetaEvidencia({
    required this.id,
    required this.titulo,
    required this.rutaImagen,
    required this.fechaHora,
    required this.acelerometro,
    required this.giroscopio,
  });
}

class BitacoraInspeccionPage extends StatefulWidget {
  const BitacoraInspeccionPage({super.key});

  @override
  State<BitacoraInspeccionPage> createState() => _BitacoraInspeccionPageState();
}

class _BitacoraInspeccionPageState extends State<BitacoraInspeccionPage> {
  final _tituloCtrl = TextEditingController();
  final List<TarjetaEvidencia> _evidencias = [];

  double _accX = 0, _accY = 0, _accZ = 0;
  double _gyroX = 0, _gyroY = 0, _gyroZ = 0;

  @override
  void initState() {
    super.initState();
    accelerometerEventStream().listen((e) {
      if (mounted) {
        setState(() {
          _accX = e.x;
          _accY = e.y;
          _accZ = e.z;
        });
      }
    });

    gyroscopeEventStream().listen((e) {
      if (mounted) {
        setState(() {
          _gyroX = e.x;
          _gyroY = e.y;
          _gyroZ = e.z;
        });
      }
    });
  }

  Future<void> _capturarEvidencia() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un título de inspección')),
      );
      return;
    }

    final XFile? foto = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (foto == null) return; // Manejo seguro de cancelación de cámara

    final nuevaEvidencia = TarjetaEvidencia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloCtrl.text.trim(),
      rutaImagen: foto.path,
      fechaHora: DateTime.now(),
      acelerometro: 'X: ${_accX.toStringAsFixed(2)}, Y: ${_accY.toStringAsFixed(2)}, Z: ${_accZ.toStringAsFixed(2)}',
      giroscopio: 'X: ${_gyroX.toStringAsFixed(2)}, Y: ${_gyroY.toStringAsFixed(2)}, Z: ${_gyroZ.toStringAsFixed(2)}',
    );

    setState(() {
      _evidencias.insert(0, nuevaEvidencia);
      _tituloCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora de Inspección')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lecturas en Tiempo Real:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Acelerómetro: X: ${_accX.toStringAsFixed(2)}, Y: ${_accY.toStringAsFixed(2)}, Z: ${_accZ.toStringAsFixed(2)}'),
                    Text('Giroscopio: X: ${_gyroX.toStringAsFixed(2)}, Y: ${_gyroY.toStringAsFixed(2)}, Z: ${_gyroZ.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tituloCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Punto / Elemento a inspeccionar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: _capturarEvidencia,
                ),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: _evidencias.isEmpty
                  ? const Center(child: Text('No hay evidencias registradas.'))
                  : ListView.builder(
                      itemCount: _evidencias.length,
                      itemBuilder: (context, i) {
                        final item = _evidencias[i];
                        final fechaStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(item.fechaHora);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Fecha/Hora: $fechaStr', style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Image.file(File(item.rutaImagen), height: 180, width: double.infinity, fit: BoxFit.cover),
                                const SizedBox(height: 8),
                                Text('Acc: ${item.acelerometro}', style: const TextStyle(fontSize: 12)),
                                Text('Gyro: ${item.giroscopio}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}