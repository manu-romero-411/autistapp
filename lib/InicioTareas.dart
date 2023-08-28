import 'dart:io';
import 'package:autistapp/menuLateral.dart';
import 'package:autistapp/tareas/EditarTarea.dart';
import 'package:autistapp/tareas/tarea.dart';
import 'package:autistapp/tareas/vida_diaria/rutina.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:diacritic/diacritic.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class VistaTareas extends StatefulWidget {
  const VistaTareas(
      {super.key, required this.theme, required this.onThemeChanged});

  final String theme;
  final ValueChanged<String> onThemeChanged;

  @override
  _VistaTareasState createState() => _VistaTareasState();
}

class _VistaTareasState extends State<VistaTareas> {
  final listaTareas = ListaTareas();
  final listaRutinas = ListaRutinas();

  List<TareaN> busqueda = [];

  @override
  void initState() {
    super.initState();
    listaTareas.cargarDatos().then((_) {
      setState(() {
        busqueda = listaTareas.toList();
      });
    });
    regenerarRutinas().then((_) {
      setState(() {
        listaRutinas.cargarDatos();
      });
    });
  }

  void _filtrarBusqueda(String valor) {
    setState(() {
      if (valor.isEmpty) {
        busqueda = listaTareas.toList();
      } else {
        busqueda = listaTareas
            .toList()
            .where((nota) => _operadorBusqueda(nota, removeDiacritics(valor)))
            .toList();
      }
    });
  }

  bool _operadorBusqueda(TareaN tarea, String valor) {
    if (valor == "") return true;
    if (removeDiacritics(tarea.nombre.toLowerCase()).contains(valor))
      return true;
    //if (nota.texto.toLowerCase().contains(valor)) return true;
    if ((DateFormat('yyyy-MM-dd').format(tarea.fechaInicio).contains(valor)))
      return true;
    if ((DateFormat('yyyy-MM-dd').format(tarea.fechaLimite!).contains(valor)))
      return true;

    if (valor.toLowerCase().contains("acad") ||
        valor.toLowerCase().contains("laboral")) {
      if (tarea.tipo == 0) return true;
    }
    if (valor.toLowerCase().contains("social")) {
      if (tarea.tipo == 1) return true;
    }

    if (valor.toLowerCase().contains("personal")) {
      if (tarea.tipo == 2) return true;
    }
    return false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 10, 172, 155),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: MenuLateral(
            theme: widget.theme, onThemeChanged: widget.onThemeChanged),
        body: SingleChildScrollView(
          child: Column(children: [
            const Text(
              "¡Bienvenido, fulano!",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              "¿Cómo te sientes hoy?",
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "feliz",
                  onPressed: () {
                    // Lógica cuando se presiona el botón
                  },
                  child: const Text("😄", style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16), // Espacio entre botones
                FloatingActionButton(
                  heroTag: "neutral",
                  onPressed: () {
                    // Lógica cuando se presiona el botón
                  },
                  child: const Text("😕", style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16), // Espacio entre botones
                FloatingActionButton(
                  heroTag: "triste",
                  onPressed: () {
                    // Lógica cuando se presiona el botón
                  },
                  child: const Text("😔", style: TextStyle(fontSize: 32)),
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
                  const TextSpan(
                    text: 'Datos de tus tareas\n',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: listaTareas.getCompletados() != listaRutinas.getSize()
                        ? '🗓 Tareas que hoy tocaban: ${listaTareas.getPercentage().toStringAsPrecision(3)} % completadas\n'
                        : '🗓 ¡Ya has acabado las tareas para hoy!\n',
                  ),
                  const TextSpan(text: '🔙 ¿Pendientes de otros días? Sí\n'),
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
                                    builder: (context) =>
                                        EditorTareas(tarea: tarea),
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
              height: 16,
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
                                  color: widget.theme == "light"
                                      ? Colors.black87
                                      : Colors.white12)
                              : TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  color: widget.theme == "light"
                                      ? Colors.black87
                                      : Colors.white12),
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
          ]),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.edit),
              label: 'Nueva tarea',
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => const EditorTareas(),
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
                    builder: (context) => const EditorTareas(),
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
                    builder: (context) => EditorTareas(),
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
              child: const Icon(Icons.edit),
              label: '¡Necesito ayuda!',
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => const EditorTareas(),
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
