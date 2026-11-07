import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/db.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GuiadoPage(),
    ));

class GuiadoPage extends StatefulWidget {
  const GuiadoPage({super.key});

  @override
  State<GuiadoPage> createState() => _GuiadoPageState();
}

class _GuiadoPageState extends State<GuiadoPage> {
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  final _usuarioCtrl = TextEditingController();
  String _usuarioGuardado = 'Invitado';
  List<Map<String, dynamic>> _notas = [];
  int? _idSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
    _cargarNotas();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usuarioGuardado = prefs.getString('nombre_usuario') ?? 'Invitado';
    });
  }

  Future<void> _guardarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre_usuario', _usuarioCtrl.text);
    _cargarUsuario();
  }

  Future<void> _cargarNotas() async {
    final datos = await DB.listar();
    setState(() => _notas = datos);
  }

  void _guardarOActualizar() async {
    if (_tituloCtrl.text.isEmpty) return;
    if (_idSeleccionado == null) {
      await DB.insertar(_tituloCtrl.text, _contenidoCtrl.text);
    } else {
      await DB.actualizar(_idSeleccionado!, _tituloCtrl.text, _contenidoCtrl.text);
      _idSeleccionado = null;
    }
    _tituloCtrl.clear();
    _contenidoCtrl.clear();
    _cargarNotas();
  }

  void _eliminarNota(int id) async {
    await DB.eliminar(id);
    _cargarNotas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notas de $_usuarioGuardado')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usuarioCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _guardarUsuario,
                  child: const Text('Guardar Nombre'),
                )
              ],
            ),
            const Divider(),
            TextField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: 'Título de la nota'),
            ),
            TextField(
              controller: _contenidoCtrl,
              decoration: const InputDecoration(labelText: 'Contenido'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _guardarOActualizar,
              child: Text(_idSeleccionado == null ? 'Guardar Nota' : 'Actualizar Nota'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _notas.length,
                itemBuilder: (context, i) {
                  final n = _notas[i];
                  return ListTile(
                    title: Text(n['titulo']),
                    subtitle: Text(n['contenido']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarNota(n['id']),
                    ),
                    onTap: () {
                      setState(() {
                        _idSeleccionado = n['id'];
                        _tituloCtrl.text = n['titulo'];
                        _contenidoCtrl.text = n['contenido'];
                      });
                    },
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