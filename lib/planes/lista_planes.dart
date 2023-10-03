import 'dart:convert';
import 'dart:io';
import 'package:autistapp/planes/plan.dart';
import 'package:path_provider/path_provider.dart';

class ListaPlanes {
  String id;
  String name;

  ListaPlanes({required this.id, required this.name});

  List<Plan> _planes = [];

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

  void ordenarLista() {
    _planes.sort((a, b) => int.parse(
            "${a.horaInicio}${a.minInicio}${a.horaFin}${a.minFin}")
        .compareTo(
            int.parse("${b.horaInicio}${b.minInicio}${b.horaFin}${b.minFin}")));
  }

  Future<void> cargarDatos() async {
    final file = await _localFile;
    if (await file.exists()) {
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      _planes = List<Plan>.from(data['plans'].map((x) => Plan(
          id: x['id'],
          nombre: x['nombre'],
          horaInicio: x['horaInicio'],
          minInicio: x['minInicio'],
          horaFin: x['horaFin'],
          minFin: x['minFin'],
          tipo: x['tipo'])));
      //ordenarLista();
    }
  }

  Future<File> guardarDatos() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode({
      'plans': List<dynamic>.from(_planes.map((x) => {
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

  void agregarTarea(String uuid, String nombre, int tipo, int horaInicio,
      int minInicio, int horaFin, int minFin) {
    try {
      Plan planExistente = _planes.firstWhere((plan) => plan.id == uuid);
      planExistente.nombre = nombre;
      planExistente.tipo = tipo;
      planExistente.horaInicio = horaInicio;
      planExistente.minInicio = minInicio;
      planExistente.horaFin = horaFin;
      planExistente.minFin = minFin;
    } catch (e) {
      _planes.add(Plan(
        id: uuid,
        nombre: nombre,
        tipo: tipo,
        horaInicio: horaInicio,
        minInicio: minInicio,
        horaFin: horaFin,
        minFin: minFin,
      ));
    }
    //ordenarLista();
    guardarDatos();
  }

  void eliminarTarea(String id) {
    _planes.removeWhere((planBuscada) => planBuscada.id == id);
    guardarDatos();
  }
}
