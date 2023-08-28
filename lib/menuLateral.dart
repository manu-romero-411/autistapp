import 'package:autistapp/apuntes/audio/apuntesAudio.dart';
import 'package:autistapp/apuntes/texto/apuntesTexto.dart';
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

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const DrawerHeader(child: Text('Menú')),
      SwitchListTile(
        title: const Text('Habilitar notificaciones'),
        value: notificationsEnabled,
        onChanged: (value) {
          setState(() {
            notificationsEnabled = value;
          });
        },
      ),
    ];

    if (notificationsEnabled) {
      children.add(
        ListTile(
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
        title: const Text('Notas de voz'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListaVoz()),
          );
        },
      ),
      ListTile(
        title: const Text('Notas de texto'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VistaNotasTexto()),
          );
        },
      ),
      ListTile(
        title: const Text('Elegir tema'),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('Selecciona un tema'),
                children: [
                  SimpleDialogOption(
                    padding: const EdgeInsets.all(16.0),
                    onPressed: () {
                      widget.onThemeChanged('light');
                      Navigator.pop(context);
                    },
                    child: const Text('Claro'),
                  ),
                  SimpleDialogOption(
                    padding: const EdgeInsets.all(16.0),
                    onPressed: () {
                      widget.onThemeChanged('dark');
                      Navigator.pop(context);
                    },
                    child: const Text('Oscuro'),
                  ),
                  SimpleDialogOption(
                    padding: const EdgeInsets.all(16.0),
                    onPressed: () {
                      widget.onThemeChanged('system');
                      Navigator.pop(context);
                    },
                    child: const Text('Usar ajustes del sistema'),
                  ),
                ],
              );
            },
          );
        },
      ),
      ListTile(
        title: const Text('Cómo usar la app'),
        onTap: () {
          // Mostrar información sobre cómo usar la app
        },
      ),
      ListTile(
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
