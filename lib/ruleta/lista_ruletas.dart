import 'dart:convert';
import 'dart:io';
import 'package:autistapp/ruleta/ruleta.dart';
import 'package:path_provider/path_provider.dart';

class ListaRuletas {
  ListaRuletas();

  List<Ruleta> _ruletas = [];

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_ruletas_list.json');
  }

  Future<File> getListaFile(String uuid) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_ruleta_$uuid.json');
  }

  List<Ruleta> toList() {
    return _ruletas;
  }

  int getSize() {
    return _ruletas.length;
  }

  Future<void> cargarDatos() async {
    final file = await _localFile;
    if (await file.exists()) {
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      _ruletas = List<Ruleta>.from(data['ruletaList'].map((x) => Ruleta(
            id: x['id'],
            name: x['nombre'],
            fecha: DateTime.parse(x['fecha']),
          )));
      for (int i = 0; i < _ruletas.length; ++i) {
        _ruletas[i].cargarDatos();
      }
    }
  }

  Future<File> guardarDatos() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode({
      'ruletaList': List<dynamic>.from(_ruletas.map((x) => {
            'id': x.id,
            'nombre': x.name,
            'fecha': x.fecha.toIso8601String(),
          })),
    }));
  }

  void agregarTarea(String uuid, String nombre, DateTime fecha) {
    try {
      Ruleta ruletaExist = _ruletas.firstWhere((ruleta) => ruleta.id == uuid);
      ruletaExist.name = nombre;
    } catch (e) {
      _ruletas.add(Ruleta(id: uuid, name: nombre, fecha: fecha));
    }
    guardarDatos();
  }

  Future<void> eliminarTarea(String id) async {
    _ruletas.removeWhere((ruletaBuscada) => ruletaBuscada.id == id);
    final file = await getListaFile(id);

    guardarDatos();

    if (file.existsSync()) {
      file.delete().catchError((e) {
        return e;
      });
    }
  }
}
