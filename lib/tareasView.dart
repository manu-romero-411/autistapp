import 'dart:convert';
import 'dart:io';
import 'package:autistapp/apuntes/audio/apuntesAudio.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'common.dart';
import 'inicioView.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final file = await _localFile;
    String contents = await file.readAsString();
    Map<String, dynamic> json = jsonDecode(contents);
    List<Task> loadedTasks = [];
    for (var task in json['tasks']) {
      loadedTasks.add(Task.fromJson(task));
    }
    setState(() {
      tasks = loadedTasks;
    });
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/autistapp_tasks.json');
  }

  void _updateTask(Task task) async {
    final file = await _localFile;
    String contents = await file.readAsString();
    Map<String, dynamic> json = jsonDecode(contents);
    for (var t in json['tasks']) {
      if (t['id'] == task.id) {
        t['checked'] = task.checked ? 1 : 0;
        break;
      }
    }
    await file.writeAsString(jsonEncode(json));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index].name),
            trailing: Checkbox(
              value: tasks[index].checked,
              onChanged: (bool? value) {
                setState(() {
                  tasks[index].checked = value!;
                  _updateTask(tasks[index]);
                });
              },
            ),
            onLongPress: () {},
          );
        },
      ),
    );
  }
}

class Task {
  final int id;
  final String name;
  bool checked;

  Task({required this.id, required this.name, required this.checked});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      checked: json['checked'] == 1,
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;

  const AddTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final nameController = TextEditingController();
  String scope = 'Académico/Laboral';
  bool repeats = false;
  final intervalController = TextEditingController();
  String intervalUnit = 'días';
  final uuid = const Uuid();
  int priority = 1; // Prioridad media por defecto

  void _saveTask() {
    final name = nameController.text;
    final interval = int.tryParse(intervalController.text);
    if (name.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Por favor, introduce un nombre para la tarea',
        gravity: ToastGravity.CENTER,
      );
    } else if (repeats && (interval == null || interval < 1)) {
      Fluttertoast.showToast(
        msg: 'Por favor, introduce un intervalo de repetición válido',
        gravity: ToastGravity.CENTER,
      );
    } else {
      Navigator.pop(context, {
        'id': widget.task != null ? widget.task!['id'] : uuid.v4(),
        'name': name,
        'scope': scope,
        'repeats': repeats,
        'interval': interval,
        'intervalUnit': intervalUnit,
        'completed': 0,
        'priority': priority,
      });
    }
  }

  void _deleteTask(String id) async {
    // Carga los datos del archivo JSON
    final data = await loadDataFromJson();
    // Encuentra el índice de la tarea en la lista de tareas
    final index = data['tasks'].indexWhere((task) => task['id'] == id);
    // Elimina la tarea de la lista de tareas
    data['tasks'].removeAt(index);
    // Guarda los datos en el archivo JSON
    saveDataToJson(data);
  }

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // Inicializa los campos del formulario con los valores de la tarea que se está editando
      nameController.text = widget.task!['name'];
      scope = widget.task!['scope'];
      repeats = widget.task!['repeats'];
      intervalController.text = widget.task!['interval'].toString();
      intervalUnit = widget.task!['intervalUnit'];
      priority = widget.task!['priority'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar tarea'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteTask(widget.task!['id']);
                Navigator.pop(context, 'deleted');
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: _saveTask,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre de la tarea'),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Ámbito vital',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          DropdownButton<String>(
            value: scope,
            hint: const Text('Ámbito vital'),
            onChanged: (value) {
              setState(() {
                scope = value!;
              });
            },
            items: [
              'Académico/Laboral',
              'Vida social',
              'Vida amorosa',
              'Tareas de casa',
              'Papeleos',
              'Vida personal',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Prioridad',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => priority = 2),
                    child: const Text('Alta'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => priority == 2 ? Colors.red : Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => priority = 1),
                    child: const Text('Media'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) =>
                              priority == 1 ? Colors.orange : Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => priority = 0),
                    child: const Text('Baja'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) =>
                              priority == 0 ? Colors.green : Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CheckboxListTile(
            title: const Text('¿Se repite?'),
            value: repeats,
            onChanged: (value) {
              setState(() {
                repeats = value!;
              });
            },
          ),
          if (repeats)
            Row(
              children: [
                const Text('Cada'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: intervalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Intervalo de repetición'),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: intervalUnit,
                  hint: const Text('Unidad de tiempo'),
                  onChanged: (value) {
                    setState(() {
                      intervalUnit = value!;
                    });
                  },
                  items: ['días', 'semanas', 'meses']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
