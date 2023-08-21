import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MyWidget extends StatefulWidget {
  const MyWidget();
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Map<String, dynamic> data = {
    'checkedItems': {},
    'tasks': [],
  };

  bool editing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final file = await _getFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      setState(() {
        data = jsonDecode(contents);
      });
    }
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  Future<void> _saveData() async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }

  void _addTask(Map<String, dynamic> task) {
    setState(() {
      data['tasks'] = data['tasks'] ?? [];
      data['tasks'].add(task);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkedItems = data['checkedItems'] ?? {};
    final tasks = data['tasks'] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text('autistApp'),
        actions: [
          IconButton(
            icon: Icon(editing ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                editing = !editing;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          if (task['completed'] == 1) {
            return SizedBox.shrink();
          }
          return editing
              ? ListTile(
                  title: Text(task['name']),
                  subtitle: Text('${task['scope']} - Próxima vez: ...'),
                  leading: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Editar tarea
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Eliminar tarea
                    },
                  ),
                )
              : CheckboxListTile(
                  title: Text(task['name']),
                  subtitle: Text('${task['scope']} - Próxima vez: ...'),
                  value: task['completed'] == 1,
                  onChanged: (checked) {
                    setState(() {
                      task['completed'] = checked == true ? 1 : 0;
                      _saveData();
                    });
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (result != null) {
            _addTask(result);
          }
        },
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final nameController = TextEditingController();
  String scope = 'Académico/Laboral';
  bool repeats = false;
  final intervalController = TextEditingController();
  String intervalUnit = 'días';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar tarea'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              final name = nameController.text;
              final interval = int.tryParse(intervalController.text) ?? -1;
              if (name.isNotEmpty &&
                  scope != null &&
                  (!repeats || (interval > -1 && intervalUnit != null))) {
                Navigator.pop(context, {
                  'name': name,
                  'scope': scope,
                  'repeats': repeats,
                  'interval': interval,
                  'intervalUnit': intervalUnit,
                  'completed': 0,
                });
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nombre de la tarea'),
          ),
          DropdownButton<String>(
            value: scope,
            hint: Text('Ámbito vital'),
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
          CheckboxListTile(
            title: Text('¿Se repite?'),
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
                Text('Cada'),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: intervalController,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: 'Intervalo de repetición'),
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: intervalUnit,
                  hint: Text('Unidad de tiempo'),
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
