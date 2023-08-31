import 'package:flutter/material.dart';
import 'package:autistapp/InicioTareas.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('es_ES', null);
  tz.initializeTimeZones();
  runApp(const AutistAppMain());
}

class AutistAppMain extends StatefulWidget {
  const AutistAppMain({super.key});
  @override
  _AutistAppMainState createState() => _AutistAppMainState();
}

class _AutistAppMainState extends State<AutistAppMain> {
  String _theme = 'light';

  String get theme => _theme;

  set theme(String value) {
    setState(() {
      _theme = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme == 'light'
          ? ThemeData.light()
          : theme == 'dark'
              ? ThemeData.dark()
              : null,
      home: VistaTareas(
        theme: _theme,
        onThemeChanged: (value) => theme = value,
      ),
    );
  }
}
