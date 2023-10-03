import 'dart:io';
import 'package:autistapp/apuntes/audio/lista_notas_voz.dart';
import 'package:autistapp/apuntes/audio/vista_grabador_audio.dart';
import 'package:autistapp/apuntes/texto/vista_editor_texto.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/inicio/vista_ajustes.dart';
import 'package:autistapp/inicio/menu_lateral.dart';
import 'package:autistapp/tareas/lista_tareas.dart';
import 'package:autistapp/tareas/vista_editar_tarea.dart';
import 'package:autistapp/tareas/tarea.dart';
import 'package:autistapp/calendario/dia.dart';
import 'package:autistapp/inicio/rutina.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class VistaInicio extends StatefulWidget {
  const VistaInicio(
      {super.key,
      required Ajustes ajustes,
      required this.onThemeChanged,
      required this.onChangeColour})
      : _ajustes = ajustes;

  final Ajustes _ajustes;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<Color> onChangeColour;

  @override
  VistaInicioState createState() => VistaInicioState();
}

class VistaInicioState extends State<VistaInicio> {
  final listaTareas = ListaTareas();
  final listaRutinas = ListaRutinas();
  String nombre = "";
  Dia dia = Dia(
      id: DateFormat("yyyyMMdd").format(DateTime.now()),
      nombre: '',
      mood: -1,
      texto: '');
  bool _isEditing = false;
  final TextEditingController _textFieldController = TextEditingController();

  List<Tarea> busqueda = [];

