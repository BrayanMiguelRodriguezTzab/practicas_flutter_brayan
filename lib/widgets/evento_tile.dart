import 'package:flutter/material.dart';
import '../models/evento_model.dart';

class EventoTile extends StatelessWidget {
  final Evento evento;
  final VoidCallback onDelete;

  const EventoTile({
    super.key,
    required this.evento,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fechaFormateada =
      '${evento.fecha.day.toString().padLeft(2, '0')}/'
      '${evento.fecha.month.toString().padLeft(2, '0')}/'
      '${evento.fecha.year} - '
      '${evento.fecha.hour.toString().padLeft(2, '0')}:'
      '${evento.fecha.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.event)),
        title: Text(
          evento.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Fecha: $fechaFormateada'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}