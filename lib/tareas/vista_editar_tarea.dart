import 'dart:math';

import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/tareas/lista_tareas.dart';
import 'package:autistapp/tareas/tarea.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;

class EditorTareas extends StatefulWidget {
  final Tarea? _tarea;
  final Ajustes _ajustes;
  final ListaTareas _listaTareas;
  final Function() _onUpdateTareas;

  const EditorTareas(
      {super.key,
      Tarea? tarea,
      required Ajustes ajustes,
      required listaTareas,
      required onUpdateTareas})
      : _tarea = tarea,
        _ajustes = ajustes,
        _listaTareas = listaTareas,
        _onUpdateTareas = onUpdateTareas;
  @override
  EditorTareasState createState() => EditorTareasState();
}

class EditorTareasState extends State<EditorTareas> {
  late TextEditingController _nombreController;

  late String _id;
  late int _notifId;
  late DateTime _fechaInicio;
  late DateTime? _fechaFin;
  //late DateTime? _fechaLimite;
  late int _tipo;
  late int _notifIntervalo;
  late int _prioridad;
  late bool _completada;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget._tarea?.nombre);

    if (widget._tarea != null) {
      _id = widget._tarea?.id;
      _nombreController.text = widget._tarea?.nombre;
      _fechaInicio = widget._tarea?.fechaInicio;
      _fechaFin = widget._tarea?.fechaFin;
      _tipo = widget._tarea?.tipo;
      _prioridad = widget._tarea?.prioridad;
      _notifIntervalo = widget._tarea!.intervalo;
      _completada = widget._tarea?.completada;
      _notifId = widget._tarea?.notifId;
    } else {
      _id = const Uuid().v4();
      _nombreController.text = "Nueva tarea";
      _fechaInicio = DateTime.now();
      _fechaFin = DateTime(DateTime.now().year + 99);
      //_fechaLimite = DateTime(DateTime.now().year + 99);
      _tipo = 0;
      _prioridad = 1;
      _notifIntervalo = 0;
      _completada = false;
      Random rng = Random();
      _notifId = rng.nextInt(pow(2, 31).toInt());
    }

    widget._listaTareas.cargarDatos().then((_) {
      setState(() {});
    });
  }

  void _enviarNotif() async {
    // Eliminamos la notificación anterior
    widget._ajustes.flutNotif.cancel(_notifId);

    // Configuramos los detalles de la notificación.
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'autistapp_chan2', 'Tareas',
        importance: Importance.max, priority: Priority.high, showWhen: false);
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // Determinamos el intervalo de tiempo basado en el int proporcionado.
    Duration duration;
    switch (_notifIntervalo) {
      case 0:
        duration = const Duration(minutes: 30);
        break;
      case 1:
        duration = const Duration(hours: 1);
        break;
      case 2:
        duration = const Duration(hours: 3);
        break;
      case 3:
        duration = const Duration(hours: 6);
        break;
      case 4:
        duration = const Duration(days: 1);
        break;
      case 5:
        duration = const Duration(days: 3);
        break;
      case 6:
        duration = const Duration(days: 7);
        break;
      default:
        throw ArgumentError('Intervalo no válido: $_notifIntervalo');
    }

