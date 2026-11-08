import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacionesService {
  static final plugin = FlutterLocalNotificationsPlugin();

  static Future<void> iniciar() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await plugin.initialize(settings: settings);
  }

  static Future<void> mostrar(String titulo, String cuerpo) async {
    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        'canal_practica_10',
        'Notificaciones Integradoras',
        channelDescription: 'Canal para alertas de la aplicación integradora',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: titulo,
      body: cuerpo,
      notificationDetails: detalles,
    );
  }
}