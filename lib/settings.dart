import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String theme;
  final ValueChanged<String> onThemeChanged;

  const SettingsScreen(
      {super.key, required this.theme, required this.onThemeChanged});

  @override
  _SettingsScreenState createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Habilitar notificaciones'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('Tema'),
            trailing: PopupMenuButton<String>(
              initialValue: widget.theme,
              onSelected: widget.onThemeChanged,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'light', child: Text('Claro')),
                const PopupMenuItem(value: 'dark', child: Text('Oscuro')),
                const PopupMenuItem(
                    value: 'system', child: Text('Usar ajustes del sistema')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Teléfonos de emergencia'),
            onTap: () {
              // Navegar a la pantalla de teléfonos de emergencia
            },
          ),
        ],
      ),
    );
  }
}
