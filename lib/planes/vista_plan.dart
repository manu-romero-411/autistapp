import 'dart:math';

import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/planes/lista_planes.dart';
import 'package:autistapp/planes/meta_lista_planes.dart';
import 'package:autistapp/planes/plan.dart';
import 'package:autistapp/planes/vista_lista_planes.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class VistaDiagramaTareas extends StatefulWidget {
  final Ajustes _ajustes;
  final String _listaId;
  String _nombre;
  final MetaListaPlanes _meta;

  VistaDiagramaTareas(
      {Key? key, required id, required ajustes, required nombre, required meta})
      : _ajustes = ajustes,
        _listaId = id,
        _meta = meta,
        _nombre = nombre,
        super(key: key);

  @override
  _VistaDiagramaTareasState createState() => _VistaDiagramaTareasState();
}

class _VistaDiagramaTareasState extends State<VistaDiagramaTareas> {
  late ListaPlanes listaPlanes;

  @override
  void initState() {
    super.initState();

    listaPlanes = ListaPlanes(id: widget._listaId, name: widget._nombre);
    listaPlanes.cargarDatos().then((_) {
      setState(() {});
    });
  }

  void actualizarNombre() {
    setState(() {
      widget._nombre = listaPlanes.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget._nombre,
            style: TextStyle(color: widget._ajustes.fgColor),
          ),
          actions: [
            IconButton(
              color: widget._ajustes.fgColor,
              icon: const Icon(Icons.delete),
              onPressed: () {
                widget._meta.eliminarTarea(widget._listaId);
                if (!context.mounted) return;

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('La nota ha sido eliminada con éxito')),
                );
              },
            ),
            IconButton(
              color: widget._ajustes.fgColor,
              icon: const Icon(Icons.share),
              onPressed: () async {
                String shareString =
                    "AutistApp - Planificación - ${widget._nombre}\n\n";
                for (int i = 0; i < listaPlanes.getSize(); ++i) {
                  shareString +=
                      "* ${listaPlanes.toList()[i].horaInicio}:${listaPlanes.toList()[i].minInicio} - ${listaPlanes.toList()[i].horaFin}:${listaPlanes.toList()[i].minFin} => ${listaPlanes.toList()[i].nombre}\n";
                }
                await Share.share(shareString);
              },
            ),
            IconButton(
              color: widget._ajustes.fgColor,
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => VistaListaPlanes(
                        meta: widget._meta,
                        listaPlanes: listaPlanes,
                        ajustes: widget._ajustes,
                        onChangeNombre: actualizarNombre),
                  ),
                )
                    .then((_) {
                  listaPlanes.cargarDatos().then((_) {
                    setState(() {});
                  });
                });
              },
            ),
          ],
          backgroundColor: widget._ajustes.color,
          leading: BackButton(color: widget._ajustes.fgColor),
        ),
        body:
            GanttChart(ajustes: widget._ajustes, planes: listaPlanes.toList()));
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

  bool aproximarHoras(int hora, int minuto, Plan plan) {
    if (hora == widget.ajustes.maxHoraGantt) return false;
    if (plan.horaInicio < hora && plan.horaFin > hora) {
      return true;
    }
    if (plan.horaInicio != plan.horaFin) {
      if (plan.horaInicio == hora && plan.minInicio <= minuto) {
        return true;
      }
      if (plan.horaFin == hora && plan.minFin > minuto) {
        return true;
      }
    } else if (plan.horaInicio == hora &&
        plan.minInicio <= minuto &&
        plan.minFin > minuto) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: [
          const SizedBox(
            height: 16,
          ),
          Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 180, right: 20),
                  child: Row(
                    children: [
                      for (int i = widget.ajustes.minHoraGantt;
                          i <= widget.ajustes.maxHoraGantt;
                          i++)
                        for (int k = 0;
                            i != widget.ajustes.maxHoraGantt ? k < 59 : k < 4;
                            k = k + 5)
                          SizedBox(
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
                                                          ? const Color
                                                              .fromARGB(255,
                                                              131, 132, 136)
                                                          : const Color
                                                              .fromARGB(40, 148,
                                                              148, 148),
                                                ),
                                              ),
                                              color: aproximarHoras(
                                                      i, k, widget.planes[j])
                                                  ? widget
                                                      .ajustes
                                                      .listaAmbitos[
                                                          widget.planes[j].tipo]
                                                      .color
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
                    physics: const NeverScrollableScrollPhysics(),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(widget.planes[j].nombre)),
                          ),
                      ])
                    ]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "Desplázate a la izquierda o derecha para visualizar el espacio horario que ocupan tus planes.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              )),
          const SizedBox(
            height: 16,
          ),
        ]));
  }
}
