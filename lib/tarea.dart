/*import 'package:autistapp/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'notify.dart';

class Tarea {
  //String id;
  //String nombre = "";
  //DateTime fechaInicio = DateTime.now();
  //DateTime? fechaFin = DateTime(DateTime.now().year + 99);
  //DateTime? fechaLimite = DateTime(DateTime.now().year + 99);
  //int tipo = 0;
  //int prioridad = 1;
  //bool repite = false;
  //int intervalo = 1;
  //bool completada = false;
  String id;
  String nombre;
  DateTime fechaInicio;
  DateTime? fechaFin;
  DateTime? fechaLimite;
  int tipo;
  int prioridad;
  bool repite;
  int intervalo;
  int unidad;
  bool completada;

  Tarea({
    required this.id,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.fechaLimite,
    required this.tipo,
    required this.prioridad,
    required this.repite,
    required this.intervalo,
    required this.unidad,
    required this.completada,
  });
}

class ListaTareas {
  List<Tarea> tareas = [];

  static final ListaTareas _singleton = ListaTareas._internal();

  factory ListaTareas() {
    return _singleton;
  }

  ListaTareas._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }

  Future<File> writeData() async {
    final file = await _localFile;
    Map<String, dynamic> data = {'tasks': []};
    for (var tarea in tareas) {
      data['tasks'].add({
        'id': tarea.id,
        'nombre': tarea.nombre,
        'fechaInicio': tarea.fechaInicio.toIso8601String(),
        'fechaFin': tarea.fechaFin?.toIso8601String(),
        'fechaLimite': tarea.fechaLimite?.toIso8601String(),
        'tipo': tarea.tipo,
        'prioridad': tarea.prioridad,
        'repite': tarea.repite,
        'intervalo': tarea.intervalo,
        'unidad': tarea.intervalo,
        'completada': tarea.completada
      });
    }
    return file.writeAsString(json.encode(data));
  }

  Future<void> readData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        Map<String, dynamic> data = json.decode(contents);
        tareas = [];
        for (var task in data['tasks']) {
          tareas.add(Tarea(
              id: task['id'],
              nombre: task['nombre'],
              fechaInicio: DateTime.parse(task['fechaInicio']),
              fechaFin: task['fechaFin'] != null
                  ? DateTime.parse(task['fechaFin'])
                  : null,
              fechaLimite: task['fechaLimite'] != null
                  ? DateTime.parse(task['fechaLimite'])
                  : null,
              tipo: task['tipo'],
              prioridad: task['prioridad'],
              repite: task['repite'],
              intervalo: task['intervalo'],
              unidad: task['unidad'],
              completada: task['completada']));
        }
      } else {
        writeData();
      }
    } catch (e) {
      print(e);
    }
  }

  void crearTarea(Tarea tarea) {
    tareas.add(tarea);
    writeData();
    programarNotificaciones(tareasList);
  }

  void actualizarTarea(Tarea tarea) {
    int index = tareas.indexWhere((element) => element.id == tarea.id);
    if (index != -1) {
      tareas[index] = tarea;
      writeData();
      programarNotificaciones(tareasList);
    }
  }

  void borrarTarea(Tarea tarea) {
    tareas.removeWhere((element) => element.id == tarea.id);
    writeData();
    programarNotificaciones(tareasList);
  }
}

class ListaTarjeta extends StatefulWidget {
  @override
  _ListaTarjetaState createState() => _ListaTarjetaState();
}

class _ListaTarjetaState extends State<ListaTarjeta> {
  final listaTareas = ListaTareas();

  @override
  void initState() {
    super.initState();
    listaTareas.readData().then((_) {
      setState(() {});
    });
  }

  void borrarTarea(Tarea tarea) {
    listaTareas.borrarTarea(tarea);
    setState(() {});
  }

  String getEmoji(int prioridad) {
    switch (prioridad) {
      case 0:
        return '🟢';
      case 1:
        return '🟡';
      case 2:
        return '🔴';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
      ),
      body: Card(
        child: ListView.builder(
          itemCount: listaTareas.tareas.length,
          itemBuilder: (context, index) {
            final tarea = listaTareas.tareas[index];
            return InkWell(
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditarTarea(tarea: tarea)),
                ).then((_) => setState(() {}));
              },
              child: CheckboxListTile(
                title: Row(
                  children: [
                    Text(getEmoji(tarea.prioridad)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(tarea.nombre)),
                  ],
                ),
                value: tarea.completada,
                onChanged: (bool? value) {
                  setState(() {
                    tarea.completada = value!;
                    listaTareas.actualizarTarea(tarea);
                  });
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.edit),
            label: 'Nueva tarea',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditarTarea()),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
    );
  }
}

class EditarTarea extends StatefulWidget {
  final Tarea? tarea;

  EditarTarea({this.tarea});

  @override
  _EditarTareaState createState() => _EditarTareaState();
}

class _EditarTareaState extends State<EditarTarea> {
  final listaTareas = ListaTareas();
  late TextEditingController _nombreController;
  late int _tipo;
  late int _prioridad;
  late bool _establecerFechaLimite;
  late DateTime _fechaLimite;
  late bool _repite;
  late TextEditingController _intervaloController;
  late int _unidad;

  @override
  void initState() {
    super.initState();
    final tarea = widget.tarea;
    _nombreController = TextEditingController(text: tarea?.nombre);
    _tipo = tarea?.tipo ?? 0;
    _prioridad = tarea?.prioridad ?? 1;
    _establecerFechaLimite = tarea?.fechaLimite != null &&
        tarea?.fechaLimite != DateTime(DateTime.now().year + 99);
    _fechaLimite = tarea?.fechaLimite ?? DateTime.now();
    _repite = tarea?.repite ?? false;
    _intervaloController = TextEditingController(
        text: tarea != null ? tarea.intervalo.toString() : '');
    _unidad = tarea?.unidad ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarea'),
        actions: [
          if (widget.tarea != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                listaTareas.borrarTarea(widget.tarea!);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          DropdownButtonFormField<int>(
            value: _tipo,
            items: const [
              DropdownMenuItem(value: 0, child: Text('Académico/laboral')),
              DropdownMenuItem(value: 1, child: Text('Social')),
              DropdownMenuItem(value: 2, child: Text('Personal')),
            ],
            onChanged: (value) => setState(() => _tipo = value!),
            decoration: const InputDecoration(labelText: 'Tipo'),
          ),
          const SizedBox(height: 16),
          const Text('Prioridad'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _prioridad = 0),
                child: const Text('Baja'),
                style: ElevatedButton.styleFrom(
                  primary: _prioridad == 0 ? Colors.green : Colors.grey,
                ),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _prioridad = 1),
                child: const Text('Media'),
                style: ElevatedButton.styleFrom(
                  primary: _prioridad == 1 ? Colors.orange : Colors.grey,
                ),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _prioridad = 2),
                child: const Text('Alta'),
                style: ElevatedButton.styleFrom(
                  primary: _prioridad == 2 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Establecer fecha límite'),
            value: _establecerFechaLimite,
            onChanged: (value) =>
                setState(() => _establecerFechaLimite = value),
          ),
          if (_establecerFechaLimite)
            ListTile(
              title: Text(
                  'Fecha límite: ${DateFormat('yyyy-MM-dd HH:mm').format(_fechaLimite)}'),
              onTap: () async {
                final fechaSeleccionada = await showDatePicker(
                  context: context,
                  initialDate: _fechaLimite,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365 * 100)),
                );
                if (fechaSeleccionada != null) {
                  final horaSeleccionada = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_fechaLimite),
                  );
                  if (horaSeleccionada != null) {
                    setState(() {
                      _fechaLimite = DateTime(
                        fechaSeleccionada.year,
                        fechaSeleccionada.month,
                        fechaSeleccionada.day,
                        horaSeleccionada.hour,
                        horaSeleccionada.minute,
                      );
                    });
                  }
                }
              },
            ),
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
                    decoration: const InputDecoration(labelText: 'Intervalo'),
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
                    decoration: const InputDecoration(labelText: 'Unidad'),
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_nombreController.text.isEmpty ||
              (_repite &&
                  (int.tryParse(_intervaloController.text) == null ||
                      int.parse(_intervaloController.text) < 1))) {
            return;
          }
          if (widget.tarea != null) {
            widget.tarea!.nombre = _nombreController.text;
            widget.tarea!.tipo = _tipo;
            widget.tarea!.prioridad = _prioridad;
            widget.tarea!.fechaLimite = _establecerFechaLimite
                ? _fechaLimite
                : DateTime(DateTime.now().year + 99);
            widget.tarea!.repite = _repite;
            if (_repite) {
              widget.tarea!.intervalo = int.parse(_intervaloController.text);
              widget.tarea!.unidad = _unidad;
            }
            listaTareas.actualizarTarea(widget.tarea!);
          } else {
            listaTareas.crearTarea(Tarea(
              id: const Uuid().v4(),
              nombre: _nombreController.text,
              fechaInicio: DateTime.now(),
              fechaFin: DateTime(DateTime.now().year + 99),
              fechaLimite: _establecerFechaLimite
                  ? _fechaLimite
                  : DateTime(DateTime.now().year + 99),
              tipo: _tipo,
              prioridad: _prioridad,
              repite: _repite,
              intervalo: _repite ? int.parse(_intervaloController.text) : 1,
              unidad: _unidad,
              completada: false,
            ));
          }
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
*/