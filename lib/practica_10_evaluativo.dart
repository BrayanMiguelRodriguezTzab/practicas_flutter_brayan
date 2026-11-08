import 'package:flutter/material.dart';
import 'services/notificaciones_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacionesService.iniciar();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: EventosStaffPage(),
  ));
}

class EventosStaffPage extends StatefulWidget {
  const EventosStaffPage({super.key});

  @override
  State<EventosStaffPage> createState() => _EventosStaffPageState();
}

class _EventosStaffPageState extends State<EventosStaffPage> {
  final _formKey = GlobalKey<FormState>();
  final _eventoCtrl = TextEditingController();
  final _lugarCtrl = TextEditingController();
  final List<Map<String, String>> _eventos = [];

  void _guardarEvento() async {
    if (!_formKey.currentState!.validate()) return;
    final nuevo = {
      'evento': _eventoCtrl.text.trim(),
      'lugar': _lugarCtrl.text.trim(),
      'fecha': DateTime.now().toString().substring(0, 16),
    };

    setState(() {
      _eventos.add(nuevo);
    });

    await NotificacionesService.mostrar(
      'Nuevo Evento Registrado',
      'Asignación a "${_eventoCtrl.text}" guardada.',
    );

    _eventoCtrl.clear();
    _lugarCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión Eventos Staff Móvil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _eventoCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del Evento'),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese nombre' : null,
                  ),
                  TextFormField(
                    controller: _lugarCtrl,
                    decoration: const InputDecoration(labelText: 'Lugar / Sede'),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese lugar' : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _guardarEvento,
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Registrar Evento y Notificar'),
                  ),
                ],
              ),
            ),
            const Divider(height: 30),
            Expanded(
              child: _eventos.isEmpty
                  ? const Center(child: Text('No hay eventos programados.'))
                  : ListView.builder(
                      itemCount: _eventos.length,
                      itemBuilder: (context, i) {
                        final ev = _eventos[i];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.event)),
                            title: Text(ev['evento']!),
                            subtitle: Text('Sede: ${ev['lugar']} | ${ev['fecha']}'),
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