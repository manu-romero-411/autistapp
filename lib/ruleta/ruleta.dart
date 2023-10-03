import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Ruleta {
  Ruleta({required id, required name, required fecha})
      : _id = id,
        _name = name,
        _fecha = fecha;

  String _id;
  String _name;
  List<String> items = [];
  List<String> ids = [];
  List<int> repet = [];
  final DateTime _fecha;

  get fecha => _fecha;

  get name => _name;
  set name(value) => _name = value;
  get id => _id;
  set id(final value) => _id = value;

  Map<String, dynamic> toMap() {
    return {};
  }

  Future<void> guardarDatos() async {
    final file = await _localFile;
    await file.writeAsString(json.encode({
      'id': _id,
      'items': items,
      'ids': ids,
      'repet': repet,
    }));
  }

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      final jsonString = await file.readAsString();
      final map = json.decode(jsonString);
      id = map['id'];
      items = List<String>.from(map['items']);
      ids = List<String>.from(map['ids']);
      repet = List<int>.from(map['repet']);
    } catch (e) {
      agregarItem("newItem");
    }
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_ruleta_$_id.json');
  }

  void agregarItem(String newItem) {
    items.add(newItem);
    ids.add(const Uuid().v4());
    repet.add(0);
    guardarDatos();
  }

  void borrarItem(String id) {
    items.removeAt(ids.indexOf(id));
    repet.removeAt(ids.indexOf(id));
    ids.removeAt(ids.indexOf(id));
    guardarDatos();
  }

  void actualizarItem(String id, String newName) {
    if (newName != items[ids.indexOf(id)]) {
      repet[ids.indexOf(id)] = 0;
    }

    items[ids.indexOf(id)] = newName;
    guardarDatos();
  }

  void nuevaRepeticionItem(int index) {
    repet[index]++;
    guardarDatos();
  }
}
