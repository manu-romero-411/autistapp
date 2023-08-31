import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Tarea {
  String _id;
  String _nombre;
  DateTime _fechaInicio;
  DateTime? _fechaFin = DateTime(DateTime.now().year + 99);
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

  Tarea({
    required String id,
    required String nombre,
    required DateTime fechaInicio,
    required DateTime? fechaFin,
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
        _fechaFin = fechaFin,
        _fechaInicio = fechaInicio,
        _nombre = nombre,
        _id = id {
    if (_nombre.length > 100) {
      _nombre = _nombre.substring(0, 100);
    }
  }

  toFirebase() {
    return {
      "tarea": nombre,
      "fechaInicio": fechaInicio.toString(),
      "repite": repite,
    };
  }
}

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
