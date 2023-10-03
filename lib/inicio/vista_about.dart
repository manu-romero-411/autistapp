import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';

class VistaAbout extends StatefulWidget {
  final Ajustes ajustes;
  const VistaAbout({Key? key, required this.ajustes}) : super(key: key);

  @override
  VistaAboutState createState() => VistaAboutState();
}

class VistaAboutState extends State<VistaAbout> {
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.cover,
                    child: Image.asset(
                      "assets/images/infinity_loop_white.png",
                      width: 200,
                      height: 200,
                    ),
                  );
                },
              ),
            ),
            const Text(
              "AutistApp",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
                "Prototipo de asistente personal para personas con TEA\n\n"),
            const Text(
              textAlign: TextAlign.center,
              "Trabajo de final de grado EPSJ 21/22-3770",
              style: TextStyle(),
            ),
            const SizedBox(height: 24),
            const Text(
                textAlign: TextAlign.center,
                "Autor: Manuel Jesús Romero Mateos - mjrm0035@red.ujaen.es"),
            const Text(
                textAlign: TextAlign.center,
                "Colabora: Aurora Cobo - psicóloga de HorizonTEAsperger Jaén"),
          ]),
        ),
      ),

      // Aquí puedes construir tu interfaz de usuario
    );
  }
}
