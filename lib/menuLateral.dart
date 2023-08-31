import 'package:autistapp/apuntes/audio/apuntesAudio.dart';
import 'package:autistapp/apuntes/texto/apuntesTexto.dart';
import 'package:autistapp/tareas/vida_diaria/VistaDias.dart';
import 'package:flutter/material.dart';

class MenuLateral extends StatefulWidget {
  const MenuLateral(
      {Key? key, required this.theme, required this.onThemeChanged})
      : super(key: key);
  final String theme;
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
    widget.theme == "light" ? isDark = false : isDark = true;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const DrawerHeader(child: Text('Menú')),
      ListTile(
        dense: true,
        onTap: () {
          setState(() {
            notificationsEnabled = !notificationsEnabled;
          });
        },
        leading: const Icon(Icons.notifications),
        title: const Text('Habilitar notificaciones'),
        trailing: Switch(
          value: notificationsEnabled,
          onChanged: (value) {
            setState(() {
              notificationsEnabled = value;
            });
          },
        ),
      ),
    ];

    if (notificationsEnabled) {
      children.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.settings),
          title: const Text('Ajustes de notificaciones'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NotificationSettingsScreen()),
            );
          },
        ),
      );
    }

    children.addAll([
      ListTile(
        leading: const Icon(Icons.calendar_today),
        dense: true,
        title: const Text('Vista de calendario'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VistaCalendario()),
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
            MaterialPageRoute(builder: (context) => ListaVoz()),
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
            MaterialPageRoute(builder: (context) => VistaNotasTexto()),
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
          // Mostrar información sobre cómo usar la app
        },
      ),
      ListTile(
        dense: true,
        leading: const Icon(Icons.info),
        title: const Text('Acerca de'),
        onTap: () {
          // Mostrar información sobre la app
        },
      ),
    ]);

    return Drawer(
      child: ListView(children: children),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de notificaciones'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Tono de notificación'),
            subtitle: const Text('Tono seleccionado'),
            onTap: () {
              // Mostrar un diálogo para seleccionar el tono de notificación
            },
          ),
        ],
      ),
    );
  }
}
