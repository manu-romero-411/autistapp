import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/inicio/vista_bienvenida.dart';
import 'package:flutter/material.dart';
import 'package:autistapp/inicio/vista_inicio.dart';
import 'package:dynamic_color/dynamic_color.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  initializeDateFormatting('es_ES', null);
  runApp(const AutistAppMain());
}

class AutistAppMain extends StatefulWidget {
  const AutistAppMain({super.key});
  @override
  AutistAppMainState createState() => AutistAppMainState();
}

class AutistAppMainState extends State<AutistAppMain> {
  Ajustes ajustes = Ajustes();
  bool isWelcome = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ajustes.cargarDatos();
    setState(() {
      _isLoading = false;
    });
  }

  get color => ajustes.color;

  ThemeData? getThemeData() {
    ajustes.cargarDatos();
    return ajustes.isDarkTheme
        ? ThemeData.dark()
        : !ajustes.isDarkTheme
            ? ThemeData.light()
            : null;
  }

  set theme(bool value) {
    setState(() {
      ajustes.setDarkTheme = value;
    });
  }

  set selectedColor(Color color) {
    setState(() {
      ajustes.color = color;
    });
  }

  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'AutistApp',
          theme: ThemeData(
            colorScheme: lightColorScheme ?? _defaultLightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          initialRoute: ajustes.welcome ? '/welcome' : "/home",
          routes: {
            '/welcome': (context) => PantallaBienvenida(
                  ajustes: ajustes,
                  onThemeChanged: (value) => theme = value,
                  onColorSelected: (colorSel) => selectedColor = colorSel,
                ),
            '/home': (context) => VistaInicio(
                  ajustes: ajustes,
                  onThemeChanged: (value) => theme = value,
                  onChangeColour: (colorSel) => selectedColor = colorSel,
                ),
          },
        );
      });
    }
  }
}
