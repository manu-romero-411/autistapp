import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/inicio/vista_bienvenida.dart';
import 'package:flutter/material.dart';
import 'package:autistapp/inicio/vista_inicio.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('es_ES', null);
  tz.initializeTimeZones();
  runApp(AutistAppMain());
}

class AutistAppMain extends StatefulWidget {
  AutistAppMain({super.key});
  @override
  _AutistAppMainState createState() => _AutistAppMainState();
}

class _AutistAppMainState extends State<AutistAppMain> {
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

  String get theme {
    return ajustes.theme;
  }

  ThemeData? getThemeData() {
    ajustes.cargarDatos();
    return ajustes.theme == 'light'
        ? ThemeData.light()
        : ajustes.theme == 'dark'
            ? ThemeData.dark()
            : null;
  }

  set theme(String value) {
    setState(() {
      ajustes.theme = value;
    });
  }

  set selectedColor(Color color) {
    setState(() {
      ajustes.color = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return MaterialApp(
        theme: getThemeData(),
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
    }
  }
}
