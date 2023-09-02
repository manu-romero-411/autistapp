import 'dart:convert';
import 'dart:io';

import 'package:autistapp/tareas/tarea.dart';
import 'package:path_provider/path_provider.dart';

class ListaTareas {
  List<Tarea> _tareas = [];

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_tasks.json');
  }

  List<Tarea> toList() {
    return _tareas;
  }

  double getPercentage() {
    return (_tareas.where((tarea) => tarea.completada).length /
            _tareas.length) *
        100;
  }

  int getSize() {
    return _tareas.length;
  }

  int getCompletados() {
    return (_tareas.where((tarea) => tarea.completada).length);
  }

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      _tareas = List<Tarea>.from(data['tasks'].map((x) => Tarea(
          id: x['id'],
          nombre: x['nombre'],
          fechaInicio: DateTime.parse(x['fechaInicio']),
          fechaFin: DateTime.parse(x['fechaFin']),
          tipo: x['tipo'],
          prioridad: x['prioridad'],
          repite: x['repite'] == true ? true : false,
          intervalo: x['intervalo'],
          unidad: x['unidad'],
          completada: x['completada'] == true ? true : false)));
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<File> guardarDatos() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode({
      'tasks': List<dynamic>.from(_tareas.map((x) => {
            'id': x.id,
            'nombre': x.nombre,
            'fechaInicio': x.fechaInicio.toIso8601String(),
            'fechaFin': x.fechaFin?.toIso8601String(),
            'tipo': x.tipo,
            'prioridad': x.prioridad,
            'repite': x.repite,
            'intervalo': x.intervalo,
            'unidad': x.unidad,
            'completada': x.completada,
          })),
    }));
  }

  void agregarTarea(String uuid, String nombre, DateTime fechaFin, int tipo,
      int prioridad, bool repite, int intervalo, int unidad, bool completada) {
    try {
      Tarea tareaExistente = _tareas.firstWhere((tarea) => tarea.id == uuid);
      tareaExistente.nombre = nombre;
      tareaExistente.fechaFin = fechaFin;
      tareaExistente.tipo = tipo;
      tareaExistente.prioridad = prioridad;
      tareaExistente.repite = repite;
      tareaExistente.intervalo = intervalo;
      tareaExistente.unidad = unidad;
      tareaExistente.completada = completada;
    } catch (e) {
      _tareas.add(Tarea(
        id: uuid,
        nombre: nombre,
        fechaInicio: DateTime.now(),
        fechaFin: fechaFin,
        tipo: tipo,
        prioridad: prioridad,
        repite: repite,
        intervalo: intervalo,
        unidad: unidad,
        completada: completada,
      ));
    }
    guardarDatos();
  }

  void eliminarTarea(String id) {
    _tareas.removeWhere((tareaBuscada) => tareaBuscada.id == id);
    guardarDatos();
  }
}
