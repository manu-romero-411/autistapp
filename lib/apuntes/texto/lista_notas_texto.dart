import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:autistapp/apuntes/texto/nota_texto.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

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

  int getSize() {
    return _notas.length;
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
      throw Exception('Error al cargar datos: $e');
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
      throw Exception('Error al cargar datos: $e');
    }
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
      titulo.isEmpty
          ? notaExistente.titulo == "Nota sin título"
          : notaExistente.titulo = titulo;
      notaExistente.texto = texto;
      notaExistente.mood = mood;
      notaExistente.ambito = ambito;
    } catch (e) {
      _notas.add(NotaTexto(
        id: uuid,
        titulo: titulo.isEmpty ? "Nota sin título" : titulo,
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
