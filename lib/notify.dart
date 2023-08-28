/*import 'package:autistapp/tarea.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> programarNotificaciones(ListaTareas listaTareas) async {
  // Inicializar el plugin de notificaciones
  const initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final initializationSettings = const InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Cancelar todas las notificaciones existentes
  await flutterLocalNotificationsPlugin.cancelAll();

  // Programar notificaciones para cada tarea
  for (final tarea in listaTareas.tareas) {
    if (!tarea.completada) {
      final id = tarea.id.hashCode;
      final titulo = 'Recordatorio de tarea';
      final cuerpo = tarea.nombre;

      if (tarea.fechaLimite != null && tarea.fechaLimite != DateTime(9999)) {
        // Programar notificaciones antes de la fecha límite
        final fechaLimite = tarea.fechaLimite;
        final tzFechaLimite = tz.TZDateTime.from(fechaLimite!, tz.local);
        if (tarea.prioridad == 2) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            titulo,
            cuerpo,
            tzFechaLimite.subtract(const Duration(hours: 6)),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'Tarea',
                'Recordatorios de tareas',
              ),
            ),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          await flutterLocalNotificationsPlugin.zonedSchedule(
            id + 1,
            titulo,
            cuerpo,
            tzFechaLimite.subtract(const Duration(hours: 3)),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'Tarea',
                'Recordatorios de tareas',
              ),
            ),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
        if (tarea.prioridad >= 1) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            id + 2,
            titulo,
            cuerpo,
            tzFechaLimite.subtract(const Duration(hours: 1)),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'Tarea',
                'Recordatorios de tareas',
              ),
            ),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      } else {
        // Programar notificaciones periódicas
        final intervalo = Duration(
            hours: tarea.prioridad == 2
                ? 1
                : tarea.prioridad == 1
                    ? 3
                    : 24);
        await flutterLocalNotificationsPlugin.periodicallyShow(
          id,
          titulo,
          cuerpo,
          RepeatInterval.everyMinute,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'Tarea',
              'Recordatorios de tareas',
            ),
          ),
          androidAllowWhileIdle: true,
        );
      }
    }
  }
}
*/