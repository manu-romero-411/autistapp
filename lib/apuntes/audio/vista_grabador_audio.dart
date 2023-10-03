import 'dart:async';
import 'package:autistapp/apuntes/audio/lista_notas_voz.dart';
import 'package:autistapp/apuntes/audio/nota_voz.dart';
import 'package:autistapp/apuntes/widgets_editores.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

class GrabadorAudio extends StatefulWidget {
  final NotaVoz? _nota;
  final Ajustes _ajustes;
  final ListaNotasVoz _listaNotasVoz;
  final Function() _onUpdateLista;
  const GrabadorAudio(
      {super.key,
      NotaVoz? nota,
      required Ajustes ajustes,
      required ListaNotasVoz listaNotasVoz,
      required onUpdateLista})
      : _ajustes = ajustes,
        _nota = nota,
        _listaNotasVoz = listaNotasVoz,
        _onUpdateLista = onUpdateLista;
  @override
  GrabadorAudioState createState() => GrabadorAudioState();
}

class GrabadorAudioState extends State<GrabadorAudio> {
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

  String titulo = "";

  late int _ambito;
  late int _mood;

  @override
  void initState() {
    super.initState();
    _ambito = 0;
    _mood = 1;

    widget._listaNotasVoz.cargarDatos().then((_) {
      setState(() {});
    });
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    if (widget._nota != null) {
      titulo = widget._nota!.descripcion;
      _ambito = widget._nota!.ambito;
      _mood = widget._nota!.mood;
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
        await audioRecord.start();
        setState(() {
          isRecording = true;
        });
        elapsedTime = Duration.zero;
        startTimer();
      }
    } catch (e) {
      throw Exception("[ERROR] Error al iniciar grabación: $e");
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

      widget._listaNotasVoz.agregarNota(const Uuid().v4(), audioPath,
          titulo.isEmpty ? "Nota sin descripción" : titulo, _mood, _ambito);
      widget._onUpdateLista();

      if (!context.mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La grabación ha sido creada con éxito')),
      );
    } catch (e) {
      throw Exception("[ERROR] Error al parar grabación: $e");
    }
  }

  Future<void> playRecording() async {
    try {
      String path = widget._nota?.audioFileName ?? audioPath;
      Source urlSource = UrlSource(path);
      await audioPlayer.play(urlSource);
      elapsedTime = Duration.zero;
      startTimer();

      setState(() {
        playStart = true;
        isPlaying = true;
      });
    } catch (e) {
      throw Exception("[ERROR] Fallo al reproducir: $e");
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
      throw Exception("[ERROR] Fallo al pausar: $e");
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
      throw Exception("[ERROR] Fallo al pausar: $e");
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
      throw Exception("[ERROR] Fallo al reanudar: $e");
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
      throw Exception(
          "[ERROR] Fallo al cambiar la velocidad de reproducción: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget._ajustes.fgColor),
        backgroundColor: widget._ajustes.color,
        title: Text('Nota de voz',
            style: TextStyle(color: widget._ajustes.fgColor)),
        actions: [
          if (widget._nota != null)
            IconButton(
              icon: const Icon(Icons.delete),
              color: widget._ajustes.fgColor,
              onPressed: () {
                widget._listaNotasVoz.eliminarNota(widget._nota!.id);
                widget._onUpdateLista();
                Navigator.of(context).pop();
              },
            ),
          if (widget._nota != null)
            IconButton(
              icon: const Icon(Icons.share),
              color: widget._ajustes.fgColor,
              onPressed: () async {
                await Share.shareXFiles(
                    [XFile(Uri.parse(widget._nota!.audioFileName).toString())]);
              },
            ),
          if (widget._nota != null)
            IconButton(
              icon: const Icon(Icons.save),
              color: widget._ajustes.fgColor,
              onPressed: () {
                widget._nota!.descripcion = titulo;
                widget._nota!.ambito = _ambito;
                widget._nota!.mood = _mood;

                widget._listaNotasVoz.agregarNota(
                    widget._nota!.id, audioPath, titulo, _mood, _ambito);
                widget._onUpdateLista();
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  WidgetsEditores(
                    ambito: _ambito,
                    mood: _mood,
                    descController: TextEditingController(text: titulo),
                    cambiarAmbito: _cambiarAmbito,
                    cambiarMood: _cambiarMood,
                    cambiarTitulo: _cambiarTitulo,
                    ajustes: widget._ajustes,
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
              ))),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: widget._nota != null
          ? Stack(
              children: [
                if (isPlaying)
                  Positioned(
                    bottom: 144,
                    right: 16,
                    child: FloatingActionButton(
                      backgroundColor: widget._ajustes.color,
                      foregroundColor: widget._ajustes.fgColor,
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
                        backgroundColor: widget._ajustes.color,
                        foregroundColor: widget._ajustes.fgColor,
                        heroTag: "audioStop",
                        onPressed: stopPlay,
                        child: const Icon(Icons.stop)),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: widget._ajustes.color,
                    foregroundColor: widget._ajustes.fgColor,
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
                      backgroundColor: widget._ajustes.color,
                      foregroundColor: widget._ajustes.fgColor,
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
                    backgroundColor: widget._ajustes.color,
                    foregroundColor: widget._ajustes.fgColor,
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
