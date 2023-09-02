import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';

class VistaAyuda extends StatefulWidget {
  final Ajustes ajustes;
  const VistaAyuda({Key? key, required this.ajustes}) : super(key: key);

  @override
  _VistaAyudaState createState() => _VistaAyudaState();
}

class _VistaAyudaState extends State<VistaAyuda> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "¿Necesitas ayuda?",
          style: TextStyle(color: widget.ajustes.fgColor),
        ),
        backgroundColor: widget.ajustes.color,
        leading: BackButton(color: widget.ajustes.fgColor),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: buildCard(
                  'Estoy teniendo una sobrecarga sensorial/emocional',
                  Icons.sentiment_very_dissatisfied)),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: buildCard(
                  'Estoy teniendo dificultades con la gente', Icons.group)),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: buildCard(
                  'Me está costando planificarme.', Icons.event_busy)),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: buildCard('Me ha ocurrido un imprevisto', Icons.error)),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
      // Aquí puedes construir tu interfaz de usuario
    );
  }
}

Card buildCard(String title, IconData icon) {
  return Card(
    child: ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        print('Card seleccionada');
        // Aquí puedes añadir tu propio método onPressed
      },
    ),
  );
}
