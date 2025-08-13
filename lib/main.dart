import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Hive.openBox('tasks');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Todo Plus',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
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

  void _addTask(Map<String, dynamic> task) {
    taskBox.add(task);
  }

  void _showTaskForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskForm(onSave: _addTask)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mes tâches")),
      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(child: Text("Aucune tâche"));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final task = box.getAt(index);
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: task['iconPath'] != null
                      ? CircleAvatar(backgroundImage: FileImage(File(task['iconPath'])))
                      : Text(task['emoji'] ?? "📝", style: TextStyle(fontSize: 24)),
                  title: Text(task['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${task['description'] ?? ''}\n${task['startTime']} - ${task['endTime']}"),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTaskForm,
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  TaskForm({required this.onSave});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _startTime;
  String? _endTime;
  String? _emoji;
  String? _iconPath;

  Future<void> _pickTime(bool isStart) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time.format(context);
        } else {
          _endTime = time.format(context);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _iconPath = picked.path;
        _emoji = null;
      });
    }
  }

  void _pickEmoji() {
    showModalBottomSheet(
      context: context,
      builder: (_) => EmojiPicker(
        onEmojiSelected: (category, emoji) {
          setState(() {
            _emoji = emoji.emoji;
            _iconPath = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.isEmpty || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Remplis les champs obligatoires")));
      return;
    }
    widget.onSave({
      'title': _titleController.text,
      'description': _descController.text,
      'startTime': _startTime,
      'endTime': _endTime,
      'emoji': _emoji,
      'iconPath': _iconPath,
      'done': false,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nouvelle tâche")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: "Titre *")),
            TextField(controller: _descController, decoration: InputDecoration(labelText: "Description")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Début: ${_startTime ?? "--:--"}"),
                TextButton(onPressed: () => _pickTime(true), child: Text("Choisir"))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Fin: ${_endTime ?? "--:--"}"),
                TextButton(onPressed: () => _pickTime(false), child: Text("Choisir"))
              ],
            ),
            Row(
              children: [
                ElevatedButton(onPressed: _pickEmoji, child: Text("Emoji")),
                SizedBox(width: 10),
                ElevatedButton(onPressed: _pickImage, child: Text("Image"))
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveTask, child: Text("Enregistrer"))
          ],
        ),
      ),
    );
  }
}
