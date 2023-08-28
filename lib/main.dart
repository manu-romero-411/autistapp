import 'package:flutter/material.dart';
import 'package:autistapp/InicioTareas.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Flutter code sample for [BottomNavigationBar].

void main() {
  initializeDateFormatting('es_ES', null);
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
      //home: ListaVoz(),
      home: VistaTareas(
        theme: _theme,
        onThemeChanged: (value) => theme = value,
      ),
    );
  }
}
