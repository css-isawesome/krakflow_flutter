import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // List<Task> tasks = [
  //   Task(title: "Projekt Flutter", deadline: "jutro"),
  //   Task(title: "Cwiczenia z matematyki", deadline: "dzisiaj"),
  //   Task(title: "Przeczytac o widgetach", deadline: "w tym tygodniu")
  // ];

  final List<Task> tasks = [
    Task(title: "Analiza danych", deadline: "jutro", done: true, priority: "wysoki"),
    Task(title: "Witryny internetowe", deadline: "w przyszlym tygodniu", done: false, priority: "sredni"),
    Task(title: "Zadanie z Fluttera", deadline: "dzisiaj", done: true, priority: "niski"),
    Task(title: "Rownania rozniczkowe", deadline: "jutro", done: false, priority: "sredni")
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // glowna aplikacja
      home: Scaffold( // scaffold to podsatwowy layout ekranu
        appBar: AppBar( // pasek gorny
          title: Text("KrakFlow"), // glowna zawartosc ekranu
        ),
        body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text("Masz dzis ${tasks.length} zadania"),
              SizedBox(height: 16),
              Text("Dzisiejsze zadania"),
              Expanded(child: // poniewaz list view znajduje sie wewnatrz Column, trzeba uzyc expanded
              ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  // return Text("${tasks[index].done ? Icons.check_circle : Icons.radio_button_unchecked} ${tasks[index].title}\n ${tasks[index].deadline}");
                  return TaskCard(title: tasks[index].title, subtitle: "termin: ${tasks[index].deadline} | priorytet: ${tasks[index].priority}", icon: tasks[index].done ? Icons.check_circle : Icons.radio_button_unchecked);
              },
            ),
              ),
              ],
            ),
      ),
    ),
    );
  }
}



class Task { // definicja nowej klasy
  final String title; // tytul zadania
  final String deadline; // informacja o terminie
  final bool done;
  final String priority;
  // final - po utworzeniu obiektu wartosc nie bedzie zmieniana
  Task({required this.title, required this.deadline, required this.done, required this.priority});
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

