import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '/models/task.dart';
import '/services/task_sync_service.dart';
import '/services/task_local_database.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // inicjalizacja
  await Hive.openBox("tasks"); // otwarcie kontenera

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrakFlow',
      home: const MainTaskListScreen(), // Przenosimy logikę tutaj
    );
  }
}

class MainTaskListScreen extends StatefulWidget {
  const MainTaskListScreen({super.key});

  @override
  State<MainTaskListScreen> createState() => _MainTaskListScreenState();
}

class _MainTaskListScreenState extends State<MainTaskListScreen> {
  late Future<List<Task>> tasksFuture;
  List<Task>? allTasks;
  String selectedFilter = "wszystkie";

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  Future<List<Task>> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    return TaskLocalDatabase.getTasks();
  }

  Future<void> addTask(Task task) async {
    await TaskLocalDatabase.addTask(task);
    await loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: (allTasks == null || allTasks!.isEmpty)
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Potwierdzenie"),
                        content: const Text(
                          "Czy na pewno chcesz usunąć wszystkie zadania?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Anuluj"),
                          ),
                          TextButton(
                            onPressed: () async{
                              await TaskLocalDatabase.deleteAllTasks();
                              setState(() {
                                tasksFuture = loadTasks();
                              });
                              // Navigator.pop(context); // Don't use 'BuildContext's across async gaps.
                            },
                            child: const Text("Usuń"),
                          ),
                        ],
                      ),
                    );
                  },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Masz ${allTasks?.length ?? 0} zadań"),
            const SizedBox(height: 8),
            Row(
              children: [
                filterButton("Wszystkie", "wszystkie"),
                filterButton("Do zrobienia", "do zrobienia"),
                filterButton("Wykonane", "wykonane"),
              ],
            ),
            const Text(
              "Dzisiejsze zadania",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      allTasks == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Błąd: ${snapshot.error}"));
                  }

                  allTasks ??= snapshot.data ?? [];

                  final filteredTasks = allTasks!.where((task) {
                    if (selectedFilter == "wykonane") return task.done;
                    if (selectedFilter == "do zrobienia") return !task.done;
                    return true;
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return const Center(
                      child: Text("Brak zadań w tej kategorii"),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Dismissible(
                        key: ObjectKey(task),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async{
                          await TaskLocalDatabase.deleteTask(index);
                          setState(() {
                            tasksFuture = loadTasks();
                          });
                        },
                        child: TaskCard(
                          title: task.title,
                          subtitle:
                              "termin: ${task.deadline} | priorytet: ${task.priority}",
                          done: task.done,
                          onChanged: (value) async {
                            final updatedTask = Task(
                              id: task.id,
                              title: task.title,
                              deadline: task.deadline,
                              priority: task.priority,
                              done: value ?? false,
                            );

                            await TaskLocalDatabase.updateTask(updatedTask);

                            setState(() {
                              tasksFuture = loadTasks();
                            });
                          },
                          onTap: () async {
                            final Task? updatedTask = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditTaskScreen(task: task),
                              ),
                            );
                            if (updatedTask != null) {
                              await TaskLocalDatabase.updateTask(updatedTask);
                              setState(() {
                                tasksFuture = loadTasks();
                              });
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (newTask != null) {
            setState(() {
              allTasks?.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget filterButton(String label, String value) {
    return TextButton(
      onPressed: () => setState(() => selectedFilter = value),
      child: Text(label),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: done, onChanged: onChanged),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("KrakFlow")),
      body: Center(child: Text("Lista zadan")),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nowe zadanie")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Deadline",
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  id: Random().nextInt(1000000),
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: priorityController.text,
                );
                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final Task task;

  late TextEditingController titleController;
  late TextEditingController deadlineController;
  late TextEditingController priorityController;

  EditTaskScreen({super.key, required this.task}) {
    titleController = TextEditingController(text: task.title);
    deadlineController = TextEditingController(text: task.deadline);
    priorityController = TextEditingController(text: task.priority);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nowe zadanie")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Deadline",
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  id: Random().nextInt(1000000),
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: priorityController.text,
                );
                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}
