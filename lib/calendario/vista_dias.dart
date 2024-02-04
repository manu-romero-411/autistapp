import 'dart:io';

import 'package:autistapp/apuntes/audio/lista_notas_voz.dart';
import 'package:autistapp/apuntes/audio/vista_grabador_audio.dart';
import 'package:autistapp/apuntes/texto/lista_notas_texto.dart';
import 'package:autistapp/apuntes/texto/vista_editor_texto.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/calendario/dia.dart';
import 'package:autistapp/inicio/rutina.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class VistaCalendario extends StatefulWidget {
  final Ajustes ajustes;
  const VistaCalendario({Key? key, required this.ajustes}) : super(key: key);

  final String title = "¿Cómo te ha ido cada día?";

  @override
  VistaCalendarioState createState() => VistaCalendarioState();
}

class VistaCalendarioState extends State<VistaCalendario> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

/*
  Future<String?> _popUpPregunta(BuildContext context, DateTime fecha) async {
    return showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("¿Quieres abrir una nueva vista?"),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context, "");
                },
              ),
              TextButton(
                child: const Text('Sí'),
                onPressed: () {
                  Navigator.pop(context, "");

                  ListaPlanes newLista = ListaPlanes(
                      id: DateFormat("yyyyMMdd").format(fecha).toString(),
                      name: DateFormat("EEEE dd de MMMM de yyyy")
                          .format(fecha)
                          .toString());
                  /*Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => VistaListaPlanes(
                  meta: metaListaPlanes,
                  listaPlanes: newLista,
                  ajustes: widget._ajustes,
                  onChangeNombre: () {}),
            ),
          )
              .then((_) {
            metaListaPlanes!.agregarTarea(newLista.id, newLista.name);
            metaListaPlanes!.cargarDatos().then((_) {
              setState(() {
                busqueda = metaListaPlanes!.toList();
              });
            });
          });*/
                },
              ),
            ],
          );
        });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget.ajustes.fgColor),
        backgroundColor: widget.ajustes.color,
        title:
            Text(widget.title, style: TextStyle(color: widget.ajustes.fgColor)),
      ),
      body: Center(
        child: TableCalendar(
          firstDay: DateTime.utc(2023, 01, 01),
          lastDay: DateTime.now(),
          focusedDay: _focusedDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
            if (int.parse(DateFormat("yyyyMMdd").format(selectedDay)) >
                int.parse(DateFormat("yyyyMMdd").format(_focusedDay))) {
              /*Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _popUpPregunta(
                      selectedDate: selectedDay, ajustes: widget.ajustes),
                ),
              );*/
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VistaDia(
                      selectedDate: selectedDay, ajustes: widget.ajustes),
                ),
              );
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              // Call `setState()` when updating calendar format
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            // No need to call `setState()` here
            _focusedDay = focusedDay;
          },
        ),
      ),
    );
  }
}

class VistaDia extends StatefulWidget {
  final Ajustes ajustes;
  final DateTime selectedDate;

  const VistaDia({Key? key, required this.selectedDate, required this.ajustes})
      : super(key: key);

  @override
  VistaDiaState createState() => VistaDiaState();
}

class VistaDiaState extends State<VistaDia> {
  ListaNotasTexto listaNotasTexto = ListaNotasTexto();
  ListaNotasVoz listaNotasVoz = ListaNotasVoz();
  Dia dia = Dia(
      id: DateFormat("yyyyMMdd").format(DateTime.now()),
      nombre: '',
      mood: -1,
      texto: '');
  late ListaRutinas listaRutinas;

  @override
  void initState() {
    super.initState();
    listaRutinas = ListaRutinas();
    regenerarRutinas();

    dia.id = DateFormat("yyyyMMdd").format(widget.selectedDate);

    // Carga los datos de mood de este día
    dia.cargarDatos().then((_) {
      setState(() {});
    });

    // Carga la lista de notas de texto de este día
    listaNotasTexto
        .cargarDatosPorFecha(
            DateFormat("yyyy-MM-dd").format(widget.selectedDate))
        .then((_) {
      setState(() {});
    });

    // Carga la lista de notas de voz de este día
    listaNotasVoz
        .cargarDatosPorFecha(
            DateFormat("yyyy-MM-dd").format(widget.selectedDate))
        .then((_) {
      setState(() {});
    });

    regenerarRutinas();
  }

