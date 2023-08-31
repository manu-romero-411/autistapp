import 'package:autistapp/apuntes/audio/apuntesAudio.dart';
import 'package:autistapp/apuntes/texto/apuntesTexto.dart';
import 'package:autistapp/tareas/vida_diaria/Dia.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class VistaCalendario extends StatefulWidget {
  VistaCalendario({Key? key}) : super(key: key);

  final String title = "¿Cómo te ha ido cada día?";

  @override
  _VistaCalendarioState createState() => _VistaCalendarioState();
}

class _VistaCalendarioState extends State<VistaCalendario> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: TableCalendar(
          firstDay: DateTime.utc(2023, 01, 01),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) {
            // Use `selectedDayPredicate` to determine which day is currently selected.
            // If this returns true, then `day` will be marked as selected.

            // Using `isSameDay` is recommended to disregard
            // the time-part of compared DateTime objects.
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              // Call `setState()` when updating the selected day
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              // Navigate to another view with the selected date as argument
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VistaDia(selectedDate: selectedDay),
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
  final DateTime selectedDate;

  const VistaDia({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _VistaDiaState createState() => _VistaDiaState();
}

class _VistaDiaState extends State<VistaDia> {
  ListaNotasTexto listaNotasTexto = ListaNotasTexto();
  ListaNotasVoz listaNotasVoz = ListaNotasVoz();

  // Un ejemplo de objeto Dia con algunos datos de prueba
  Dia dia = Dia(
      id: DateFormat("yyyyMMdd").format(DateTime.now()),
      nombre: '',
      mood: -1,
      texto: '');

  @override
  void initState() {
    super.initState();

    dia.id = DateFormat("yyyyMMdd").format(widget.selectedDate);

    dia.cargarDatos().then((_) {
      setState(() {});
    });

    listaNotasTexto
        .cargarDatosPorFecha(
            DateFormat("yyyy-MM-dd").format(widget.selectedDate))
        .then((_) {
      setState(() {});
    });

    listaNotasVoz
        .cargarDatosPorFecha(
            DateFormat("yyyy-MM-dd").format(widget.selectedDate))
        .then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat("yyyy-MM-dd EEEE", "es_ES")
            .format(widget.selectedDate)
            .toString()),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
              ),
              const Text(
                '¿Cómo te sentiste este día?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 20,
                height: 20,
              ),
              // Mostrar un icono diferente según el valor de dia.mood
              dia.mood == -1
                  ? const Text(
                      "❓",
                      style: TextStyle(fontSize: 32),
                    )
                  : dia.mood == 0
                      ? const Text(
                          "😄",
                          style: TextStyle(fontSize: 32),
                        )
                      : dia.mood == 1
                          ? const Text(
                              "😕",
                              style: TextStyle(fontSize: 32),
                            )
                          : dia.mood == 2
                              ? const Text(
                                  "😢",
                                  style: TextStyle(fontSize: 32),
                                )
                              : const Text(
                                  "😩",
                                  style: TextStyle(fontSize: 32),
                                ),

              Text(
                dia.texto,
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              listaNotasTexto.toList().isNotEmpty
                  ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          const SizedBox(height: 10, width: 1),

                          const Text(
                            'Notas de texto',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ), // Espacio entre botones
                          const SizedBox(height: 5, width: 2),

                          ListView.builder(
                            // Mostrar una lista con los elementos de dia.notasVoz
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: listaNotasTexto.toList().length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(Icons.text_snippet),
                                title: Text(
                                    listaNotasTexto.toList()[index].titulo),
                                onTap: () {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => EditorNotas(
                                          nota: listaNotasTexto.notas[index]),
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
              const SizedBox(height: 20, width: 20),
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
                                title: Text(
                                    listaNotasVoz.toList()[index].descripcion),
                                onTap: () {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => GrabadorAudio(
                                          nota: listaNotasVoz.notas[index]),
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
                  : const SizedBox(width: 16)
            ],
          ),
        ),
      ),
    );
  }
}
