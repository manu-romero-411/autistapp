import 'dart:io';
import 'package:autistapp/apuntes/audio/vista_grabador_audio.dart';
import 'package:autistapp/apuntes/texto/apuntes_texto.dart';
import 'package:autistapp/autoayuda/VistaAyuda.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/inicio/vista_ajustes.dart';
import 'package:autistapp/inicio/menu_lateral.dart';
import 'package:autistapp/tareas/lista_tareas.dart';
import 'package:autistapp/tareas/vista_editar_tarea.dart';
import 'package:autistapp/tareas/tarea.dart';
import 'package:autistapp/tareas/vida_diaria/dia.dart';
import 'package:autistapp/tareas/vida_diaria/rutina.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class VistaTareas extends StatefulWidget {
  const VistaTareas(
      {super.key,
      required this.ajustes,
      required this.onThemeChanged,
      required this.onChangeColour});

  final Ajustes ajustes;
  final ValueChanged<String> onThemeChanged;
  final ValueChanged<Color> onChangeColour;

  @override
  _VistaTareasState createState() => _VistaTareasState();
}

class _VistaTareasState extends State<VistaTareas> {
  final listaTareas = ListaTareas();
  final listaRutinas = ListaRutinas();
  String nombre = "";
  Dia dia = Dia(
      id: DateFormat("yyyyMMdd").format(DateTime.now()),
      nombre: '',
      mood: -1,
      texto: '');

  List<Tarea> busqueda = [];

  @override
  void initState() {
    super.initState();
    dia.cargarDatos();
    widget.ajustes.cargarDatos().then((_) {
      setState(() {
        widget.onThemeChanged(widget.ajustes.theme);
      });
    });

    listaTareas.cargarDatos().then((_) {
      setState(() {
        busqueda = listaTareas.toList();
        regenerarRutinas();
        listaRutinas.cargarDatos();
      });
    });
  }

