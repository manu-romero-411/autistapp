/*import 'dart:convert';
import 'dart:io';
import 'package:autistapp/InicioTareas.dart';
import 'package:autistapp/menuLateral.dart';
import 'package:autistapp/tarea.dart';
import 'package:autistapp/tareas/EditarTarea.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';

import 'common.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio(
      {super.key, required this.theme, required this.onThemeChanged});

  final String theme;
  final ValueChanged<String> onThemeChanged;

  @override
  PantallaInicioView createState() =>
      PantallaInicioView(theme: theme, onThemeChanged: onThemeChanged);
}

class PantallaInicioView extends State<PantallaInicio> {
  PantallaInicioView({required this.theme, required this.onThemeChanged});

  final String theme;
  final ValueChanged<String> onThemeChanged;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: MenuLateral(theme: theme, onThemeChanged: onThemeChanged),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 1),
          ),
          const Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 100),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Text(
                      '¡Hola, nombre!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(value: 0.14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BotonFlotanteInicio extends StatefulWidget {
  @override
  _BotonFlotanteInicioState createState() => _BotonFlotanteInicioState();
}

class _BotonFlotanteInicioState extends State<BotonFlotanteInicio> {
  Map<String, dynamic> data = {
    'tasks': [],
  };

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.edit),
          label: 'Nueva tarea',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditorTareas()),
            ).then((_) => setState(() {}));
          },
        ),
      ],
    );
  }
}
*/