  // Verifica la existencia del archivo de rutinas de este día.
  Future<bool> hayRutinas() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/autistapp_rutinas_${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}.json';
    final file = File(filePath);
    return file.exists();
  }

  // Carga la lista de rutinas apuntada en la pantalla de inicio
  Future<void> regenerarRutinas() async {
    if (await hayRutinas()) {
      listaRutinas.cargarDatos(widget.selectedDate).then((_) {
        setState(() {});
      });
    }
  }

  void actualizarListaTexto() {
    setState(() {
      listaNotasTexto.cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget.ajustes.fgColor),
        backgroundColor: widget.ajustes.color,
        title: Text(
            DateFormat("yyyy-MM-dd EEEE", "es_ES")
                .format(widget.selectedDate)
                .toString(),
            style: TextStyle(color: widget.ajustes.fgColor)),
      ),
      // Vista de scroll contínuo
      body: SingleChildScrollView(
        // Contenedor para centrar los widgets
        child: Container(
          alignment: Alignment.topCenter,

          // Columna con los widgets en vertical.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Espaciador vertical
              const SizedBox(height: 20),

              // Texto de título
              const Text(
                '¿Cómo te sentiste este día?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              // Espaciador veticial
              const SizedBox(height: 20),

              // Mostrar un icono diferente según el valor de dia.mood
              Text(
                dia.mood == -1 ? "❓" : widget.ajustes.emoEmojis[dia.mood],
                style: const TextStyle(fontSize: 32),
              ),

              // Espaciador vertical
              const SizedBox(height: 16),

              // Texto de "¿Cómo te ha ido el día?" para el día concreto
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  dia.texto,
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),

              // Espaciador vertical
              const SizedBox(height: 16),

              // Lista de notas de texto realizadas este día
              listaNotasTexto.toList().isNotEmpty
                  ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          const SizedBox(height: 10, width: 1),
                          const Text(
                            'Notas de texto',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5, width: 2),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: listaNotasTexto.toList().length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(Icons.text_snippet),
                                trailing: Icon(widget
                                    .ajustes
                                    .listaAmbitos[
                                        listaNotasTexto.toList()[index].ambito]
                                    .icono),
                                title: Text(
                                    listaNotasTexto.toList()[index].titulo),
                                onTap: () {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => EditorNotas(
                                        nota: listaNotasTexto.notas[index],
                                        ajustes: widget.ajustes,
                                      ),
                                    ),
                                  )
                                      .then((_) {
                                    listaNotasTexto
                                        .cargarDatosPorFecha(
                                            DateFormat("yyyy-MM-dd")
                                                .format(widget.selectedDate))
                                        .then((_) {
                                      setState(() {});
                                    });
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20, width: 20)
                        ],
                      ),
                    )
                  : const SizedBox(height: 20, width: 20),

              // Espaciador vertical
              const SizedBox(height: 20),

              // Lista de notas de voz realizadas este día
              listaNotasVoz.toList().isNotEmpty
                  ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          const SizedBox(height: 10, width: 2),
                          const Text(
                            'Notas de voz',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5, width: 2),
                          ListView.builder(
                            // Mostrar una lista con los elementos de dia.notasTexto
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: listaNotasVoz.toList().length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(Icons.mic),
                                trailing: Icon(widget
                                    .ajustes
                                    .listaAmbitos[
                                        listaNotasVoz.toList()[index].ambito]
                                    .icono),
                                title: Text(
                                    listaNotasVoz.toList()[index].descripcion),
                                onTap: () {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => GrabadorAudio(
                                          nota: listaNotasVoz.notas[index],
                                          ajustes: widget.ajustes,
                                          listaNotasVoz: listaNotasVoz,
                                          onUpdateLista: () {
                                            setState(() {});
                                          }),
                                    ),
                                  )
                                      .then((_) {
                                    listaNotasTexto
                                        .cargarDatosPorFecha(
                                            DateFormat("yyyy-MM-dd")
                                                .format(widget.selectedDate))
                                        .then((_) {
                                      setState(() {});
                                    });
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 20, height: 20),
                        ],
                      ),
                    )
                  : const SizedBox(height: 0),

              // Espaciador vertical
              const SizedBox(height: 20),

              // Lista de rutinas exitosamente realizadas este día
              listaRutinas.getCompletados() > 0
                  ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          const SizedBox(height: 10, width: 1),
                          const Text(
                            'Rutinas hechas',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5, width: 2),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: listaRutinas.getCompletados(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(Icons.check),
                                trailing: Icon(widget
                                    .ajustes
                                    .rutinas[listaRutinas
                                        .getRutinasCompletadas()[index]]
                                    .icono),
                                title: Text(listaRutinas
                                    .get(listaRutinas
                                        .getRutinasCompletadas()[index])
                                    .nombre),
                              );
                            },
                          ),
                          const SizedBox(height: 20, width: 20)
                        ],
                      ),
                    )
                  : const SizedBox(height: 0)
            ],
          ),
        ),
      ),
    );
  }
}
