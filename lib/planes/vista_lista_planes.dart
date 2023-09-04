import 'dart:math';

import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/planes/meta_lista_planes.dart';
import 'package:autistapp/planes/plan.dart';
import 'package:autistapp/planes/lista_planes.dart';
import 'package:autistapp/planes/vista_editor_planes.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';

class VistaListaPlanes extends StatefulWidget {
  final Ajustes _ajustes;
  final ListaPlanes _listaPlanes;
  final MetaListaPlanes _meta;
  final Function() _onChangeNombre;

  const VistaListaPlanes(
      {super.key,
      required ListaPlanes listaPlanes,
      required meta,
      required Ajustes ajustes,
      required onChangeNombre})
      : _ajustes = ajustes,
        _listaPlanes = listaPlanes,
        _meta = meta,
        _onChangeNombre = onChangeNombre;

  @override
  _VistaListaPlanesState createState() => _VistaListaPlanesState();
}

class _VistaListaPlanesState extends State<VistaListaPlanes> {
  List<Plan> busqueda = [];
  bool isSearch = false;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget._listaPlanes.name);

    widget._listaPlanes.cargarDatos().then((_) {
      setState(() {
        busqueda = widget._listaPlanes.toList();
      });
    });
  }

  void _filtrarBusqueda(String valor) {
    setState(() {
      if (valor.isEmpty) {
        busqueda = widget._listaPlanes.toList();
      } else {
        busqueda = widget._listaPlanes
            .toList()
            .where((nota) => _operadorBusqueda(nota, removeDiacritics(valor)))
            .toList();
      }
    });
  }

  bool _operadorBusqueda(Plan nota, String valor) {
    if (valor == "") return true;
    if (removeDiacritics(nota.nombre.toLowerCase()).contains(valor))
      return true;
    //if (nota.texto.toLowerCase().contains(valor)) return true;

    return false;
  }

  void actualizarListaPlanes() {
    setState(() {
      widget._listaPlanes.cargarDatos();
    });
  }

  void guardarSalir() {
    widget._listaPlanes.name = _descController.text;
    widget._meta.agregarTarea(widget._listaPlanes.id, _descController.text);
    widget._onChangeNombre();
    setState(() {});
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambios guardados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: widget._ajustes.fgColor,
        ),
        backgroundColor: widget._ajustes.color,
        title: Text('Editar planning...',
            style: TextStyle(color: widget._ajustes.fgColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: widget._ajustes.fgColor,
            onPressed: () {
              setState(() {
                isSearch = !isSearch;
              });
            },
          ),
          IconButton(
            color: widget._ajustes.fgColor,
            icon: const Icon(Icons.save),
            onPressed: guardarSalir,
          ),
        ],
      ),
      body: widget._listaPlanes.getSize() == 0
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "No hay planes hechos.\n\nToca el botón + para crear uno.",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ))
          : Column(
              children: [
                const SizedBox(
                  height: 24,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _descController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        labelText: 'Nombre',
                      ),
                    )),
                if (isSearch)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        onChanged: (value) => _filtrarBusqueda(value),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            labelText: "Busca planes...",
                            suffixIcon: const Icon(Icons.search)),
                      )),
                const SizedBox(
                  height: 16,
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: busqueda.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = busqueda.length - 1 - index;
                      final plan = busqueda[reversedIndex];
                      return ListTile(
                        leading: Transform.rotate(
                          angle: pi * 3 / 2,
                          child: Icon(Icons.waterfall_chart,
                              color: widget
                                  ._ajustes.listaAmbitos[plan.tipo].color),
                        ),
                        trailing:
                            Icon(widget._ajustes.listaAmbitos[plan.tipo].icono),
                        title: Text(plan.nombre),
                        subtitle: Text(
                            "${plan.horaInicio}:${plan.minInicio} - ${plan.horaFin}:${plan.minFin}"),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => EditorPlanes(
                                  plan: plan,
                                  ajustes: widget._ajustes,
                                  listaPlanes: widget._listaPlanes,
                                  onChangePlanes: actualizarListaPlanes),
                            ),
                          )
                              .then((_) {
                            widget._listaPlanes.cargarDatos().then((_) {
                              setState(() {
                                busqueda = widget._listaPlanes.toList();
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
        backgroundColor: widget._ajustes.color,
        foregroundColor: widget._ajustes.fgColor,
        heroTag: "btn3",
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => EditorPlanes(
                ajustes: widget._ajustes,
                listaPlanes: widget._listaPlanes,
                onChangePlanes: actualizarListaPlanes,
              ),
            ),
          )
              .then((_) {
            widget._listaPlanes.cargarDatos().then((_) {
              setState(() {
                busqueda = widget._listaPlanes.toList();
              });
            });
          });
        },
      ),
    );
  }
}
