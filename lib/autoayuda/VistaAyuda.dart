import 'package:flutter/material.dart';

class VistaAyuda extends StatefulWidget {
  const VistaAyuda({Key? key}) : super(key: key);

  @override
  _VistaAyudaState createState() => _VistaAyudaState();
}

class _VistaAyudaState extends State<VistaAyuda> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("¿Necesitas ayuda?")),
      // Aquí puedes construir tu interfaz de usuario
    );
  }
}