// Calculamos la fecha y hora en que se debe mostrar la notificación.
    var scheduledDate = tz.TZDateTime.now(tz.local).add(duration);

    // Mostramos la notificación.
    await widget._ajustes.flutNotif.zonedSchedule(
        0,
        '¡Tienes tareas!',
        "${widget._ajustes.prioridadesEmoji[_prioridad]} ${_nombreController.text} (${widget._ajustes.listaAmbitos[_tipo].ambito})",
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget._ajustes.fgColor),
        backgroundColor: widget._ajustes.color,
        title: Text('Editar tarea',
            style: TextStyle(color: widget._ajustes.fgColor)),
        actions: [
          if (widget._tarea != null)
            IconButton(
              color: widget._ajustes.fgColor,
              icon: const Icon(Icons.delete),
              onPressed: () {
                widget._ajustes.flutNotif.cancel(widget._tarea?.id);
                widget._listaTareas.eliminarTarea(widget._tarea?.id);
                Navigator.of(context).pop();
              },
            ),
          if (widget._tarea != null)
            IconButton(
              color: widget._ajustes.fgColor,
              icon: const Icon(Icons.share),
              onPressed: () async {
                await Share.share(
                    "AutistApp - ¡TENGO QUE HACER ESTA TAREA!: \n📝 Nombre: ${_nombreController.text} \n📅 Fecha en que se programó: ${DateFormat('yyyy-MM-dd - EEEE - HH:mm', 'es_ES').format(_fechaInicio)}\n*️⃣ Ámbito: ${widget._ajustes.listaAmbitos[_tipo].emoji} ${widget._ajustes.listaAmbitos[_tipo].ambito}\n🚧 Prioridad: ${widget._ajustes.prioridadesEmoji[_tipo]}\n");
              },
            ),
          IconButton(
            color: widget._ajustes.fgColor,
            icon: const Icon(Icons.save),
            onPressed: () {
              widget._onUpdateTareas;
              widget._listaTareas.agregarTarea(
                _id,
                _notifId,
                _nombreController.text,
                _fechaFin!,
                _tipo,
                _prioridad,
                true,
                _notifIntervalo,
                0,
                _completada,
              );
              _enviarNotif();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  labelText: 'Nombre'),
            ),
            const SizedBox(height: 24),
            const Text(
              "Ámbito vital:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              widget._ajustes.getTextoAmbito(_tipo),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < widget._ajustes.listaAmbitos.length; ++i)
                  Row(children: [
                    if (i > 0) const SizedBox(width: 16),
                    FloatingActionButton(
                      backgroundColor: _tipo == i
                          ? Colors.blueAccent
                          : const Color.fromARGB(255, 212, 222, 219),
                      heroTag: "ambito$i",
                      onPressed: () async {
                        setState(() {
                          _tipo = i;
                        });
                      },
                      child: widget._ajustes.getIconoAmbitoBoton(i, _tipo),
                    ),
                  ]),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Prioridad:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              widget._ajustes.getTextoPrioridad(_prioridad),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0;
                    i < widget._ajustes.prioridadesColor.length;
                    ++i)
                  Row(children: [
                    if (i > 0) const SizedBox(width: 16),
                    FloatingActionButton(
                      backgroundColor: _prioridad == i
                          ? widget._ajustes.prioridadesColor[i]
                          : const Color.fromARGB(255, 212, 222, 219),
                      heroTag: "prio$i",
                      onPressed: () async {
                        setState(() {
                          _prioridad = i;
                        });
                      },
                      child: Icon(
                        widget._ajustes.prioridadesIcono[i],
                        color: _prioridad == i ? Colors.white : Colors.black,
                      ),
                    ),
                  ]),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Recordar dentro de  '),
                  DropdownButton<int>(
                    value: _notifIntervalo,
                    onChanged: (int? newValue) {
                      setState(() {
                        _notifIntervalo = newValue!;
                      });
                    },
                    items: const <DropdownMenuItem<int>>[
                      DropdownMenuItem<int>(
                        value: 0,
                        child: Text('Media hora'),
                      ),
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text('1 hora'),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text('3 horas'),
                      ),
                      DropdownMenuItem<int>(
                        value: 3,
                        child: Text('6 horas'),
                      ),
                      DropdownMenuItem<int>(
                        value: 4,
                        child: Text('1 día'),
                      ),
                      DropdownMenuItem<int>(
                        value: 5,
                        child: Text('3 días'),
                      ),
                      DropdownMenuItem<int>(
                        value: 6,
                        child: Text('1 semana'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /*
            SwitchListTile(
              title: const Text('Repetir periódicamente'),
              value: _repite,
              onChanged: (value) => setState(() => _repite = value),
            ),
            if (_repite)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _intervaloController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          labelText: 'Intervalo'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _unidad,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Días')),
                        DropdownMenuItem(value: 1, child: Text('Semanas')),
                        DropdownMenuItem(value: 2, child: Text('Meses')),
                      ],
                      onChanged: (value) => setState(() => _unidad = value!),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          labelText: 'Unidad'),
                    ),
                  ),
                ],
              ),*/
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
