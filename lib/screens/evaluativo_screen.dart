import 'package:flutter/material.dart';
import '../providers/evento_provider.dart';
import '../widgets/evento_tile.dart';

class EvaluativoScreen extends StatefulWidget {
  const EvaluativoScreen({super.key});

  @override
  State<EvaluativoScreen> createState() => _EvaluativoScreenState();
}

class _EvaluativoScreenState extends State<EvaluativoScreen> {
  final _tituloCtrl = TextEditingController();
  final _eventoProvider = EventoProvider();

  void _guardar() {
    if (_tituloCtrl.text.trim().isEmpty) return;
    _eventoProvider.agregarEvento(
          _tituloCtrl.text.trim(),
          DateTime.now(),
        );
    _tituloCtrl.clear();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _eventoProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de Eventos Refactorizado')),
      body: AnimatedBuilder(
        animation: _eventoProvider,
        builder: (context, _) {
          final eventos = _eventoProvider.eventos;
          return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tituloCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del Evento',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.add),
                        onPressed: _guardar,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: eventos.isEmpty
                      ? const Center(child: Text('No hay eventos registrados.'))
                      : ListView.builder(
                          itemCount: eventos.length,
                          itemBuilder: (context, index) {
                            final evento = eventos[index];
                            return EventoTile(
                              evento: evento,
                              onDelete: () =>
                                  _eventoProvider.eliminarEvento(evento.id),
                            );
                          },
                        ),
                ),
              ],
            );
        },
      ),
    );
  }
}