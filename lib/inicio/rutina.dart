import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Rutina {
  String _id;
  String _nombre;
  TimeOfDay? _hora;
  bool _completada;

  get id => _id;
  set id(value) => _id = value;
  get nombre => _nombre;
  set nombre(value) => _nombre = value;
  get hora => _hora;
  set hora(value) => _hora = value;
  get completada => _completada;
  set completada(value) => _completada = value;

  Rutina({
    required String id,
    required String nombre,
    //TimeOfDay hora,
    required bool completada,
  })  : _completada = completada,
        // _hora = hora,
        _nombre = nombre,
        _id = id;

  /* DateTime getHoraAsDateTime() {
    return DateTime(
        DateTime.now().year, // cualquier año
        DateTime.now().month, // cualquier mes
        DateTime.now().day, // cualquier día
        _hora.hour,
        _hora.minute);
  }*/

  void setHoraFromDateTime(DateTime fecha) {
    _hora = TimeOfDay(hour: fecha.hour, minute: fecha.minute);
  }
}

class ListaRutinas {
  List<Rutina> _rutinas = [];

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File(
        '${directory.path}/autistapp_rutinas_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json');
  }

  Future<File> getDatedLocalFile(DateTime fecha) async {
    final directory = await getApplicationDocumentsDirectory();
    return File(
        '${directory.path}/autistapp_rutinas_${DateFormat('yyyy-MM-dd').format(fecha)}.json');
  }

  List<Rutina> toList() {
    return _rutinas;
  }

  Rutina get(int index) {
    return _rutinas[index];
  }

  int getSize() {
    return _rutinas.length;
  }

  double getPercentage() {
    return (_rutinas.where((tarea) => tarea._completada).length /
            _rutinas.length) *
        100;
  }

  int getCompletados() {
    int total = 0;
    for (int i = 0; i < _rutinas.length; ++i) {
      if (_rutinas[i].completada) total++;
    }
    return total;
  }

  List<int> getRutinasCompletadas() {
    List<int> count = [];
    for (int i = 0; i < _rutinas.length; ++i) {
      if (_rutinas[i]._completada) count.add(i);
    }
    return count;
  }

  Future<void> cargarDatos(DateTime? fecha) async {
    try {
      final file =
          fecha == null ? await _localFile : await getDatedLocalFile(fecha);
      final contents = await file.readAsString();
      final data = jsonDecode(contents);

      _rutinas = List<Rutina>.from(data['tasks'].map((x) => Rutina(
          id: x['id'],
          nombre: x['nombre'],
          /* hora: TimeOfDay(
              hour: DateTime.parse(x['hora']).hour,
              minute: DateTime.parse(x['hora']).minute),*/
          completada: x['completada'] == true ? true : false)));
    } catch (e) {
      throw Exception('Error al cargar datos: $e');
    }
  }

  Future<File> guardarDatos() async {
    final file = await _localFile;

    return file.writeAsString(jsonEncode({
      'tasks': List<dynamic>.from(_rutinas.map((x) => {
            'id': x.id,
            'nombre': x.nombre,
            //'hora': x.getHoraAsDateTime().toIso8601String(),
            'completada': x.completada,
          })),
    }));
  }

  void agregarRutina(String uuid, String nombre, bool completada) {
    try {
      Rutina rutinaExistente = _rutinas.firstWhere((tarea) => tarea.id == uuid);
      rutinaExistente.nombre = nombre;
      //rutinaExistente.hora = hora;
      rutinaExistente.completada = completada;
    } catch (e) {
      _rutinas.add(Rutina(
        id: uuid,
        nombre: nombre,
        //hora: hora,
        completada: completada,
      ));
    }
    guardarDatos();
  }

  void eliminarRutina(String id) {
    _rutinas.removeWhere((rutinaBuscada) => rutinaBuscada._id == id);
    guardarDatos();
  }

  void eliminarRutinaIndex(int index) {
    _rutinas.removeAt(index);
    guardarDatos();
  }

  void borrarTodas() {
    _rutinas.clear();
  }
}
