import 'dart:convert';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';

import 'package:autistapp/tarea.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'common.dart';
import 'inicioView.dart';
import 'apuntes/audio/apuntesAudio.dart';
import 'settings.dart';
import 'menuLateral.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
  String _theme = 'dark';

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
      home: PantallaInicio(
        theme: _theme,
        onThemeChanged: (value) => theme = value,
      ),
    );
  }
}
