import 'package:autistapp/apuntes/audio/lista_notas_voz.dart';
import 'package:autistapp/apuntes/audio/nota_voz.dart';
import 'package:autistapp/apuntes/audio/vista_grabador_audio.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VistaListaNotasVoz extends StatefulWidget {
  final Ajustes _ajustes;
  const VistaListaNotasVoz({super.key, required Ajustes ajustes})
      : _ajustes = ajustes;

  @override
  VistaListaNotasVozState createState() => VistaListaNotasVozState();
}

class VistaListaNotasVozState extends State<VistaListaNotasVoz> {
  final listaNotasVoz = ListaNotasVoz();
  List<NotaVoz> busqueda = [];
  bool isSearch = false;

  @override
  void initState() {
    listaNotasVoz.cargarDatos().then((_) {
      setState(() {
        busqueda = listaNotasVoz.toList();
      });
    });
    super.initState();
  }

  void _filtrarBusqueda(String valor) {
    setState(() {
      if (valor.isEmpty) {
        busqueda = listaNotasVoz.toList();
      } else {
        busqueda = listaNotasVoz
            .toList()
            .where((nota) => _operadorBusqueda(nota, removeDiacritics(valor)))
            .toList();
      }
    });
  }

  bool _operadorBusqueda(NotaVoz nota, String valor) {
    if (removeDiacritics(nota.descripcion.toLowerCase())
        .contains(removeDiacritics(valor.toLowerCase()))) return true;
    if ((DateFormat('yyyy-MM-dd', "es_ES")
        .format(nota.fecha)
        .contains(valor))) {
      return true;
    }
    if (valor.toLowerCase().contains("acad") ||
        valor.toLowerCase().contains("laboral")) {
      if (nota.ambito == 0) return true;
    }
    if (valor.toLowerCase().contains("social")) {
      if (nota.ambito == 1) return true;
    }

    if (valor.toLowerCase().contains("personal")) {
      if (nota.ambito == 2) return true;
    }
    return false;
  }

  void actualizarLista() {
    setState(() {
      listaNotasVoz.cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget._ajustes.fgColor),
        backgroundColor: widget._ajustes.color,
        title: Text(
          'Tus notas de voz',
          style: TextStyle(color: widget._ajustes.fgColor),
        ),
        actions: [
          if (listaNotasVoz.getSize() > 0)
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
      body: listaNotasVoz.getSize() == 0
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "No hay notas de voz tomadas.\n\nToca el botón + para crear una.",
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
                      final nota = busqueda[reversedIndex];
                      return ListTile(
                        leading: const Icon(Icons.mic),
                        trailing: widget._ajustes.getIconoAmbito(nota.ambito),
                        title: Text(nota.descripcion),
                        subtitle: Text(
                            DateFormat('yyyy-MM-dd - EEEE - HH:mm:ss', "es_ES")
                                .format(nota.fecha)),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => GrabadorAudio(
                                ajustes: widget._ajustes,
                                nota: nota,
                                listaNotasVoz: listaNotasVoz,
                                onUpdateLista: actualizarLista,
                              ),
                            ),
                          )
                              .then((_) {
                            listaNotasVoz.cargarDatos().then((_) {
                              setState(() {
                                busqueda = listaNotasVoz.toList();
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
              builder: (context) => GrabadorAudio(
                  ajustes: widget._ajustes,
                  listaNotasVoz: listaNotasVoz,
                  onUpdateLista: actualizarLista),
            ),
          )
              .then((_) {
            listaNotasVoz.cargarDatos().then((_) {
              setState(() {
                busqueda = listaNotasVoz.toList();
              });
            });
          });
        },
      ),
    );
  }
}
