import 'dart:convert';
import 'dart:io';
import 'package:autistapp/planes/lista_planes.dart';
import 'package:path_provider/path_provider.dart';

class MetaListaPlanes {
  MetaListaPlanes();

  List<ListaPlanes> _planes = [];

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_plans_list.json');
  }

  Future<File> getListaFile(String uuid) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_plans_${uuid}.json');
  }

  List<ListaPlanes> toList() {
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
      _planes = List<ListaPlanes>.from(data['planList'].map((x) => ListaPlanes(
            id: x['id'],
            name: x['nombre'],
          )));
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<File> guardarDatos() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode({
      'planList': List<dynamic>.from(_planes.map((x) => {
            'id': x.id,
            'nombre': x.name,
          })),
    }));
  }

  void agregarTarea(String uuid, String nombre) {
    try {
      ListaPlanes planExistente = _planes.firstWhere((plan) => plan.id == uuid);
      planExistente.name = nombre;
    } catch (e) {
      _planes.add(ListaPlanes(
        id: uuid,
        name: nombre,
      ));
    }
    guardarDatos();
  }

  Future<void> eliminarTarea(String id) async {
    _planes.removeWhere((planBuscada) => planBuscada.id == id);
    final file = await getListaFile(id);

    file.delete().catchError((e) {
      return e;
    });
    guardarDatos();
  }
}
