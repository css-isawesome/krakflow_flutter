import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
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
  // List<Task> tasks = [
  //   Task(title: "Projekt Flutter", deadline: "jutro"),
  //   Task(title: "Cwiczenia z matematyki", deadline: "dzisiaj"),
  //   Task(title: "Przeczytac o widgetach", deadline: "w tym tygodniu")
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar( // pasek gorny
          title: Text("KrakFlow"), // glowna zawartosc ekranu
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Masz dzis ${TaskRepository.tasks.length} zadania"),
              SizedBox(height: 16),
              Text("Dzisiejsze zadania"),
              Expanded(
                child: // poniewaz list view znajduje sie wewnatrz Column, trzeba uzyc expanded
                ListView.builder(
                  itemCount: TaskRepository.tasks.length,
                  itemBuilder: (context, index) {
                    // return Text("${tasks[index].done ? Icons.check_circle : Icons.radio_button_unchecked} ${tasks[index].title}\n ${tasks[index].deadline}");
                    return TaskCard(title: TaskRepository.tasks[index].title,
                        subtitle: "termin: ${TaskRepository.tasks[index]
                            .deadline} | priorytet: ${TaskRepository.tasks[index].priority}",
                        icon: TaskRepository.tasks[index].done ? Icons.check_circle : Icons
                            .radio_button_unchecked);
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
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => AddTaskScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  final offsetAnimation = Tween<Offset>(
                    begin: Offset(1.0,0.0),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                      position: offsetAnimation,
                  child: child,
                  );
                }
              ),
            );
            if (newTask != null) {
              setState(() {
                TaskRepository.tasks.add(newTask);
              });
            }
          },
          child: Icon(Icons.add),
        ),
      );
  }
}

class Task {
  // definicja nowej klasy
  final String title; // tytul zadania
  final String deadline; // informacja o terminie
  final bool done;
  final String priority;

  // final - po utworzeniu obiektu wartosc nie bedzie zmieniana
  Task(
      {required this.title, required this.deadline, required this.done, required this.priority});
// required - parametr musi zostac przekazany przy tworzeniu obiektu
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
        )
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
      appBar: AppBar(
        title: Text("KrakFlow"),
      ),
      body: Center(
        child: Text("Lista zadan"),
      ),
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
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
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
                    title: titleController.text,
                    deadline: deadlineController.text,
                    done: false,
                    priority: priorityController.text
                );
                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            )
          ],
        ),
      ),
    );
  }
}

