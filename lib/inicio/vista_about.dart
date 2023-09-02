import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';

class VistaAbout extends StatefulWidget {
  final Ajustes ajustes;
  const VistaAbout({Key? key, required this.ajustes}) : super(key: key);

  @override
  _VistaAboutState createState() => _VistaAboutState();
}

class _VistaAboutState extends State<VistaAbout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Acerca de",
          style: TextStyle(color: widget.ajustes.fgColor),
        ),
        backgroundColor: widget.ajustes.color,
        leading: BackButton(color: widget.ajustes.fgColor),
      ),
      body: const Column(children: [
        Text("autistApp"),
        Text("Prototipo de asistente personal para personas con TEA"),
        Text("Trabajo de final de grado EPSJ 2022-xxxx"),
        Text("Autor: Manuel Jesús Romero Mateos - mjrm0035@red.ujaen.es"),
        Text("Colabora: Aurora Cobo - psicóloga de HorizonTEAsperger Jaén"),
      ]),

      // Aquí puedes construir tu interfaz de usuario
    );
  }
}
