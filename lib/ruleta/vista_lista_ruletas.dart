import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/ruleta/lista_ruletas.dart';
import 'package:autistapp/ruleta/ruleta.dart';
import 'package:autistapp/ruleta/vista_ruleta.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class VistaListaRuletas extends StatefulWidget {
  final Ajustes _ajustes;

  const VistaListaRuletas({super.key, required Ajustes ajustes})
      : _ajustes = ajustes;

  @override
  VistaListaRuletasState createState() => VistaListaRuletasState();
}

class VistaListaRuletasState extends State<VistaListaRuletas> {
  ListaRuletas? listaRuletas;

  List<Ruleta> busqueda = [];
  bool isSearch = false;

  @override
  void initState() {
    super.initState();
    listaRuletas = ListaRuletas();
    listaRuletas!.cargarDatos().then((_) {
      setState(() {
        busqueda = listaRuletas!.toList();
      });
    });
  }

  void _filtrarBusqueda(String valor) {
    setState(() {
      if (valor.isEmpty) {
        busqueda = listaRuletas!.toList();
      } else {
        busqueda = listaRuletas!
            .toList()
            .where(
                (ruleta) => _operadorBusqueda(ruleta, removeDiacritics(valor)))
            .toList();
      }
    });
  }

  bool _operadorBusqueda(Ruleta ruleta, String valor) {
    if (valor.isEmpty) return true;
    if (removeDiacritics(ruleta.name.toLowerCase())
        .contains(removeDiacritics(valor.toLowerCase()))) return true;

    return false;
  }

  void _cambiarNombreRuleta(Ruleta rul, String nombre) {
    setState(() {
      rul.name = nombre;
      listaRuletas!.guardarDatos();
    });
  }

  void _eliminarRuleta(Ruleta rul) {
    listaRuletas!.eliminarTarea(rul.id).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget._ajustes.fgColor),
        backgroundColor: widget._ajustes.color,
        title: Text('Tus ruletas de decisiones',
            style: TextStyle(color: widget._ajustes.fgColor)),
        actions: [
          if (listaRuletas!.getSize() > 0)
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
      body: listaRuletas!.getSize() == 0
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "No hay ruletas hechas.\n\nToca el botón + para crear una.",
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
                            labelText: "Busca ruletas...",
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
                      final ruleta = busqueda[reversedIndex];
                      return ListTile(
                        leading: const Icon(Icons.incomplete_circle),
                        title: Text(ruleta.name),
                        subtitle: Text(
                            "Fecha de creación: ${DateFormat("yyyy/MM/dd - EEEE - hh:mm:ss", "es_ES").format(ruleta.fecha)}"),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => VistaRuleta(
                                  ajustes: widget._ajustes,
                                  ruleta: ruleta,
                                  onCambiarTitulo: _cambiarNombreRuleta,
                                  onDeleteRuleta: _eliminarRuleta),
                            ),
                          )
                              .then((_) {
                            listaRuletas!.cargarDatos().then((_) {
                              setState(() {
                                busqueda = listaRuletas!.toList();
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
          Ruleta newRuleta = Ruleta(
              id: const Uuid().v4(),
              name: "Nueva ruleta",
              fecha: DateTime.now());
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => VistaRuleta(
                  ajustes: widget._ajustes,
                  ruleta: newRuleta,
                  onCambiarTitulo: _cambiarNombreRuleta,
                  onDeleteRuleta: null),
            ),
          )
              .then((_) {
            listaRuletas!
                .agregarTarea(newRuleta.id, newRuleta.name, DateTime.now());
            listaRuletas!.cargarDatos().then((_) {
              setState(() {
                busqueda = listaRuletas!.toList();
              });
            });
          });
        },
      ),
    );
  }
}
