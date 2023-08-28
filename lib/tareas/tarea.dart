import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:diacritic/diacritic.dart';

class TareaN {
  String _id;
  String _nombre;
  DateTime _fechaInicio;
  DateTime? _fechaFin = DateTime(DateTime.now().year + 99);
  DateTime? _fechaLimite = DateTime(DateTime.now().year + 99);
  int _tipo;
  int _prioridad;
  bool _repite;
  int _intervalo;
  int _unidad;
  bool _completada;

  get id => _id;

  set id(final value) => _id = value;

  get nombre => _nombre;

  set nombre(value) => _nombre = value;

  get fechaInicio => _fechaInicio;

  set fechaInicio(value) => _fechaInicio = value;

  get fechaFin => _fechaFin;

  set fechaFin(value) => _fechaFin = value;

  get fechaLimite => _fechaLimite;

  set fechaLimite(value) => _fechaLimite = value;

  get tipo => _tipo;

  set tipo(value) => _tipo = value;

  get prioridad => _prioridad;

  set prioridad(value) => _prioridad = value;

  get repite => _repite;

  set repite(value) => _repite = value;

  get intervalo => _intervalo;

  set intervalo(value) => _intervalo = value;

  get unidad => _unidad;

  set unidad(value) => _unidad = value;

  get completada => _completada;

  set completada(value) => _completada = value;

  TareaN({
    required String id,
    required String nombre,
    required DateTime fechaInicio,
    required DateTime? fechaFin,
    required DateTime? fechaLimite,
    required int tipo,
    required int prioridad,
    required bool repite,
    required int intervalo,
    required int unidad,
    required bool completada,
  })  : _completada = completada,
        _unidad = unidad,
        _intervalo = intervalo,
        _repite = repite,
        _prioridad = prioridad,
        _tipo = tipo,
        _fechaLimite = fechaLimite,
        _fechaFin = fechaFin,
        _fechaInicio = fechaInicio,
        _nombre = nombre,
        _id = id {
    if (_nombre.length > 100) {
      _nombre = _nombre.substring(0, 100);
    }
  }
}

class ListaTareas {
  List<TareaN> _tareas = [];

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_tasks.json');
  }

  List<TareaN> toList() {
    return _tareas;
  }

  double getPercentage() {
    return (_tareas.where((tarea) => tarea.completada).length /
            _tareas.length) *
        100;
  }

  int getCompletados() {
    return (_tareas.where((tarea) => tarea.completada).length);
  }

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      _tareas = List<TareaN>.from(data['tasks'].map((x) => TareaN(
          id: x['id'],
          nombre: x['nombre'],
          fechaInicio: DateTime.parse(x['fechaInicio']),
          fechaFin: DateTime.parse(x['fechaFin']),
          fechaLimite: DateTime.parse(x['fechaLimite']),
          tipo: x['tipo'],
          prioridad: x['prioridad'],
          repite: x['repite'] == true ? true : false,
          intervalo: x['intervalo'],
          unidad: x['unidad'],
          completada: x['completada'] == true ? true : false)));
      print("");
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
            'fechaLimite': x.fechaLimite?.toIso8601String(),
            'tipo': x.tipo,
            'prioridad': x.prioridad,
            'repite': x.repite,
            'intervalo': x.intervalo,
            'unidad': x.unidad,
            'completada': x.completada,
          })),
    }));
  }

  void agregarTarea(
      String uuid,
      String nombre,
      DateTime fechaFin,
      DateTime fechaLimite,
      int tipo,
      int prioridad,
      bool repite,
      int intervalo,
      int unidad,
      bool completada) {
    try {
      TareaN tareaExistente = _tareas.firstWhere((tarea) => tarea.id == uuid);
      tareaExistente.nombre = nombre;
      tareaExistente.fechaFin = fechaFin;
      tareaExistente.fechaLimite = fechaLimite;
      tareaExistente.tipo = tipo;
      tareaExistente.prioridad = prioridad;
      tareaExistente.repite = repite;
      tareaExistente.intervalo = intervalo;
      tareaExistente.unidad = unidad;
      tareaExistente.completada = completada;
    } catch (e) {
      _tareas.add(TareaN(
        id: uuid,
        nombre: nombre,
        fechaInicio: DateTime.now(),
        fechaFin: fechaFin,
        fechaLimite: fechaLimite,
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
