import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todofast/tools.dart';
import 'package:todofast/models.dart';
import 'package:intl/intl.dart';

void main() => runApp(TodoFastApp());

class TodoFastApp extends StatelessWidget {
  const TodoFastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TodoFast',
      debugShowCheckedModeBanner: false,
      home: TodoFastHome(),
    );
  }
}

class TodoFastHome extends StatefulWidget {
  const TodoFastHome({super.key});

  @override
  _TodoFastHomeState createState() => _TodoFastHomeState();
}

class _TodoFastHomeState extends State<TodoFastHome> {
  final TextEditingController _taskController = TextEditingController();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJson = prefs.getString('tasks');
    if (taskJson != null) {
      final decoded = json.decode(taskJson) as List;
      setState(() {
        _tasks = decoded.map((t) => Task.fromJson(t)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', encoded);
  }

  void _addTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    final selectedEmoji = await _pickEmoji();
    if (selectedEmoji == null) return;

    setState(() {
      _tasks.add(Task(
        title: capitalize(text),
        icon: selectedEmoji,
      ));
      _taskController.clear();
    });
    _saveTasks();
  }

  Future<String?> _pickEmoji() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        final emojis = ['📝', '📌', '✅', '🔥', '🚀', '🎯', '💡', '🧹'];
        return AlertDialog(
          title: Text('Choisis un emoji pour la tâche'),
          content: Wrap(
            spacing: 10,
            children: emojis.map((emoji) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(emoji),
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 28),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _toggleTask(int index, bool? value) {
    setState(() {
      _tasks[index].done = value ?? false;
    });
    _saveTasks();
  }

  void _deleteCompletedTasks() {
    setState(() {
      _tasks = _tasks.where((task) => !task.done).toList();
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TodoFast')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(hintText: 'Nouvelle tâche'),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Ajouter'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Liste de taches
            Expanded(
              child: _tasks.isEmpty
                  ? Center(child: Text('Aucune tâche'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        final formattedDate =
                            DateFormat('dd/MM/yyyy').format(task.dateAdded);

                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Row(
                            children: [
                              Text(task.icon, style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.done
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          value: task.done,
                          onChanged: (value) => _toggleTask(index, value),
                        );
                      }),
            ),
            if (_tasks.any((task) => task.done))
              ElevatedButton.icon(
                onPressed: _deleteCompletedTasks,
                icon: Icon(Icons.delete),
                label: Text('Supprimer tâches terminées'),
                style: ElevatedButton.styleFrom(),
              ),
          ],
        ),
      ),
    );
  }
}
