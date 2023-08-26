import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart';

class NotaTexto {
  String id;
  String titulo;
  final DateTime fecha;
  String texto;
  int mood;
  int ambito;

  NotaTexto({
    required this.id,
    required this.titulo,
    required this.fecha,
    this.texto = '',
    this.mood = 1,
    this.ambito = 0,
  }) {
    if (titulo.length > 100) {
      titulo = titulo.substring(0, 100);
    }
  }
}

class ListaNotasTexto {
  List<NotaTexto> notas = [];

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_text_notes.json');
  }

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        notas = List<NotaTexto>.from(data['voiceNotes'].map((x) => NotaTexto(
            id: x['id'],
            titulo: x['audioFileName'],
            fecha: DateTime.parse(x['fecha']),
            texto: x['descripcion'],
            mood: x['mood'],
            ambito: x['ambito'])));
      } else {
        // Manejar el caso en que el archivo no exista
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<File> guardarDatos() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode({
      'voiceNotes': List<dynamic>.from(notas.map((x) => {
            'id': x.id,
            'titulo': x.titulo,
            'fecha': x.fecha.toIso8601String(),
            'texto': x.texto,
            'mood': x.mood,
            'ambito': x.ambito
          })),
    }));
  }

  void agregarNota(
      String uuid, String titulo, String texto, int mood, int ambito) {
    try {
      NotaTexto notaExistente = notas.firstWhere((nota) => nota.id == uuid);
      notaExistente.titulo = titulo;
      notaExistente.texto = titulo;
      notaExistente.mood = mood;
      notaExistente.ambito = ambito;
    } catch (e) {
      notas.add(NotaTexto(
        id: uuid,
        titulo: titulo,
        fecha: DateTime.now(),
        texto: texto,
        mood: mood,
        ambito: ambito,
      ));
    }
    guardarDatos();
  }

  void eliminarNota(String id) {
    notas.removeWhere((notaBuscada) => notaBuscada.id == id);
    guardarDatos();
  }
}

class VistaNotasTexto extends StatefulWidget {
  @override
  _VistaNotasTextoState createState() => _VistaNotasTextoState();
}

class _VistaNotasTextoState extends State<VistaNotasTexto> {
  final listaNotasTexto = ListaNotasTexto();

  @override
  void initState() {
    super.initState();
    listaNotasTexto.cargarDatos().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de notas de voz'),
      ),
      body: ListView.builder(
        itemCount: listaNotasTexto.notas.length,
        itemBuilder: (context, index) {
          final reversedIndex = listaNotasTexto.notas.length - 1 - index;
          final nota = listaNotasTexto.notas[reversedIndex];
          return ListTile(
            title: Text(nota.titulo),
            subtitle: Text(DateFormat('yyyy-MM-dd - EEEE - HH:mm:ss', "es_ES")
                .format(nota.fecha)),
            onTap: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => EditorNotas(nota: nota),
                ),
              )
                  .then((_) {
                listaNotasTexto.cargarDatos().then((_) {
                  setState(() {});
                });
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn3",
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => const EditorNotas(),
            ),
          )
              .then((_) {
            listaNotasTexto.cargarDatos().then((_) {
              setState(() {});
            });
          });
        },
      ),
    );
  }
}

class EditorNotas extends StatefulWidget {
  final NotaTexto? nota;

  const EditorNotas({this.nota});
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

  @override
  void initState() {
    super.initState();
    listaNotasTexto.cargarDatos();
    _descController = TextEditingController(text: widget.nota?.titulo);
    _textController = TextEditingController(text: widget.nota?.texto);

    _ambito = 0;
    _mood = 1;

    listaNotasTexto.cargarDatos().then((_) {
      setState(() {});
    });

    if (widget.nota != null) {
      _descController.text = widget.nota!.titulo;
      _descController.text = widget.nota!.texto;
      _ambito = widget.nota!.ambito;
      _mood = widget.nota!.mood;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Nota de voz'),
          actions: [
            if (widget.nota != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  listaNotasTexto.eliminarNota(widget.nota!.id);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _descController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Título',
                ),
              ),
              TextField(
                controller: _textController,
                maxLength: 4000,
                decoration: const InputDecoration(
                  labelText: 'Texto',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.sentiment_very_satisfied),
                    color: _mood == 2 ? Colors.green : null,
                    onPressed: () {
                      setState(() {
                        _mood = 2;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.sentiment_neutral),
                    color: _mood == 1 ? Colors.yellow : null,
                    onPressed: () {
                      setState(() {
                        _mood = 1;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.sentiment_very_dissatisfied),
                    color: _mood == 0 ? Colors.red : null,
                    onPressed: () {
                      setState(() {
                        _mood = 0;
                      });
                    },
                  ),
                ],
              ),
              DropdownButton<int>(
                value: _ambito,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('⚙️ Académico/Laboral'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('🗣 Social'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('😇 Personal'),
                  ),
                ],
                onChanged: (value) {
                  if (widget.nota != null && value != null) {
                    setState(() {
                      _ambito = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: "audioSave",
                onPressed: () {
                  widget.nota!.titulo = _descController.text;
                  widget.nota!.texto = _textController.text;
                  widget.nota!.ambito = _ambito;
                  widget.nota!.mood = _mood;

                  listaNotasTexto.agregarNota(
                      widget.nota!.id,
                      _descController.text,
                      _textController.text,
                      _mood,
                      _ambito);
                  Navigator.pop(context);
                },
                child: const Icon(Icons.save),
              ),
            ),
          ],
        ));
  }
}