  Future<bool> hayRutinas() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/autistapp_rutinas_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
    final file = File(filePath);
    return file.exists();
  }

  Future<void> regenerarRutinas() async {
    if (!(await hayRutinas())) {
      listaRutinas.borrarTodas();
      listaRutinas.agregarRutina(const Uuid().v4(), "Primera rutina",
          const TimeOfDay(hour: 8, minute: 00), false);
      listaRutinas.agregarRutina(const Uuid().v4(), "Segunda rutina",
          const TimeOfDay(hour: 9, minute: 00), false);
    } else {
      listaRutinas.cargarDatos();
    }
  }

  String getEmojiCircle(int numb) {
    switch (numb) {
      case 0:
        return '🟢';
      case 1:
        return '🟡';
      case 2:
        return '🔴';
      default:
        return '';
    }
  }

  MaterialColor getColor(int numb) {
    switch (numb) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.amber;
      case 2:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData getIcon(int numb) {
    switch (numb) {
      case 0:
        return Icons.work;
      case 1:
        return Icons.person_2;
      case 2:
        return Icons.tag_faces;
      default:
        return Icons.emergency;
    }
  }

  final TextEditingController _textFieldController = TextEditingController();

  Future<String?> _popUpResumenDia(BuildContext context, String titulo) async {
    return showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(titulo),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  hintText: "Comenta algo sobre tu día"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context, "");
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context, _textFieldController.text);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: widget.ajustes.color,
        appBar: AppBar(
            centerTitle: true,
            title: Text("autistApp",
                style: TextStyle(color: widget.ajustes.fgColor)),
            backgroundColor: widget.ajustes.color,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: widget.ajustes.fgColor),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: widget.ajustes.fgColor),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => VistaAjustes(
                          ajustes: widget.ajustes,
                          onColorSelected: widget.onChangeColour),
                    ),
                  )
                      .then((_) {
                    setState(() {
                      widget.ajustes.name = widget.ajustes.name;
                    });
                  });
                },
              ),
            ]),
        drawer: MenuLateral(
            onThemeChanged: widget.onThemeChanged, ajustes: widget.ajustes),
        body: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: 28,
            ),
            Text(
              "¡Te damos la bienvenida, ${widget.ajustes.name}!",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: widget.ajustes.fgColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              "¿Cómo te sientes hoy?",
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: widget.ajustes.fgColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: dia.mood == 0
                      ? Colors.green
                      : const Color.fromARGB(255, 212, 222, 219),
                  heroTag: "feliz",
                  onPressed: () async {
                    String? result =
                        await _popUpResumenDia(context, 'Mi título');

                    setState(() {
                      dia.texto = result;
                      dia.mood = 0;
                      dia.guardarDatos();
                    });
                  },
                  child: const Text("😄", style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16), // Espacio entre botones
                FloatingActionButton(
                  backgroundColor: dia.mood == 1
                      ? Colors.amber
                      : const Color.fromARGB(255, 212, 222, 219),
                  heroTag: "neutral",
                  onPressed: () async {
                    String? result =
                        await _popUpResumenDia(context, 'Mi título');
                    setState(() {
                      dia.texto = result;

                      dia.mood = 1;
                      dia.guardarDatos();
                    });
                  },
                  child: const Text("😕", style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  backgroundColor: dia.mood == 2
                      ? Colors.red
                      : const Color.fromARGB(255, 212, 222, 219),
                  heroTag: "triste",
                  onPressed: () async {
                    String? result =
                        await _popUpResumenDia(context, 'Mi título');
                    print(result);
                    setState(() {
                      dia.texto = result;

                      dia.mood = 2;
                      dia.guardarDatos();
                    });
                  },
                  child: const Text("😢", style: TextStyle(fontSize: 32)),
                ),

                const SizedBox(width: 16),
                FloatingActionButton(
                  backgroundColor: dia.mood == 3
                      ? Colors.purple
                      : const Color.fromARGB(255, 212, 222, 219),
                  heroTag: "cansado",
                  onPressed: () async {
                    String? result =
                        await _popUpResumenDia(context, 'Mi título');
                    setState(() {
                      dia.texto = result;

                      dia.mood = 3;
                      dia.guardarDatos();
                    });
                  },
                  child: const Text("😩", style: TextStyle(fontSize: 32)),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Datos de tus tareas\n',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.ajustes.fgColor),
                  ),
                  TextSpan(
                      style: TextStyle(
                        color: widget.ajustes.fgColor,
                      ),
                      text: listaTareas.getCompletados() !=
                              listaTareas.getSize()
                          ? '🗓 Tareas que hoy tocaban: ${listaTareas.getPercentage().toStringAsPrecision(3)} % completadas\n'
                          : listaTareas.getSize() == 0
                              ? '🗓 Parece que no tienes tareas pendientes\n'
                              : '🗓 ¡Ya has acabado las tareas para hoy!\n'),
                  TextSpan(
                    text: '🔙 ¿Pendientes de otros días? Sí\n',
                    style: TextStyle(
                      color: widget.ajustes.fgColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Card(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: busqueda.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                            "No hay tareas pendientes. ¡Disfruta de tu día!"),
                      ),
                    )
                  : Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "✅ Tus tareas",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ...List.generate(busqueda.length, (index) {
                          final reversedIndex = busqueda.length - 1 - index;
                          final tarea = busqueda[reversedIndex];
                          return Dismissible(
                            key: Key(tarea.id),
                            onDismissed: (direction) {
                              setState(() {
                                listaTareas
                                    .eliminarTarea(busqueda[reversedIndex].id);
                                listaTareas.guardarDatos();
                              });
                            },
                            background: Container(color: Colors.red),
                            child: InkWell(
                              onLongPress: () {
                                Navigator.of(context)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (context) => EditorTareas(
                                        tarea: tarea, ajustes: widget.ajustes),
                                  ),
                                )
                                    .then((_) {
                                  listaTareas.cargarDatos().then((_) {
                                    setState(() {
                                      busqueda = listaTareas.toList();
                                    });
                                  });
                                });
                              },
                              child: CheckboxListTile(
                                secondary: Icon(
                                  getIcon(tarea.tipo),
                                  color: getColor(tarea.prioridad),
                                ),
                                title: Text("${tarea.nombre}"),
                                subtitle: Text(
                                    "Iniciada: ${DateFormat('yyyy-MM-dd - EEEE - HH:mm:ss', "es_ES").format(tarea.fechaInicio)}"),
                                value: tarea.completada,
                                onChanged: (bool? value) {
                                  setState(() {
                                    tarea.completada = value!;
                                    listaTareas.guardarDatos();
                                  });
                                },
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
            const SizedBox(
              height: 24,
            ),
            Card(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "⏳ Rutinas",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...List.generate(listaRutinas.getSize(), (index) {
                    final rutina = listaRutinas.get(index);
                    return CheckboxListTile(
                      title: RichText(
                        text: TextSpan(
                          text: rutina.nombre,
                          style: rutina.completada
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 16,
                                  color: widget.ajustes.theme == "dark"
                                      ? const Color.fromARGB(255, 255, 255, 255)
                                      : const Color.fromARGB(255, 30, 30, 30))
                              : TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  color: widget.ajustes.theme == "dark"
                                      ? const Color.fromARGB(255, 255, 255, 255)
                                      : const Color.fromARGB(255, 30, 30, 30)),
                        ),
                      ),
                      subtitle: Text(DateFormat('HH:mm', "es_ES")
                          .format(rutina.getHoraAsDateTime())),
                      value: rutina.completada,
                      onChanged: (bool? value) {
                        setState(() {
                          rutina.completada = value!;
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
          ]),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.all_inclusive,
          // animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.edit),
              label: 'Nueva tarea',
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => EditorTareas(ajustes: widget.ajustes),
                  ),
                )
                    .then((_) {
                  listaTareas.cargarDatos().then((_) {
                    setState(() {
                      busqueda = listaTareas.toList();
                    });
                  });
                });
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.mic),
              label: 'Nueva nota de voz',
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) =>
                        GrabadorAudio(ajustes: widget.ajustes),
                  ),
                )
                    .then((_) {
                  listaTareas.cargarDatos().then((_) {
                    setState(() {
                      busqueda = listaTareas.toList();
                    });
                  });
                });
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.edit_document),
              label: 'Nueva nota de texto',
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => EditorNotas(ajustes: widget.ajustes),
                  ),
                )
                    .then((_) {
                  listaTareas.cargarDatos().then((_) {
                    setState(() {
                      busqueda = listaTareas.toList();
                    });
                  });
                });
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.feedback),
              label: '¡Necesito ayuda!',
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => VistaAyuda(ajustes: widget.ajustes),
                  ),
                )
                    .then((_) {
                  listaTareas.cargarDatos().then((_) {
                    setState(() {
                      busqueda = listaTareas.toList();
                    });
                  });
                });
              },
            ),
          ],
        ));
  }
}
