import 'dart:convert';
import 'dart:io';

import 'package:autistapp/_aux/rutina_generador.dart';
import 'package:autistapp/_aux/pair_ambito_icono.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

class Ajustes {
  bool _welcome = true;
  bool _isDarkTheme = true;
  Color? _color;
  Color? _fgColor = Colors.white;
  Color? _bgColor = Colors.black;
  String _name = "";
  int _minHoraGantt = 8;
  int _maxHoraGantt = 23;
  int _frecNotif = 1;
  FlutterLocalNotificationsPlugin flutNotif = FlutterLocalNotificationsPlugin();
  Ajustes();

  get frecNotif => _frecNotif;
  set frecNotif(value) => _frecNotif = value;
  get color => _color;
  get fgColor => _fgColor;
  get bgColor => _bgColor;
  get isDarkTheme => _isDarkTheme;

  set setDarkTheme(final value) {
    _isDarkTheme = value;
    guardarDatos();
  }

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

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      _isDarkTheme = data['theme'];
      _color = Color(data['color']);
      _fgColor = Color(data['fgColor']);
      _bgColor = Color(data['bgColor']);
      _name = data['name'];
      _frecNotif = data['frecNotif'];
      _minHoraGantt = data['minHoraGantt'];
      _maxHoraGantt = data['maxHoraGantt'];
      _welcome = data['welcome'] == true ? true : false;
    } catch (e) {
      defaultData();
    }
  }

  Future<void> guardarDatos() async {
    try {
      final file = await _localFile;

      final data = {
        'theme': isDarkTheme,
        'color': color.value,
        'bgColor': bgColor.value,
        'fgColor': fgColor.value,
        'name': name,
        'frecNotif': frecNotif,
        'minHoraGantt': minHoraGantt,
        'maxHoraGantt': maxHoraGantt,
        'welcome': welcome,
      };
      final contents = jsonEncode(data);
      await file.writeAsString(contents);
    } catch (e) {
      defaultData();
    }
  }

  void defaultData() {
    _isDarkTheme = true;
    _color = Colors.blueGrey;
    _fgColor = Colors.white;
    _bgColor = Colors.black;
    _name = "";
    _minHoraGantt = 8;
    _maxHoraGantt = 23;
    _welcome = true;
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_settings.json');
  }

  final List<Color> colors = [
    Colors.brown,
    Colors.red,
    const Color.fromARGB(255, 148, 110, 145),
    Colors.orange,
    Colors.yellow,
    Colors.white,
    Colors.lime,
    Colors.lightGreen,
    Colors.green,
    const Color.fromARGB(255, 28, 163, 157),
    Colors.blue,
    const Color.fromRGBO(7, 63, 160, 1),
    Colors.blueGrey,
    Colors.purple,
    Colors.deepPurple,
    const Color.fromRGBO(217, 4, 160, 1),
  ];

/* ICONOS Y LABELS DE ÁMBITOS */
  final List<PairAmbitoIcono> listaAmbitos = [
    PairAmbitoIcono(
        ambito: "Académico/Laboral",
        icono: Icons.work_outline_rounded,
        color: Colors.red,
        emoji: "💼"),
    PairAmbitoIcono(
        ambito: "Social",
        icono: Icons.people_rounded,
        color: Colors.lightGreen,
        emoji: "👥"),
    PairAmbitoIcono(
        ambito: "Personal",
        icono: Icons.person,
        color: Colors.lightBlue,
        emoji: "😇")
  ];

  String getTextoAmbito(int ambito) {
    return (ambito >= 0 && ambito < listaAmbitos.length)
        ? listaAmbitos[ambito].ambito
        : "Otro";
  }

  String getTextoPrioridad(int prio) {
    return (prio == 0)
        ? "Baja"
        : (prio == 1)
            ? "Media"
            : (prio == 2)
                ? "Alta"
                : "Otra";
  }

  Icon getIconoAmbitoBoton(int ambito, int selected) {
    IconData iconData = listaAmbitos[ambito].icono;
    Color color = ambito == selected ? Colors.white : Colors.black;
    return Icon(iconData, color: color);
  }

  Icon getIconoAmbito(int ambito) {
    return Icon(listaAmbitos[ambito].icono);
  }

  Icon? getRutinaIcon(int index) {
    if (index > rutinas.length - 1) {
      return null;
    }

    return Icon(rutinas[index].icono);
  }

  List<RutinaGenerador> rutinas = [
    RutinaGenerador(nombre: "Ducharse", icono: Icons.shower, emoji: "🚿"),
    RutinaGenerador(
        nombre: "Desayuno", icono: Icons.breakfast_dining, emoji: "🥞"),
    RutinaGenerador(nombre: "Tomar una fruta", icono: Icons.apple, emoji: "🍎"),
    RutinaGenerador(
        nombre: "Vaso de agua 1", icono: Icons.local_drink, emoji: "💧"),
    RutinaGenerador(nombre: "Hacer tu cama", icono: Icons.bed, emoji: "🛏"),
    RutinaGenerador(
        nombre: "Limpiar la casa (si no tienes que ir a trabajar)",
        icono: Icons.cleaning_services,
        emoji: "🧹"),
    RutinaGenerador(
        nombre: "Gestionar papeleos",
        icono: Icons.document_scanner,
        emoji: "🧹"),
    RutinaGenerador(
        nombre: "Vaso de agua 2", icono: Icons.local_drink, emoji: "💧"),
    RutinaGenerador(
        nombre: "Hacer la comida", icono: Icons.microwave, emoji: "🍳"),
    RutinaGenerador(nombre: "Almorzar", icono: Icons.restaurant, emoji: "🍚"),
    RutinaGenerador(nombre: "Tomar una fruta", icono: Icons.apple, emoji: "🍐"),
    RutinaGenerador(
        nombre: "Vaso de agua 3", icono: Icons.local_drink, emoji: "💧"),
    RutinaGenerador(
        nombre: "Hacer deporte", icono: Icons.run_circle, emoji: "🏃‍♂️"),
    RutinaGenerador(
        nombre: "Vaso de agua 4", icono: Icons.local_drink, emoji: "💧"),
    RutinaGenerador(
        nombre: "Merienda una fruta", icono: Icons.apple, emoji: "🍊"),
    RutinaGenerador(
        nombre: "Un rato de relax", icono: Icons.gamepad, emoji: "🎮"),
    RutinaGenerador(
        nombre: "Vaso de agua 5", icono: Icons.local_drink, emoji: "💧"),
    RutinaGenerador(nombre: "Cenar", icono: Icons.kitchen, emoji: "🍞"),
    RutinaGenerador(
        nombre: "Vaso de agua 6", icono: Icons.local_drink, emoji: "💧"),
    RutinaGenerador(
        nombre: "Lavarse los dientes",
        icono: Icons.emoji_emotions,
        emoji: "🦷"),
  ];

  List<Color> prioridadesColor = [
    Colors.green,
    Colors.amber,
    Colors.red,
  ];

  List<String> prioridadesEmoji = [
    "🟢",
    "🟡",
    "🔴",
  ];

  List<IconData> prioridadesIcono = [
    Icons.low_priority,
    Icons.trending_flat,
    Icons.priority_high
  ];

  List<String> emoEmojis = ["😄", "😕", "😢", "😩"];
  List<Color> emoColores = [
    Colors.green,
    Colors.amber,
    Colors.red,
    Colors.purpleAccent
  ];

  void initNotif() async {
    // Inicializamos las notificaciones
    var andNotiSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: andNotiSettings, iOS: iOSInitializationSettings);
    flutNotif.initialize(initializationSettings);
  }
}
