import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class NotaVoz {
  String id;
  final String audioFileName;
  final DateTime fecha;
  String descripcion;
  int mood;
  int ambito;

  NotaVoz({
    required this.id,
    required this.audioFileName,
    required this.fecha,
    this.descripcion = 'sin descripción',
    this.mood = 1,
    this.ambito = 0,
  }) {
    if (descripcion.length > 100) {
      descripcion = descripcion.substring(0, 100);
    }
  }
}

class ListaNotasVoz {
  List<NotaVoz> _notas = [];

  get notas => _notas;

  set notas(value) => _notas = value;
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_audio_notes.json');
  }

  List<NotaVoz> toList() {
    return _notas;
  }

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        _notas = List<NotaVoz>.from(data['voiceNotes'].map((x) => NotaVoz(
            id: x['id'],
            audioFileName: x['audioFileName'],
            fecha: DateTime.parse(x['fecha']),
            descripcion: x['descripcion'],
            mood: x['mood'],
            ambito: x['ambito'])));
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<void> cargarDatosPorFecha(String fecha) async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        List<NotaVoz> notasFec = List<NotaVoz>.from(data['voiceNotes']
            .where((x) => (DateFormat("yyyy-MM-dd")
                .format(DateTime.parse(x['fecha']))
                .contains(fecha)))
            .map((x) => NotaVoz(
                id: x['id'],
                audioFileName: x['audioFileName'],
                fecha: DateTime.parse(x['fecha']),
                descripcion: x['descripcion'],
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
      'voiceNotes': List<dynamic>.from(_notas.map((x) => {
            'id': x.id,
            'audioFileName': x.audioFileName,
            'fecha': x.fecha.toIso8601String(),
            'descripcion': x.descripcion,
            'mood': x.mood,
            'ambito': x.ambito
          })),
    }));
  }

  void agregarNota(String uuid, String audioFileName, String descripcion,
      int mood, int ambito) {
    try {
      NotaVoz notaExistente = _notas.firstWhere((nota) => nota.id == uuid);
      notaExistente.descripcion = descripcion;
      notaExistente.mood = mood;
      notaExistente.ambito = ambito;
    } catch (e) {
      _notas.add(NotaVoz(
        id: uuid,
        audioFileName: audioFileName,
        fecha: DateTime.now(),
        descripcion: descripcion,
        mood: mood,
        ambito: ambito,
      ));
    }
    guardarDatos();
  }

  NotaVoz getNota(int index) {
    return _notas[index];
  }

  void editarNota(int index, String desc, int mood, int ambito) {
    _notas[index].descripcion = desc;
    _notas[index].mood = mood;
    _notas[index].ambito = ambito;
  }

  void eliminarNota(String id) {
    final nota = _notas.firstWhere((nota) => nota.id == id);
    final uri = Uri.parse(nota.audioFileName);
    final file = File(uri.toFilePath());
    file.delete().catchError((e) {
      return e;
    });
    _notas.removeWhere((nota) => nota.id == id);
    guardarDatos();
  }
}
