import 'package:autistapp/apuntes/texto/lista_notas_texto.dart';
import 'package:autistapp/apuntes/texto/nota_texto.dart';
import 'package:autistapp/apuntes/widgets_editores.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class EditorNotas extends StatefulWidget {
  final NotaTexto? nota;
  final Ajustes ajustes;
  const EditorNotas({super.key, this.nota, required this.ajustes});
  @override
  _EditorNotasState createState() => _EditorNotasState();

  // ...
}

class _EditorNotasState extends State<EditorNotas> {
  final listaNotasTexto = ListaNotasTexto();

  late TextEditingController _descController;
  late TextEditingController _textController;

  late int _ambito;
  late int _mood;
  late String _id;
  late String titulo;

  @override
  void initState() {
    listaNotasTexto.cargarDatos();

    _descController = TextEditingController(text: widget.nota?.titulo);
    _textController = TextEditingController(text: widget.nota?.texto);

    _ambito = 0;
    _mood = 1;
    if (widget.nota != null) {
      titulo = widget.nota!.titulo;
    } else {
      titulo = "Nota sin título";
    }

    if (widget.nota != null) {
      _id = widget.nota!.id;
    } else {
      _id = const Uuid().v4();
    }

    listaNotasTexto.cargarDatos().then((_) {
      setState(() {});
    });

    if (widget.nota != null) {
      _descController.text = widget.nota!.titulo;
      _textController.text = widget.nota!.texto;
      _ambito = widget.nota!.ambito;
      _mood = widget.nota!.mood;
    }

    super.initState();
  }

  void _cambiarAmbito(int ambito) {
    setState(() {
      _ambito = ambito;
    });
  }

  void _cambiarMood(int mood) {
    setState(() {
      _mood = mood;
    });
  }

  void _cambiarTitulo(String tit) {
    setState(() {
      titulo = tit;
    });
  }

  String getTextoAmbito(int ambito) {
    switch (ambito) {
      case 0:
        return 'Académico/Laboral';
      case 1:
        return 'Social';
      case 2:
        return 'Personal';
      default:
        return 'Otro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget.ajustes.fgColor),
        backgroundColor: widget.ajustes.color,
        title: Text('Nota de texto',
            style: TextStyle(color: widget.ajustes.fgColor)),
        actions: [
          if (widget.nota != null)
            IconButton(
              color: widget.ajustes.fgColor,
              icon: const Icon(Icons.delete),
              onPressed: () {
                listaNotasTexto.eliminarNota(widget.nota!.id);
                if (!context.mounted) return;

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('La nota ha sido eliminada con éxito')),
                );
              },
            ),
          if (widget.nota != null)
            IconButton(
              color: widget.ajustes.fgColor,
              icon: const Icon(Icons.share),
              onPressed: () async {
                await Share.share(
                    "AutisApp - Nota de texto\nFecha: ${DateFormat("yyyy-MM-dd EEEE", "es_ES").format(widget.nota!.fecha)}\nMood: ${_mood == 0 ? '🟢' : _mood == 1 ? '🟠' : '🔴'}\n\n${widget.nota!.titulo.toUpperCase()}\n======\n\n${_textController.text}");
              },
            ),
          IconButton(
            color: widget.ajustes.fgColor,
            icon: const Icon(Icons.save),
            onPressed: () {
              listaNotasTexto.agregarNota(_id, _descController.text,
                  _textController.text, _mood, _ambito);
              if (!context.mounted) return;

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'La nota ha sido ${(widget.nota != null) ? 'editada' : 'creada'} con éxito')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              WidgetsEditores(
                ambito: _ambito,
                mood: _mood,
                descController: _descController,
                cambiarAmbito: _cambiarAmbito,
                cambiarMood: _cambiarMood,
                cambiarTitulo: _cambiarTitulo,
                ajustes: widget.ajustes,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _textController,
                maxLines: null,
                minLines: 10,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  label: const Text(
                      "Toca aquí para escribir. Puedes usar este campo de texto para ponerte pasos para hacer una tarea, contar de forma libre una situación que te haya pasado..."),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
