import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

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
      } else {
        // Manejar el caso en que el archivo no exista
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<void> cargarDatosPorFecha(String fecha) async {
    List<NotaVoz> notasFec = [];
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
      print('Error al eliminar el archivo: $e');
    });
    _notas.removeWhere((nota) => nota.id == id);
    guardarDatos();
  }
}

class ListaVoz extends StatefulWidget {
  @override
  _ListaVozState createState() => _ListaVozState();
}

class _ListaVozState extends State<ListaVoz> {
  final listaNotasVoz = ListaNotasVoz();
  List<NotaVoz> busqueda = [];

  @override
  void initState() {
    listaNotasVoz.cargarDatos().then((_) {
      setState(() {
        busqueda = listaNotasVoz.toList();
      });
    });
    super.initState();
  }

  void _filtrarBusqueda(String valor) {
    setState(() {
      if (valor.isEmpty) {
        busqueda = listaNotasVoz.toList();
      } else {
        busqueda = listaNotasVoz
            .toList()
            .where((nota) => _operadorBusqueda(nota, removeDiacritics(valor)))
            .toList();
      }
    });
  }

  bool _operadorBusqueda(NotaVoz nota, String valor) {
    if (removeDiacritics(nota.descripcion.toLowerCase()).contains(valor))
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
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                labelText: "Busca notas...",
                suffixIcon: Icon(Icons.search)),
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
                  title: Text(nota.descripcion),
                  subtitle: Text(
                      DateFormat('yyyy-MM-dd - EEEE - HH:mm:ss', "es_ES")
                          .format(nota.fecha)),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => GrabadorAudio(nota: nota),
                      ),
                    )
                        .then((_) {
                      listaNotasVoz.cargarDatos().then((_) {
                        setState(() {
                          busqueda = listaNotasVoz.toList();
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
              builder: (context) => const GrabadorAudio(),
            ),
          )
              .then((_) {
            listaNotasVoz.cargarDatos().then((_) {
              setState(() {
                busqueda = listaNotasVoz.toList();
              });
            });
          });
        },
      ),
    );
  }
}

class GrabadorAudio extends StatefulWidget {
  final NotaVoz? nota;

  const GrabadorAudio({this.nota});
  @override
  _GrabadorAudioState createState() => _GrabadorAudioState();

  // ...
}

class _GrabadorAudioState extends State<GrabadorAudio> {
  final listaNotasVoz = ListaNotasVoz();
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  bool isRecordingPaused = false;
  double playbackRate = 1.0;
  bool isPlaying = false;
  bool playStart = false;
  int timerFactor = 10;

  Duration elapsedTime = Duration.zero;
  Timer? timer;

  String audioPath = "";

  late TextEditingController _descController;
  late int _ambito;
  late int _mood;

  @override
  void initState() {
    super.initState();
    listaNotasVoz.cargarDatos();
    _descController = TextEditingController(text: widget.nota?.descripcion);
    _ambito = 0;
    _mood = 1;

    listaNotasVoz.cargarDatos().then((_) {
      setState(() {});
    });
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    if (widget.nota != null) {
      _descController.text = widget.nota!.descripcion;
      _ambito = widget.nota!.ambito;
      _mood = widget.nota!.mood;
      audioPlayer.onPlayerStateChanged.listen((event) {
        if (event == PlayerState.completed) {
          setState(() {
            isPlaying = false;
            playStart = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    audioRecord.stop();
    audioRecord.dispose();
    audioPlayer.stop();
    audioPlayer.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!isRecording && !isPlaying) {
        timer.cancel();
      } else {
        setState(() {
          double mult = (timerFactor / 10);
          elapsedTime += const Duration(milliseconds: 10) * mult;
        });
      }
    });
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start(
          bitRate: 128000, // by default
        );
        setState(() {
          isRecording = true;
        });
        elapsedTime = Duration.zero;
        startTimer();
      }
    } catch (e) {
      print("[ERROR] Error al iniciar grabación: $e");
    }
  }

  void pauseRecording() {
    audioRecord.pause();
    timer?.cancel();
    setState(() {
      isRecordingPaused = true;
    });
  }

  void resumeRecording() {
    audioRecord.resume();
    setState(() {
      isRecordingPaused = false;
    });
    startTimer();
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });
      timer?.cancel();
      timer = null;

      elapsedTime = Duration.zero;

