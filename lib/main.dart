import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Hive.openBox('tasks');
  runApp(MyPlannerApp());
}

class MyPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do & Planning',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final taskBox = Hive.box('tasks');
  int _selectedIndex = 0;

  void _addTask(String task) {
    taskBox.add({'title': task, 'done': false, 'date': DateTime.now().toString()});
    setState(() {});
  }

  void _toggleTask(int index) {
    final task = taskBox.getAt(index);
    taskBox.putAt(index, {
      'title': task['title'],
      'done': !task['done'],
      'date': task['date']
    });
    setState(() {});
  }

  void _deleteTask(int index) {
    taskBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTodoList(),
      _buildPlanningView(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('To-Do & Planning')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'To-Do'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Planning'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _showAddTaskDialog(),
            )
          : null,
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: taskBox.length,
      itemBuilder: (context, index) {
        final task = taskBox.getAt(index);
        return ListTile(
          leading: Checkbox(
            value: task['done'],
            onChanged: (_) => _toggleTask(index),
          ),
          title: Text(
            task['title'],
            style: TextStyle(
              decoration: task['done'] ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteTask(index),
          ),
        );
      },
    );
  }

  Widget _buildPlanningView() {
    return ListView.builder(
      itemCount: taskBox.length,
      itemBuilder: (context, index) {
        final task = taskBox.getAt(index);
        final date = DateTime.parse(task['date']);
        return ListTile(
          title: Text(task['title']),
          subtitle: Text('${date.day}/${date.month}/${date.year}'),
        );
      },
    );
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle tâche'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Titre de la tâche'),
        ),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Ajouter'),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addTask(controller.text);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
