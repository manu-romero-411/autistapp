import 'package:autistapp/apuntes/audio/vista_lista_notas_voz.dart';
import 'package:autistapp/apuntes/texto/vista_lista_notas_texto.dart';
import 'package:autistapp/inicio/vista_about.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/planes/vista_meta_lista_planes.dart';
import 'package:autistapp/calendario/vista_dias.dart';
import 'package:autistapp/ruleta/vista_lista_ruletas.dart';
import 'package:flutter/material.dart';

class MenuLateral extends StatefulWidget {
  final Ajustes _ajustes;

  const MenuLateral(
      {Key? key, required this.onThemeChanged, required Ajustes ajustes})
      : _ajustes = ajustes,
        super(key: key);
  final ValueChanged<bool> onThemeChanged;

  @override
  MenuLateralState createState() => MenuLateralState();
}

class MenuLateralState extends State<MenuLateral> {
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _isDark = widget._ajustes.isDarkTheme;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const DrawerHeader(
        decoration: BoxDecoration(
            color: Colors.blue,
            image: DecorationImage(
                image: AssetImage("assets/images/menu.png"),
                fit: BoxFit.cover)),
        child: Text(
          'Menú',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      /*ListTile(
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
      ),*/
      ListTile(
        leading: const Icon(Icons.calendar_month),
        dense: true,
        title: const Text('Vista de calendario'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VistaCalendario(ajustes: widget._ajustes)),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.casino),
        dense: true,
        title: const Text('Ruleta de decisiones'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VistaListaRuletas(ajustes: widget._ajustes)),
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
                    VistaListaNotasVoz(ajustes: widget._ajustes)),
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
                builder: (context) =>
                    VistaNotasTexto(ajustes: widget._ajustes)),
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
                    VistaMetaListaPlanes(ajustes: widget._ajustes)),
          );
        },
      ),
      ListTile(
        dense: true,
        onTap: () {
          setState(() {
            _isDark = !_isDark;
            widget.onThemeChanged(_isDark);
          });
        },
        leading: const Icon(Icons.dark_mode_outlined),
        title: const Text('Tema oscuro'),
        trailing: Switch(
          value: _isDark,
          activeColor: widget._ajustes.color,
          onChanged: (value) {
            setState(() {
              _isDark = value;
              widget.onThemeChanged(value);
            });
          },
        ),
      ),
      /*ListTile(
        dense: true,
        leading: const Icon(Icons.help),
        title: const Text('Cómo usar la app'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VistaAyudaApp(ajustes: widget._ajustes)),
          );
        },
      ),*/
      ListTile(
        dense: true,
        leading: const Icon(Icons.info),
        title: const Text('Acerca de'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VistaAbout(ajustes: widget._ajustes)),
          );
        },
      ),
    ];

    return Drawer(
      child: ListView(children: children),
    );
  }
}
