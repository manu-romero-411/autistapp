import 'package:autistapp/apuntes/texto/vista_editor_texto.dart';
import 'package:autistapp/apuntes/texto/lista_notas_texto.dart';
import 'package:autistapp/apuntes/texto/nota_texto.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diacritic/diacritic.dart';

class VistaNotasTexto extends StatefulWidget {
  final Ajustes _ajustes;

  const VistaNotasTexto({super.key, required Ajustes ajustes})
      : _ajustes = ajustes;

  @override
  _VistaNotasTextoState createState() => _VistaNotasTextoState();
}

class _VistaNotasTextoState extends State<VistaNotasTexto> {
  final listaNotasTexto = ListaNotasTexto();
  List<NotaTexto> busqueda = [];
  bool isSearch = false;

  @override
  void initState() {
    super.initState();
    listaNotasTexto.cargarDatos().then((_) {
      setState(() {
        busqueda = listaNotasTexto.toList();
      });
    });
  }

  void _filtrarBusqueda(String valor) {
    setState(() {
      if (valor.isEmpty) {
        busqueda = listaNotasTexto.toList();
      } else {
        busqueda = listaNotasTexto
            .toList()
            .where((nota) => _operadorBusqueda(nota, removeDiacritics(valor)))
            .toList();
      }
    });
  }

  bool _operadorBusqueda(NotaTexto nota, String valor) {
    if (valor == "") return true;
    if (removeDiacritics(nota.titulo.toLowerCase()).contains(valor))
      return true;
    //if (nota.texto.toLowerCase().contains(valor)) return true;
    if ((DateFormat('yyyy-MM-dd', "es_ES").format(nota.fecha).contains(valor)))
      return true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget._ajustes.fgColor),
        backgroundColor: widget._ajustes.color,
        title: Text('Tus notas de texto',
            style: TextStyle(color: widget._ajustes.fgColor)),
        actions: [
          if (listaNotasTexto.getSize() > 0)
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
      body: listaNotasTexto.getSize() == 0
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "No hay notas de texto tomadas.\n\nToca el botón + para crear una.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22),
                ),
              ),
            )
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
                        leading: const Icon(Icons.note_alt),
                        trailing: widget._ajustes.getIconoAmbito(nota.ambito),
                        title: Text(nota.titulo),
                        subtitle: Text(
                            DateFormat('yyyy-MM-dd - EEEE - HH:mm:ss', "es_ES")
                                .format(nota.fecha)),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => EditorNotas(
                                  nota: nota, ajustes: widget._ajustes),
                            ),
                          )
                              .then((_) {
                            listaNotasTexto.cargarDatos().then((_) {
                              setState(() {
                                busqueda = listaNotasTexto.toList();
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
        backgroundColor: widget._ajustes.color,
        foregroundColor: widget._ajustes.fgColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => EditorNotas(ajustes: widget._ajustes),
            ),
          )
              .then((_) {
            listaNotasTexto.cargarDatos().then((_) {
              setState(() {
                busqueda = listaNotasTexto.toList();
              });
            });
          });
        },
      ),
    );
  }
}
