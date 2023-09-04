import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';

class WidgetsEditores extends StatefulWidget {
  WidgetsEditores(
      {required ajustes,
      required this.ambito,
      required this.mood,
      required this.descController,
      required this.cambiarAmbito,
      required this.cambiarMood,
      required this.cambiarTitulo})
      : _ajustes = ajustes;
  Ajustes _ajustes;
  int ambito;
  int mood;
  TextEditingController descController;
  Function(int) cambiarAmbito;
  Function(int) cambiarMood;
  Function(String) cambiarTitulo;

  @override
  _WidgetsEditoresState createState() => _WidgetsEditoresState();
}

class _WidgetsEditoresState extends State<WidgetsEditores> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextField(
          onTapOutside: (event) {
            widget.cambiarTitulo(widget.descController.text);
          },
          controller: widget.descController,
          maxLength: 100,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            labelText: 'Título',
          ),
        ),
        const Text(
          "Ánimo de la nota:",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              backgroundColor: widget.mood == 0
                  ? Colors.green
                  : const Color.fromARGB(255, 212, 222, 219),
              heroTag: "feliz",
              onPressed: () async {
                widget.cambiarMood(0);
              },
              child: const Text("😄", style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              backgroundColor: widget.mood == 1
                  ? Colors.amber
                  : const Color.fromARGB(255, 212, 222, 219),
              heroTag: "neutral",
              onPressed: () async {
                widget.cambiarMood(1);
              },
              child: const Text("😕", style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              backgroundColor: widget.mood == 2
                  ? Colors.red
                  : const Color.fromARGB(255, 212, 222, 219),
              heroTag: "triste",
              onPressed: () async {
                widget.cambiarMood(2);
              },
              child: const Text("😢", style: TextStyle(fontSize: 32)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          "Ámbito vital:",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          widget._ajustes.getTextoAmbito(widget.ambito),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget._ajustes.listaAmbitos.length; ++i)
              Row(children: [
                if (i > 0) const SizedBox(width: 16),
                FloatingActionButton(
                  backgroundColor: widget.ambito == i
                      ? Colors.blueAccent
                      : const Color.fromARGB(255, 212, 222, 219),
                  heroTag: "ambito$i",
                  onPressed: () async {
                    widget.cambiarAmbito(i);
                  },
                  child: widget._ajustes.getIconoAmbitoBoton(i, widget.ambito),
                ),
              ]),
            // Espacio entre botones
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
