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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(children: [
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
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.5,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'AutistApp\n',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.ajustes.fgColor,
                    ),
                  ),
                  TextSpan(
                      style: TextStyle(
                        color: widget.ajustes.fgColor,
                      ),
                      text:
                          "Prototipo de asistente personal para personas con TEA\n\n"),
                  TextSpan(
                    text: "Trabajo de final de grado EPSJ 2022-xxxx",
                    style: TextStyle(
                      color: widget.ajustes.fgColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
                "Autor: Manuel Jesús Romero Mateos - mjrm0035@red.ujaen.es"),
            const Text(
                "Colabora: Aurora Cobo - psicóloga de HorizonTEAsperger Jaén"),
          ]),
        ),
      ),

      // Aquí puedes construir tu interfaz de usuario
    );
  }
}
