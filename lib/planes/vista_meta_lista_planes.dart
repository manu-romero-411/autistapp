import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/planes/meta_lista_planes.dart';
import 'package:autistapp/planes/lista_planes.dart';
import 'package:autistapp/planes/vista_lista_planes.dart';
import 'package:autistapp/planes/vista_plan.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class VistaMetaListaPlanes extends StatefulWidget {
  final Ajustes _ajustes;

  const VistaMetaListaPlanes({super.key, required Ajustes ajustes})
      : _ajustes = ajustes;

  @override
  VistaMetaListaPlanesState createState() => VistaMetaListaPlanesState();
}

class VistaMetaListaPlanesState extends State<VistaMetaListaPlanes> {
  MetaListaPlanes? metaListaPlanes;

  List<ListaPlanes> busqueda = [];
  bool isSearch = false;

  @override
  void initState() {
    super.initState();
    metaListaPlanes = MetaListaPlanes();
    metaListaPlanes!.cargarDatos().then((_) {
      setState(() {
        busqueda = metaListaPlanes!.toList();
      });
    });
  }

  void _filtrarBusqueda(String valor) {
    setState(() {
      if (valor.isEmpty) {
        busqueda = metaListaPlanes!.toList();
      } else {
        busqueda = metaListaPlanes!
            .toList()
            .where((planlist) =>
                _operadorBusqueda(planlist, removeDiacritics(valor)))
            .toList();
      }
    });
  }

  bool _operadorBusqueda(ListaPlanes planlist, String valor) {
    if (valor.isEmpty) return true;
    if (removeDiacritics(planlist.name.toLowerCase())
        .contains(removeDiacritics(valor.toLowerCase()))) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget._ajustes.fgColor),
        backgroundColor: widget._ajustes.color,
        title: Text('Tus plannings',
            style: TextStyle(color: widget._ajustes.fgColor)),
        actions: [
          if (metaListaPlanes!.getSize() > 0)
            IconButton(
              icon: const Icon(Icons.search),
              color: widget._ajustes.fgColor,
              onPressed: () {
                setState(() {
                  isSearch = !isSearch;
                });
              },
            ),
        ],
      ),
      body: metaListaPlanes!.getSize() == 0
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "No hay planificaciones hechas.\n\nToca el botón + para crear una.",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ))
          : Column(
              children: [
                if (isSearch) const SizedBox(height: 20),
                if (isSearch)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        onChanged: (value) => _filtrarBusqueda(value),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            labelText: "Busca planificaciones...",
                            suffixIcon: const Icon(Icons.search)),
                      )),
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
                      final planlist = busqueda[reversedIndex];
                      return ListTile(
                        leading: const Icon(Icons.list_alt_rounded),
                        title: Text(planlist.name),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => VistaDiagramaTareas(
                                  nombre: planlist.name,
                                  meta: metaListaPlanes,
                                  id: planlist.id,
                                  ajustes: widget._ajustes),
                            ),
                          )
                              .then((_) {
                            metaListaPlanes!.cargarDatos().then((_) {
                              setState(() {
                                busqueda = metaListaPlanes!.toList();
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
          ListaPlanes newLista =
              ListaPlanes(id: const Uuid().v4(), name: "Nueva planificación");
          Navigator.of(context)
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
          });
        },
      ),
    );
  }
}
