import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TareasPage(),
    ));

class DBTareas {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final ruta = join(await getDatabasesPath(), 'tareas.db');
    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE tareas (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, completada INTEGER DEFAULT 0)',
      ),
    );
    return _db!;
  }

  static Future<int> insertar(String titulo) async {
    final db = await database;
    return db.insert('tareas', {'titulo': titulo, 'completada': 0});
  }

  static Future<List<Map<String, dynamic>>> listar() async {
    final db = await database;
    return db.query('tareas', orderBy: 'id DESC');
  }

  static Future<int> cambiarEstado(int id, bool completada) async {
    final db = await database;
    return db.update(
      'tareas',
      {'completada': completada ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> eliminar(int id) async {
    final db = await database;
    return db.delete('tareas', where: 'id = ?', whereArgs: [id]);
  }
}

class TareasPage extends StatefulWidget {
  const TareasPage({super.key});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _tareas = [];
  String _filtro = 'todas';

  @override
  void initState() {
    super.initState();
    _cargarFiltro();
    _cargarTareas();
  }

  Future<void> _cargarFiltro() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _filtro = prefs.getString('filtro_tareas') ?? 'todas';
    });
  }

  Future<void> _guardarFiltro(String nuevoFiltro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('filtro_tareas', nuevoFiltro);
    setState(() => _filtro = nuevoFiltro);
  }

  Future<void> _cargarTareas() async {
    final datos = await DBTareas.listar();
    setState(() => _tareas = datos);
  }

  void _agregarTarea() async {
    if (_ctrl.text.isEmpty) return;
    await DBTareas.insertar(_ctrl.text);
    _ctrl.clear();
    _cargarTareas();
  }

  List<Map<String, dynamic>> get _tareasFiltradas {
    if (_filtro == 'pendientes') {
      return _tareas.where((t) => t['completada'] == 0).toList();
    } else if (_filtro == 'completadas') {
      return _tareas.where((t) => t['completada'] == 1).toList();
    }
    return _tareas;
  }

  @override
  Widget build(BuildContext context) {
    final lista = _tareasFiltradas;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Tareas Offline'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _filtro,
            onSelected: _guardarFiltro,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'todas', child: Text('Todas')),
              const PopupMenuItem(value: 'pendientes', child: Text('Pendientes')),
              const PopupMenuItem(value: 'completadas', child: Text('Completadas')),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(labelText: 'Nueva tarea'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue, size: 36),
                  onPressed: _agregarTarea,
                )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  final t = lista[i];
                  final bool esCompletada = t['completada'] == 1;
                  return Card(
                    child: ListTile(
                      leading: Checkbox(
                        value: esCompletada,
                        onChanged: (val) async {
                          await DBTareas.cambiarEstado(t['id'], val ?? false);
                          _cargarTareas();
                        },
                      ),
                      title: Text(
                        t['titulo'],
                        style: TextStyle(
                          decoration: esCompletada ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await DBTareas.eliminar(t['id']);
                          _cargarTareas();
                        },
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