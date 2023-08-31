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
  List<NotaTexto> _notas = [];

  get notas => _notas;

  set notas(value) => _notas = value;
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_text_notes.json');
  }

  List<NotaTexto> toList() {
    return _notas;
  }

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        _notas = List<NotaTexto>.from(data['textNotes'].map((x) => NotaTexto(
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

  Future<void> cargarDatosPorFecha(String fecha) async {
    List<NotaTexto> notasFec = [];

    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        notasFec = List<NotaTexto>.from(data['textNotes']
            .where((x) => (DateFormat("yyyy-MM-dd")
                .format(DateTime.parse(x['fecha']))
                .contains(fecha)))
            .map((x) => NotaTexto(
                id: x['id'],
                titulo: x['titulo'],
                fecha: DateTime.parse(x['fecha']),
                texto: x['texto'],
                mood: x['mood'],
                ambito: x['ambito'])));

        _notas = notasFec;
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
    //return notasFec;
  }

  Future<File> guardarDatos() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode({
      'textNotes': List<dynamic>.from(_notas.map((x) => {
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
      NotaTexto notaExistente = _notas.firstWhere((nota) => nota.id == uuid);
      titulo == ""
          ? notaExistente.titulo == "Nota sin título"
          : notaExistente.titulo = titulo;
      notaExistente.texto = texto;
      notaExistente.mood = mood;
      notaExistente.ambito = ambito;
    } catch (e) {
      _notas.add(NotaTexto(
        id: uuid,
        titulo: titulo == "" ? "Nota sin título" : titulo,
        fecha: DateTime.now(),
        texto: texto,
        mood: mood,
        ambito: ambito,
      ));
    }
    guardarDatos();
  }

  void eliminarNota(String id) {
    _notas.removeWhere((notaBuscada) => notaBuscada.id == id);
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
                await Share.share(
                    "AutisApp - Nota de texto\nFecha: ${DateFormat("yyyy-MM-dd EEEE", "es_ES").format(widget.nota!.fecha)}\nMood: ${_mood == 0 ? '🟢' : _mood == 1 ? '🟠' : '🔴'}\n\n${widget.nota!.titulo.toUpperCase()}\n======\n\n${_textController.text}");
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    backgroundColor: _mood == 0
                        ? Colors.green
                        : Color.fromARGB(255, 212, 222, 219),
                    heroTag: "feliz",
                    onPressed: () async {
                      setState(() {
                        _mood = 0;
                      });
                    },
                    child: const Text("😄", style: TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 16), // Espacio entre botones
                  FloatingActionButton(
                    backgroundColor: _mood == 1
                        ? Colors.amber
                        : Color.fromARGB(255, 212, 222, 219),
                    heroTag: "neutral",
                    onPressed: () async {
                      setState(() {
                        _mood = 1;
                      });
                    },
                    child: const Text("😕", style: TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    backgroundColor: _mood == 2
                        ? Colors.red
                        : Color.fromARGB(255, 212, 222, 219),
                    heroTag: "triste",
                    onPressed: () async {
                      setState(() {
                        _mood = 2;
                      });
                    },
                    child: const Text("😢", style: TextStyle(fontSize: 32)),
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
              TextField(
                controller: _textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(labelText: 'Texto'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
