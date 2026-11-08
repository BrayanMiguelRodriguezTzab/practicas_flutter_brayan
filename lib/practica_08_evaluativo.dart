import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PuntosInteresPage(),
    ));

class PuntoInteres {
  final String nombre;
  final double latitud;
  final double longitud;

  PuntoInteres({
    required this.nombre,
    required this.latitud,
    required this.longitud,
  });
}

class PuntosInteresPage extends StatefulWidget {
  const PuntosInteresPage({super.key});

  @override
  State<PuntosInteresPage> createState() => _PuntosInteresPageState();
}

class _PuntosInteresPageState extends State<PuntosInteresPage> {
  Position? _posicionActual;
  String _estado = 'Obteniendo GPS...';
  final _nombreCtrl = TextEditingController();

  final List<PuntoInteres> _puntos = [
    PuntoInteres(nombre: 'ITESCAM Calkiní', latitud: 20.3705, longitud: -90.0478),
    PuntoInteres(nombre: 'Parque Principal Calkiní', latitud: 20.3722, longitud: -90.0511),
    PuntoInteres(nombre: 'Plaza Central Campeche', latitud: 19.8464, longitud: -90.5360),
  ];

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionActual();
  }

  Future<void> _obtenerUbicacionActual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _estado = 'Servicio de ubicación desactivado');
      return;
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        setState(() => _estado = 'Permiso denegado');
        return;
      }
    }

    final p = await Geolocator.getCurrentPosition();
    setState(() {
      _posicionActual = p;
      _estado = 'Ubicación actual disponible';
    });
  }

  void _guardarUbicacionActualComoPOI() {
    if (_posicionActual == null || _nombreCtrl.text.trim().isEmpty) return;
    setState(() {
      _puntos.add(PuntoInteres(
        nombre: _nombreCtrl.text.trim(),
        latitud: _posicionActual!.latitude,
        longitud: _posicionActual!.longitude,
      ));
      _nombreCtrl.clear();
    });
  }

  String _calcularDistanciaTexto(double lat, double lng) {
    if (_posicionActual == null) return 'Calculando...';
    final distanciaMetros = Geolocator.distanceBetween(
      _posicionActual!.latitude,
      _posicionActual!.longitude,
      lat,
      lng,
    );
    if (distanciaMetros >= 1000) {
      return '${(distanciaMetros / 1000).toStringAsFixed(2)} km';
    }
    return '${distanciaMetros.toStringAsFixed(0)} m';
  }

  Future<void> _abrirEnMapa(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puntos de Interés & GPS')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(_estado, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (_posicionActual != null)
                      Text('Mi posición: ${_posicionActual!.latitude.toStringAsFixed(4)}, ${_posicionActual!.longitude.toStringAsFixed(4)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo Punto de Interés',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add_location_alt),
                  onPressed: _guardarUbicacionActualComoPOI,
                )
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _puntos.length,
                itemBuilder: (context, i) {
                  final poi = _puntos[i];
                  final distancia = _calcularDistanciaTexto(poi.latitud, poi.longitud);
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.place)),
                      title: Text(poi.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Lat: ${poi.latitud}, Lng: ${poi.longitud}\nDistancia: $distancia'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        onPressed: () => _abrirEnMapa(poi.latitud, poi.longitud),
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