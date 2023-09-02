import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Dia {
  String _id;
  int _mood;
  String _texto;

  get id => _id;

  set id(value) => _id = value;

  get mood => _mood;

  set mood(value) => _mood = value;

  get texto => _texto;

  set texto(value) => _texto = value;

  Dia({
    required String id,
    required String nombre,
    required int mood,
    required String texto,
  })  : _texto = texto,
        _mood = mood,
        _id = id {
    if (_texto.length > 100) {
      _texto = _texto.substring(0, 100);
    }
  }

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      _id = data['id'];
      _mood = data['mood'];
      _texto = data['texto'];
    } catch (e) {
      _id = DateFormat("yyyyMMdd").format(DateTime.now());
      _mood = -1;
      _texto = "";
      guardarDatos();
    }
  }

  Future<void> guardarDatos() async {
    try {
      final file = await _localFile;
      final data = {
        'id': _id,
        'mood': _mood,
        'texto': _texto,
      };
      final contents = jsonEncode(data);
      await file.writeAsString(contents);
    } catch (e) {
      print('Error al guardar datos: $e');
    }
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_day_$_id.json');
  }
}
