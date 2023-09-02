import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/planes/lista_planes.dart';
import 'package:autistapp/planes/plan.dart';
import 'package:flutter/material.dart';

class VistaDiagramaTareas extends StatefulWidget {
  final Ajustes _ajustes;
  ListaPlanes _planes;
  VistaDiagramaTareas(
      {Key? key, required Ajustes ajustes, required ListaPlanes planes})
      : _ajustes = ajustes,
        _planes = planes,
        super(key: key);

  @override
  _VistaDiagramaTareasState createState() => _VistaDiagramaTareasState();
}

class _VistaDiagramaTareasState extends State<VistaDiagramaTareas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Planning",
            style: TextStyle(color: widget._ajustes.fgColor),
          ),
          backgroundColor: widget._ajustes.color,
          leading: BackButton(color: widget._ajustes.fgColor),
        ),
        body: GanttChart(
            ajustes: widget._ajustes, planes: widget._planes.toList()));
  }
}

class GanttChart extends StatefulWidget {
  final Ajustes ajustes;

  GanttChart({required this.planes, required this.ajustes});

  final List<Plan> planes;

  @override
  State<GanttChart> createState() => _GanttChartState();
}

class _GanttChartState extends State<GanttChart> {
  double alturaBarras = 40;

  final List<Color> coloresTipo = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple
  ];

  final int horaFin = 23;

  bool aproximarHoras(int hora, int minuto, Plan plan) {
    if (hora == horaFin) return false;
    if (plan.horaInicio < hora && plan.horaFin > hora) {
      return true;
    }
    if (plan.horaInicio == hora && plan.minInicio <= minuto) {
      return true;
    }
    if (plan.horaFin == hora && plan.minFin > minuto) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 180, right: 20),
              child: Row(
                children: [
                  for (int i = 8; i <= horaFin; i++)
                    for (int k = 0; i != horaFin ? k < 59 : k < 4; k = k + 5)
                      Container(
                        width: 15,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment
                                  .centerLeft, // Alinea a la izquierda el label de la hora
                              child: k == 0
                                  ? Text('$i',
                                      style: const TextStyle(fontSize: 11))
                                  : const Text("",
                                      style: TextStyle(fontSize: 11)),
                            ),
                            const Divider(),
                            SizedBox(
                              height: widget.planes.length * alturaBarras,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (int j = 0;
                                        j < widget.planes.length;
                                        j++)
                                      Container(
                                        height:
                                            alturaBarras, // Altura fija para cada elemento del grid
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: const BorderSide(
                                                color: Color.fromARGB(
                                                    40, 148, 148, 148)),
                                            left: BorderSide(
                                              color: k == 0
                                                  ? const Color.fromARGB(
                                                      255, 148, 148, 148)
                                                  : (k % 30 == 0)
                                                      ? Color.fromARGB(
                                                          255, 131, 132, 136)
                                                      : const Color.fromARGB(
                                                          40, 148, 148, 148),
                                            ),
                                          ),
                                          color: aproximarHoras(
                                                  i, k, widget.planes[j])
                                              ? coloresTipo[
                                                  widget.planes[j].tipo]
                                              : null,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: Container(
              width: 150,
              height: widget.planes.length * alturaBarras,
              decoration: BoxDecoration(
                color: widget.ajustes.theme == "light"
                    ? Colors.white
                    : Colors.black45,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    alignment: Alignment
                        .centerLeft, // Alinea a la izquierda el label de la hora
                    child: Text(""),
                  ),
                  const Divider(),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    for (int j = 0; j < widget.planes.length; j++)
                      Container(
                        height:
                            alturaBarras, // Altura fija para cada elemento del widget Positioned
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(widget.planes[j].nombre)),
                      ),
                  ])
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
