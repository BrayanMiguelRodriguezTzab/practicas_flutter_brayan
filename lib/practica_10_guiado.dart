import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'services/notificaciones_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacionesService.iniciar();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IncidenciasPage(),
  ));
}

class IncidenciasDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final ruta = p.join(await getDatabasesPath(), 'incidencias.db');
    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE incidencias (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, descripcion TEXT, categoria TEXT, foto TEXT, lat REAL, lng REAL, fecha TEXT)',
      ),
    );
    return _db!;
  }

  static Future<int> insertar(Map<String, dynamic> item) async {
    final db = await database;
    return db.insert('incidencias', item);
  }

  static Future<List<Map<String, dynamic>>> listar() async {
    final db = await database;
    return db.query('incidencias', orderBy: 'id DESC');
  }
}

class IncidenciasPage extends StatefulWidget {
  const IncidenciasPage({super.key});

  @override
  State<IncidenciasPage> createState() => _IncidenciasPageState();
}

class _IncidenciasPageState extends State<IncidenciasPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _categoria = 'Mantenimiento';
  XFile? _foto;
  Position? _posicion;
  List<Map<String, dynamic>> _lista = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final datos = await IncidenciasDB.listar();
    setState(() => _lista = datos);
  }

  Future<void> _obtenerUbicacionYFoto() async {
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso != LocationPermission.denied && permiso != LocationPermission.deniedForever) {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _posicion = pos);
    }
    final img = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 75);
    if (img != null) setState(() => _foto = img);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final item = {
      'titulo': _tituloCtrl.text.trim(),
      'descripcion': _descCtrl.text.trim(),
      'categoria': _categoria,
      'foto': _foto?.path ?? '',
      'lat': _posicion?.latitude ?? 0.0,
      'lng': _posicion?.longitude ?? 0.0,
      'fecha': DateTime.now().toString(),
    };
    await IncidenciasDB.insertar(item);
    await NotificacionesService.mostrar(
      'Reporte Registrado',
      'Incidencia "${_tituloCtrl.text}" guardada con éxito.',
    );
    _tituloCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _foto = null;
      _posicion = null;
    });
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte Móvil de Incidencias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  DropdownButton<String>(
                    value: _categoria,
                    isExpanded: true,
                    items: ['Mantenimiento', 'Seguridad', 'Limpieza']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoria = v!),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _obtenerUbicacionYFoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Capturar Evidencia'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _guardar,
                        child: const Text('Guardar Incidencia'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _lista.length,
                itemBuilder: (context, i) {
                  final item = _lista[i];
                  return ListTile(
                    leading: item['foto'].isNotEmpty
                        ? Image.file(File(item['foto']), width: 50, fit: BoxFit.cover)
                        : const Icon(Icons.warning),
                    title: Text(item['titulo']),
                    subtitle: Text('${item['categoria']} - ${item['fecha']}'),
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