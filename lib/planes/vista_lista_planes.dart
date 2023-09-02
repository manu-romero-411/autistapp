import 'dart:convert';
import 'dart:io';
import 'package:autistapp/apuntes/texto/apuntes_texto.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/planes/lista_planes.dart';
import 'package:autistapp/planes/vista_plan.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class MetaListaPlanes {
  List<ListaPlanes> _planes = [];

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_plans_all.json');
  }

  List<ListaPlanes> toList() {
    return _planes;
  }

  int getSize() {
    return _planes.length;
  }

  Future<void> cargarDatos() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      _planes = List<ListaPlanes>.from(data['planLists'].map((x) => ListaPlanes(
            id: x['id'],
          )));
      for (int i = 0; i < _planes.length; ++i) {
        _planes[i].cargarDatos();
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<File> guardarDatos() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode({
      'planLists': List<dynamic>.from(_planes.map((x) => {
            'id': x.id,
          })),
    }));
  }

  void agregarListaPlanes(String uuid) {
    try {
      ListaPlanes tareaExistente =
          _planes.firstWhere((tarea) => tarea.id == uuid);
      tareaExistente.id;
    } catch (e) {
      _planes.add(ListaPlanes(
        id: uuid,
      ));
      for (int i = 0; i < _planes.length; ++i) {
        _planes[i].cargarDatos();
        _planes[i].guardarDatos();
      }
    }
    guardarDatos();
  }

  void eliminarListaTareas(String id) {
    _planes.removeWhere((tareaBuscada) => tareaBuscada.id == id);
    guardarDatos();
  }
}

class VistaListaPlanes extends StatefulWidget {
  final Ajustes ajustes;
  const VistaListaPlanes({required this.ajustes});

  @override
  _VistaListaPlanesState createState() => _VistaListaPlanesState();
}

class _VistaListaPlanesState extends State<VistaListaPlanes> {
  final metaListaPlanes = MetaListaPlanes();
  List<ListaPlanes> busqueda = [];
  bool isSearch = false;

  @override
  void initState() {
    metaListaPlanes.cargarDatos().then((_) {
      setState(() {
        busqueda = metaListaPlanes.toList();
      });
    });
    super.initState();
  }

  void _filtrarBusqueda(String valor) {
    setState(() {
      if (valor.isEmpty) {
        busqueda = metaListaPlanes.toList();
      } else {
        busqueda = metaListaPlanes
            .toList()
            .where((nota) => _operadorBusqueda(nota, removeDiacritics(valor)))
            .toList();
      }
    });
  }

  bool _operadorBusqueda(ListaPlanes nota, String valor) {
    for (int i = 0; i < nota.toList().length; ++i) {
      if (removeDiacritics(nota.toList()[i].nombre.toLowerCase())
          .contains(valor)) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget.ajustes.fgColor),
        backgroundColor: widget.ajustes.color,
        title: Text(
          'Lista de notas de voz',
          style: TextStyle(color: widget.ajustes.fgColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: widget.ajustes.fgColor,
            onPressed: () {
              setState(() {
                isSearch = !isSearch;
              });
            },
          ),
        ],
      ),
      body: Column(
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
                      labelText: "Busca notas...",
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
                final lista = busqueda[reversedIndex];
                return ListTile(
                  title: Text(lista.id),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => VistaDiagramaTareas(
                            ajustes: widget.ajustes, planes: lista),
                      ),
                    )
                        .then((_) {
                      metaListaPlanes.cargarDatos().then((_) {
                        setState(() {
                          busqueda = metaListaPlanes.toList();
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
        heroTag: "btn3",
        child: const Icon(Icons.add),
        onPressed: () {
          /*
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => GrabadorAudio(ajustes: widget.ajustes),
            ),
          )
              .then((_) {
            metaListaPlanes.cargarDatos().then((_) {
              setState(() {
                busqueda = metaListaPlanes.toList();
              });
            });
          });*/
        },
      ),
    );
  }
}
