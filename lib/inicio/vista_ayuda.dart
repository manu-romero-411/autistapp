import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';

class VistaAyudaApp extends StatefulWidget {
  final Ajustes ajustes;
  const VistaAyudaApp({Key? key, required this.ajustes}) : super(key: key);

  @override
  _VistaAyudaAppState createState() => _VistaAyudaAppState();
}

class _VistaAyudaAppState extends State<VistaAyudaApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Cómo usar la aplicación",
            style: TextStyle(color: widget.ajustes.fgColor),
          ),
          backgroundColor: widget.ajustes.color,
          leading: BackButton(color: widget.ajustes.fgColor),
        ),
        body: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: buildCard('Gestión de tareas', Icons.task)),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: buildCard('Toma de notas de audio y texto', Icons.note)),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: buildCard('¿Cómo me ha ido hoy? Calendario',
                    Icons.calendar_month_outlined)),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: buildCard('Asistente de ayuda personal',
                    Icons.sentiment_very_dissatisfied_rounded)),
            const SizedBox(
              height: 20,
            ),
          ],
        ));
  }
}

Card buildCard(String title, IconData icon) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6.0),
    ),
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        print('Card seleccionada');
        // Aquí puedes añadir tu propio método onPressed
      },
    ),
  );
}
