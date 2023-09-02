import 'dart:convert';
import 'dart:io';
import 'package:autistapp/planes/plan.dart';
import 'package:path_provider/path_provider.dart';

class ListaPlanes {
  List<Plan> _planes = [];
  String id;

  ListaPlanes({required this.id});

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_plans_$id.json');
  }

  List<Plan> toList() {
    return _planes;
  }

  int getSize() {
    return _planes.length;
  }

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      _planes = List<Plan>.from(data['plans'].map((x) => Plan(
          id: x['id'],
          nombre: x['nombre'],
          horaInicio: x['horaInicio'],
          minInicio: x['minInicio'],
          horaFin: x['horaFin'],
          minFin: x['minInicio'],
          tipo: x['tipo'])));
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<File> guardarDatos() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode({
      'tasks': List<dynamic>.from(_planes.map((x) => {
            'id': x.id,
            'nombre': x.nombre,
            'horaInicio': x.horaInicio,
            'minInicio': x.minInicio,
            'horaFin': x.horaFin,
            'minFin': x.minFin,
            'tipo': x.tipo,
          })),
    }));
  }

  void agregarTarea(String uuid, String nombre, int horaInicio, int minInicio,
      int horaFin, int minFin, int tipo) {
    try {
      Plan tareaExistente = _planes.firstWhere((tarea) => tarea.id == uuid);
      tareaExistente.nombre = nombre;
      tareaExistente.horaInicio = horaInicio;
      tareaExistente.minInicio = minInicio;
      tareaExistente.horaFin = horaFin;
      tareaExistente.minFin = minFin;
      tareaExistente.tipo = tipo;
    } catch (e) {
      _planes.add(Plan(
        id: uuid,
        nombre: nombre,
        horaInicio: horaInicio,
        minInicio: minInicio,
        horaFin: horaFin,
        minFin: minFin,
        tipo: tipo,
      ));
    }
    guardarDatos();
  }

  void eliminarTarea(String id) {
    _planes.removeWhere((tareaBuscada) => tareaBuscada.id == id);
    guardarDatos();
  }
}
