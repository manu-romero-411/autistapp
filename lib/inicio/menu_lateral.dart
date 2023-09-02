import 'package:autistapp/apuntes/audio/vista_lista_notas_voz.dart';
import 'package:autistapp/apuntes/texto/apuntes_texto.dart';
import 'package:autistapp/autoayuda/contactos/VistaContactos.dart';
import 'package:autistapp/inicio/vista_about.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/inicio/vista_ayuda.dart';
import 'package:autistapp/planes/vista_lista_planes.dart';
import 'package:autistapp/planes/vista_plan.dart';
import 'package:autistapp/tareas/vida_diaria/vista_dias.dart';
import 'package:flutter/material.dart';

class MenuLateral extends StatefulWidget {
  final Ajustes ajustes;

  const MenuLateral(
      {Key? key, required this.onThemeChanged, required this.ajustes})
      : super(key: key);
  final ValueChanged<String> onThemeChanged;

  @override
  _MenuLateralState createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  bool notificationsEnabled = false;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    widget.ajustes.theme == "light" ? isDark = false : isDark = true;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const DrawerHeader(child: Text('Menú')),
      ListTile(
        dense: true,
        leading: const Icon(Icons.phone),
        title: const Text('Contactos de emergencia'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VistaContactos(ajustes: widget.ajustes)),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.calendar_month),
        dense: true,
        title: const Text('Vista de calendario'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VistaCalendario(ajustes: widget.ajustes)),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.mic),
        dense: true,
        title: const Text('Notas de voz'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VistaListaNotasVoz(ajustes: widget.ajustes)),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.edit),
        dense: true,
        title: const Text('Notas de texto'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VistaNotasTexto(ajustes: widget.ajustes)),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.view_day),
        dense: true,
        title: const Text('Planificaciones de días'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VistaListaPlanes(ajustes: widget.ajustes)),
          );
        },
      ),
      ListTile(
        dense: true,
        onTap: () {
          setState(() {
            isDark = !isDark;
            String change = (isDark ? "dark" : 'light');
            widget.onThemeChanged(change);
          });
        },
        leading: const Icon(Icons.dark_mode_outlined),
        title: const Text('Tema oscuro'),
        trailing: Switch(
          value: isDark,
          onChanged: (value) {
            setState(() {
              String change = "";
              isDark = value;
              value ? change = 'dark' : change = 'light';
              widget.onThemeChanged(change);
            });
          },
        ),
      ),
      ListTile(
        dense: true,
        leading: const Icon(Icons.help),
        title: const Text('Cómo usar la app'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VistaAyudaApp(ajustes: widget.ajustes)),
          );
        },
      ),
      ListTile(
        dense: true,
        leading: const Icon(Icons.info),
        title: const Text('Acerca de'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VistaAbout(ajustes: widget.ajustes)),
          );
        },
      ),
    ];

    return Drawer(
      child: ListView(children: children),
    );
  }
}
