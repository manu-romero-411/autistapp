import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:diacritic/diacritic.dart';

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

  List<NotaTexto> toList() {
    return notas;
  }

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        notas = List<NotaTexto>.from(data['textNotes'].map((x) => NotaTexto(
            id: x['id'],
            titulo: x['titulo'],
            fecha: DateTime.parse(x['fecha']),
            texto: x['texto'],
            mood: x['mood'],
            ambito: x['ambito'])));
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<File> guardarDatos() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode({
      'textNotes': List<dynamic>.from(notas.map((x) => {
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
      notaExistente.texto = texto;
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
  List<NotaTexto> busqueda = [];

  @override
  void initState() {
    super.initState();
    listaNotasTexto.cargarDatos().then((_) {
      setState(() {
        busqueda = listaNotasTexto.toList();
      });
    });
  }

  void _filtrarBusqueda(String valor) {
    setState(() {
      if (valor.isEmpty) {
        busqueda = listaNotasTexto.toList();
      } else {
        busqueda = listaNotasTexto
            .toList()
            .where((nota) => _operadorBusqueda(nota, removeDiacritics(valor)))
            .toList();
      }
    });
  }

  bool _operadorBusqueda(NotaTexto nota, String valor) {
    if (valor == "") return true;
    if (removeDiacritics(nota.titulo.toLowerCase()).contains(valor))
      return true;
    //if (nota.texto.toLowerCase().contains(valor)) return true;
    if ((DateFormat('yyyy-MM-dd', "es_ES").format(nota.fecha).contains(valor)))
      return true;
    if (valor.toLowerCase().contains("acad") ||
        valor.toLowerCase().contains("laboral")) {
      if (nota.ambito == 0) return true;
    }
    if (valor.toLowerCase().contains("social")) {
      if (nota.ambito == 1) return true;
    }

    if (valor.toLowerCase().contains("personal")) {
      if (nota.ambito == 2) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de notas de voz'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => _filtrarBusqueda(value),
            decoration: const InputDecoration(
                labelText: "Busca notas...", suffixIcon: Icon(Icons.search)),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: busqueda.length,
              itemBuilder: (context, index) {
                final reversedIndex = busqueda.length - 1 - index;
                final nota = busqueda[reversedIndex];
                return ListTile(
                  title: Text(nota.titulo),
                  subtitle: Text(
                      DateFormat('yyyy-MM-dd - EEEE - HH:mm:ss', "es_ES")
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
                        setState(() {
                          busqueda = listaNotasTexto.toList();
                        });
                      });
                    });
                  },
                );
              },
            ),
          ),
        ],
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
              setState(() {
                busqueda = listaNotasTexto.toList();
              });
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
  late String _id;

  @override
  void initState() {
    listaNotasTexto.cargarDatos();

    _descController = TextEditingController(text: widget.nota?.titulo);
    _textController = TextEditingController(text: widget.nota?.texto);

    _ambito = 0;
    _mood = 1;
    if (widget.nota != null) {
      _id = widget.nota!.id;
    } else {
      _id = Uuid().v4();
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota de texto'),
        actions: [
          if (widget.nota != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                listaNotasTexto.eliminarNota(widget.nota!.id);
                Navigator.of(context).pop();
              },
            ),
          if (widget.nota != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                await Share.share(_textController.text);
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              listaNotasTexto.agregarNota(_id, _descController.text,
                  _textController.text, _mood, _ambito);
              Navigator.pop(context);
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
    );
  }
}