      listaNotasVoz.agregarNota(
          const Uuid().v4(),
          audioPath,
          _descController.text == ""
              ? "Nota sin descripción"
              : _descController.text,
          _mood,
          _ambito);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La grabación ha sido creada con éxito')),
      );
    } catch (e) {
      print("[ERROR] Error al parar grabación: $e");
    }
  }

  Future<void> playRecording() async {
    try {
      String path = widget.nota?.audioFileName ?? audioPath;
      Source urlSource = UrlSource(path);
      await audioPlayer.play(urlSource);
      elapsedTime = Duration.zero;
      startTimer();

      setState(() {
        playStart = true;
        isPlaying = true;
      });
    } catch (e) {
      print("[ERROR] Fallo al reproducir: $e");
    }
  }

  Future<void> pausePlay() async {
    try {
      await audioPlayer.pause();
      timer?.cancel();

      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      print("[ERROR] Fallo al pausar: $e");
    }
  }

  Future<void> stopPlay() async {
    try {
      await audioPlayer.stop();
      timer?.cancel();
      timer = null;

      elapsedTime = Duration.zero;

      setState(() {
        isPlaying = false;
        playStart = false;
      });
    } catch (e) {
      print("[ERROR] Fallo al pausar: $e");
    }
  }

  Future<void> resumePlay() async {
    try {
      await audioPlayer.resume();
      startTimer();

      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print("[ERROR] Fallo al reanudar: $e");
    }
  }

  Future<void> changePlaybackRate() async {
    try {
      //audioPlayer.onPlayerStateChanged.listen((event) async {
      //if (event == PlayerState.playing) {
      setState(() {
        playbackRate = playbackRate == 1.0
            ? 1.5
            : playbackRate == 1.5
                ? 2.0
                : 1.0;
        timerFactor = (10 * playbackRate).toInt();
      });
      pausePlay();
      await audioPlayer.setPlaybackRate(playbackRate);
      resumePlay(); //}
      //});
    } catch (e) {
      print("[ERROR] Fallo al cambiar la velocidad de reproducción: $e");
    }
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
                listaNotasVoz.eliminarNota(widget.nota!.id);
                Navigator.of(context).pop();
              },
            ),
          if (widget.nota != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                print('recordFilePath ${widget.nota?.audioFileName}');
                File file = File(widget.nota!.audioFileName);
                await Share.shareXFiles(
                    [XFile(Uri.parse(widget.nota!.audioFileName).toString())]);
              },
            ),
          if (widget.nota != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                widget.nota!.descripcion = _descController.text;
                widget.nota!.ambito = _ambito;
                widget.nota!.mood = _mood;

                listaNotasVoz.agregarNota(widget.nota!.id, audioPath,
                    _descController.text, _mood, _ambito);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: _descController,
            maxLength: 100,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              labelText: "Título",
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
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${elapsedTime.inHours}:${elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(elapsedTime.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(elapsedTime.inMilliseconds.remainder(1000) / 10).floor().toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontFamily: 'Segment7',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: widget.nota != null
          ? Stack(
              children: [
                if (isPlaying)
                  Positioned(
                    bottom: 144,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: "audioSpeed",
                      onPressed: changePlaybackRate,
                      child: Text(playbackRate.toStringAsFixed(1)),
                    ),
                  ),
                if (isPlaying)
                  Positioned(
                    bottom: 80,
                    right: 16,
                    child: FloatingActionButton(
                        heroTag: "audioStop",
                        onPressed: stopPlay,
                        child: Icon(Icons.stop)),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: "audioPlay",
                    onPressed: () {
                      if (isPlaying) {
                        pausePlay();
                      } else {
                        if (!playStart) {
                          playRecording();
                        } else {
                          resumePlay();
                        }
                      }
                    },
                    child: isPlaying
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow),
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                if (isRecording)
                  Positioned(
                    bottom: 80,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: "btn1",
                      onPressed:
                          isRecordingPaused ? resumeRecording : pauseRecording,
                      child: isRecordingPaused
                          ? const Icon(Icons.play_arrow)
                          : const Icon(Icons.pause),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: "btn0",
                    onPressed: isRecording ? stopRecording : startRecording,
                    child: isRecording
                        ? const Icon(Icons.stop)
                        : const Icon(Icons.mic),
                  ),
                ),
              ],
            ),
    );
  }
}
