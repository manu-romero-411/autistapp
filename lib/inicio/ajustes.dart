import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class Ajustes {
  bool _welcome = true;
  String _theme = "";
  Color? _color;
  Color? _fgColor = Colors.white;
  Color? _bgColor = Colors.black;
  String _name = "";

  final List<Color> colors = [
    Colors.brown,
    Colors.red,
    Color.fromARGB(255, 148, 110, 145),
    Colors.orange,
    Colors.yellow,
    Colors.white,
    Colors.lime,
    Colors.lightGreen,
    Colors.green,
    Color.fromARGB(255, 28, 163, 157),
    Colors.blue,
    const Color.fromRGBO(7, 63, 160, 1),
    Colors.blueGrey,
    Colors.purple,
    Colors.deepPurple,
    const Color.fromRGBO(217, 4, 160, 1),
    // Agrega aquí los demás colores
  ];

  int _minHoraGantt = 8;
  int _maxHoraGantt = 23;

  get fgColor => _fgColor;
  get bgColor => _bgColor;

  get theme => _theme;

  set theme(final value) {
    _theme = value;

    guardarDatos();
  }

  get color => _color;

  set color(value) {
    _color = value;
    _color == Colors.yellow ||
            _color == Colors.white ||
            _color == Colors.lime ||
            _color == Colors.lightGreen
        ? _fgColor = Colors.black
        : _fgColor = Colors.white;

    _color == Colors.yellow ||
            _color == Colors.white ||
            _color == Colors.lime ||
            _color == Colors.lightGreen
        ? _bgColor = Colors.white
        : _bgColor = Colors.black;
    guardarDatos();
  }

  get name => _name;

  set name(value) {
    _name = value;
    guardarDatos();
  }

  get maxHoraGantt => _maxHoraGantt;

  set maxHoraGantt(maxHoraGantt) {
    _maxHoraGantt = maxHoraGantt;
    guardarDatos();
  }

  get minHoraGantt => _minHoraGantt;

  set minHoraGantt(minHoraGantt) {
    _minHoraGantt = minHoraGantt;
    guardarDatos();
  }

  get welcome => _welcome;

  set welcome(value) {
    _welcome = value;
    guardarDatos();
  }

  Ajustes();

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      _theme = data['theme'];
      _color = Color(data['color']);
      _fgColor = Color(data['fgColor']);
      _bgColor = Color(data['bgColor']);
      _name = data['name'];
      _minHoraGantt = data['minHoraGantt'];
      _maxHoraGantt = data['maxHoraGantt'];
      _welcome = data['welcome'] == true ? true : false;
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<void> guardarDatos() async {
    try {
      final file = await _localFile;
      final data = {
        'theme': theme,
        'color': color.value,
        'bgColor': bgColor.value,
        'fgColor': fgColor.value,
        'name': name,
        'minHoraGantt': minHoraGantt,
        'maxHoraGantt': maxHoraGantt,
        'welcome': welcome,
      };
      final contents = jsonEncode(data);
      await file.writeAsString(contents);
    } catch (e) {
      print('Error al guardar datos: $e');
      _theme = "light";
      _color = Colors.blueGrey;
      _fgColor = Colors.white;
      _bgColor = Colors.black;
      _name = "";
      _minHoraGantt = 8;
      _maxHoraGantt = 23;
      _welcome = true;
      guardarDatos();
    }
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_settings.json');
  }
}
