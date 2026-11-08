import 'package:flutter/foundation.dart';
import '../models/evento_model.dart';

class EventoProvider extends ChangeNotifier {
  final List<Evento> _eventos = [];

  List<Evento> get eventos => List.unmodifiable(_eventos);

  void agregarEvento(String titulo, DateTime fecha) {
    final nuevo = Evento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      fecha: fecha,
    );
    _eventos.add(nuevo);
    notifyListeners();
  }

  void eliminarEvento(String id) {
    _eventos.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}