  @override
  void initState() {
    super.initState();

    dia.cargarDatos().then((_) {
      setState(() {
        _textFieldController.text = dia.texto;
      });
    });

    widget._ajustes.cargarDatos().then((_) {
      setState(() {
        widget.onThemeChanged(widget._ajustes.isDarkTheme);
      });
    });

    listaTareas.cargarDatos().then((_) {
      setState(() {
        busqueda = listaTareas.toList();
      });
    });

    regenerarRutinas().then((_) {
      setState(() {});
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

      /* Definición de las rutinas */
      for (int i = 0; i < widget._ajustes.rutinas.length; ++i) {
        listaRutinas.agregarRutina(
            const Uuid().v4(), widget._ajustes.rutinas[i].nombre, false);
      }
    }
    listaRutinas.cargarDatos(null).then((_) {
      setState(() {});
    });
  }

  void actualizarListasTareas() {
    listaTareas.cargarDatos().then((_) {
      setState(() {
        busqueda = listaTareas.toList();
      });
    });

    setState(() {
      regenerarRutinas();
    });
  }

  void actualizarAjustes() {
    setState(() {
      widget._ajustes.cargarDatos();
      nombre = widget._ajustes.name;
    });
  }

  void textoResumenDia() {
    setState(() {
      dia.texto = _textFieldController.text;
    });
    _isEditing = false;
    const snackBar = SnackBar(content: Text('Texto diario editado con éxito.'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    dia.guardarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: widget._ajustes.fgColor != Colors.black
            ? HSLColor.fromColor(widget._ajustes.color)
                .withLightness(0.4)
                .toColor()
            : widget._ajustes.color,
        appBar: AppBar(
            centerTitle: true,
            title: Text("AutistApp - Inicio",
                style: TextStyle(color: widget._ajustes.fgColor)),
            backgroundColor: widget._ajustes.color,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: widget._ajustes.fgColor),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: widget._ajustes.fgColor),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => VistaAjustes(
                          ajustes: widget._ajustes,
                          onColorSelected: widget.onChangeColour,
                          onChangedAjustes: actualizarAjustes),
                    ),
                  )
                      .then((_) {
                    setState(() {
                      widget._ajustes.name = widget._ajustes.name;
                    });
                  });
                },
              ),
            ]),
        drawer: MenuLateral(
            onThemeChanged: widget.onThemeChanged, ajustes: widget._ajustes),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const SizedBox(
                height: 28,
              ),
              Text(
                "¡Te damos la bienvenida${widget._ajustes.name.toString().isEmpty ? "" : ",  ${widget._ajustes.name}"}!",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: widget._ajustes.fgColor),
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
                    color: widget._ajustes.fgColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0;
                            i < widget._ajustes.emoEmojis.length;
                            ++i)
                          Row(
                            children: [
                              FloatingActionButton(
                                backgroundColor: dia.mood == i
                                    ? widget._ajustes.emoColores[i]
                                    : const Color.fromARGB(255, 212, 222, 219),
                                heroTag: widget._ajustes.emoEmojis[i],
                                onPressed: () async {
                                  setState(() {
                                    dia.mood = i;
                                    _isEditing = true;
                                  });

                                  dia.guardarDatos();
                                },
                                child: Text(widget._ajustes.emoEmojis[i],
                                    style: const TextStyle(fontSize: 32)),
                              ),
                              SizedBox(
                                  width:
                                      i == widget._ajustes.emoEmojis.length - 1
                                          ? 0
                                          : 16), // Espacio entre botones
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: _isEditing ? 16 : 0,
              ),
              _isEditing
                  ? TextField(
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 300,
                      style: TextStyle(color: widget._ajustes.fgColor),
                      onSubmitted: (event) {
                        textoResumenDia();
                      },
                      controller: _textFieldController,
                      cursorColor: widget._ajustes.fgColor,
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: widget._ajustes.fgColor),
                        focusColor: widget._ajustes.fgColor,
                        iconColor: widget._ajustes.fgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide:
                                BorderSide(color: widget._ajustes.fgColor)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(
                              color: widget._ajustes
                                  .fgColor), // Cambia esto al color que desees para el borde en foco.
                        ),
                        label: Text(
                          "Comenta algo sobre tu día",
                          style: TextStyle(color: widget._ajustes.fgColor),
                        ),
                        prefixIcon: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: widget._ajustes.fgColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                            });
                            _textFieldController.text = dia.texto;
                          },
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.save,
                            color: widget._ajustes.fgColor,
                          ),
                          onPressed: () {
                            textoResumenDia();
                          },
                        ),
                      ),
                    )
                  : const SizedBox(height: 0),
              SizedBox(
                height: _isEditing ? 0 : 28,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Datos de tus tareas:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget._ajustes.fgColor,
                      ),
                    ),
                    TextSpan(
                      style: TextStyle(
                        color: widget._ajustes.fgColor,
                      ),
                      text: listaTareas.getCompletados() !=
                              listaTareas.getSize()
                          ? '${listaTareas.getPercentage().toStringAsPrecision(3)} % completadas\n'
                          : listaTareas.getSize() == 0
                              ? 'Parece que no tienes tareas pendientes\n'
                              : '¡Ya has acabado tus tareas!\n',
                    ),
                    TextSpan(
                      text:
                          '¿Pendientes de otros días? ${listaTareas.getCountPendientes() > 0 ? "Sí (${listaTareas.getCountPendientes().toString()})" : 'No'}\n',
                      style: TextStyle(
                        color: widget._ajustes.fgColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Card(
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
                            padding: EdgeInsets.only(top: 14),
                            child: Text(
                              "Tus tareas",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 14),
                            child: Text(
                              "Mantén pulsada una tarea para editarla",
                              style: TextStyle(fontSize: 12),
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
                                  widget._ajustes.flutNotif
                                      .cancel(busqueda[reversedIndex].notifId);
                                  listaTareas.eliminarTarea(
                                      busqueda[reversedIndex].id);
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
                                        tarea: tarea,
                                        ajustes: widget._ajustes,
                                        listaTareas: listaTareas,
                                        onUpdateTareas: actualizarListasTareas,
                                      ),
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
                                  activeColor: widget._ajustes.color,
                                  secondary: Icon(
                                    widget._ajustes.listaAmbitos[tarea.tipo]
                                        .icono,
                                    color: listaTareas
                                            .getPendientesOtrosDias(tarea)
                                        ? const Color.fromARGB(
                                            255, 212, 131, 226)
                                        : widget._ajustes
                                            .prioridadesColor[tarea.prioridad],
                                  ),
                                  title: Text(
                                    "${tarea.nombre}",
                                    style: tarea.completada
                                        ? TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 14,
                                            color: widget._ajustes.isDarkTheme
                                                ? const Color.fromARGB(
                                                    255, 255, 255, 255)
                                                : const Color.fromARGB(
                                                    255, 30, 30, 30))
                                        : TextStyle(
                                            decoration: TextDecoration.none,
                                            fontSize: 14,
                                            color: widget._ajustes.isDarkTheme
                                                ? const Color.fromARGB(
                                                    255, 255, 255, 255)
                                                : const Color.fromARGB(
                                                    255, 30, 30, 30)),
                                  ),
                                  subtitle: Text(
                                    "Iniciada: ${DateFormat('yyyy/MM/dd - EEEE - HH:mm:ss', "es_ES").format(tarea.fechaInicio)}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        "Rutinas - ${DateFormat("yyyy/MM/dd").format(DateTime.now())} - ${DateFormat("EEEE", "es_ES").format(DateTime.now())}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (listaRutinas.getSize() > 0)
                      ...List.generate(listaRutinas.getSize(), (index) {
                        final rutina = listaRutinas.get(index);
                        return CheckboxListTile(
                          activeColor: widget._ajustes.color,
                          dense: true,
                          secondary: widget._ajustes.getRutinaIcon(index),
                          title: RichText(
                            text: TextSpan(
                              text: rutina.nombre,
                              style: rutina.completada
                                  ? TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 14,
                                      color: widget._ajustes.isDarkTheme
                                          ? const Color.fromARGB(
                                              255, 255, 255, 255)
                                          : const Color.fromARGB(
                                              255, 30, 30, 30))
                                  : TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 14,
                                      color: widget._ajustes.isDarkTheme
                                          ? const Color.fromARGB(
                                              255, 255, 255, 255)
                                          : const Color.fromARGB(
                                              255, 30, 30, 30)),
                            ),
                          ),
                          value: rutina.completada,
                          onChanged: (bool? value) {
                            setState(() {
                              rutina.completada = value!;
                            });
                            listaRutinas.guardarDatos();
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
        ),
        floatingActionButton: SpeedDial(
          backgroundColor: widget._ajustes.color,
          foregroundColor: widget._ajustes.fgColor,
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
                    builder: (context) => EditorTareas(
                        ajustes: widget._ajustes,
                        listaTareas: listaTareas,
                        onUpdateTareas: actualizarListasTareas),
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
                      builder: (context) => GrabadorAudio(
                          ajustes: widget._ajustes,
                          listaNotasVoz: ListaNotasVoz(),
                          onUpdateLista: () {
                            setState(() {});
                          })),
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
                    builder: (context) => EditorNotas(ajustes: widget._ajustes),
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
            /*SpeedDialChild(
              child: const Icon(Icons.feedback),
              label: '¡Necesito ayuda!',
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) =>
                        MyAppChu(), //VistaAyuda(ajustes: widget._ajustes),
                  ),
                )
                    .then((_) {
                  setState(() {});
                });
              },
            ),*/
          ],
        ));
  }
}
