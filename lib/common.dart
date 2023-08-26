import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'tarea.dart';

Future<Map<String, dynamic>> loadDataFromJson() async {
  // Define la ruta del archivo JSON
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/autistapp_tasks.json');

  // Verifica si el archivo existe
  if (await file.exists()) {
    // Lee el contenido del archivo como una cadena
    final contents = await file.readAsString();
    // Decodifica la cadena como un objeto JSON y devuelve el resultado
    return jsonDecode(contents);
  } else {
    // Si el archivo no existe, devuelve un objeto vacío
    return {};
  }
}

Future<void> saveDataToJson(Map<String, dynamic> data) async {
  // Define la ruta del archivo JSON
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/data.json');
  // Codifica el objeto `data` como una cadena JSON
  final contents = jsonEncode(data);
  // Escribe la cadena en el archivo
  await file.writeAsString(contents);
}

ListaTareas tareasList = ListaTareas();
