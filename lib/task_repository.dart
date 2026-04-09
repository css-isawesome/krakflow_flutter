import 'main.dart';

class TaskRepository {
  static List<Task> tasks = [
    Task(
      title: "Projekt Flutter",
      deadline: "jutro",
      done: false,
      priority: "wysoki",
    ),
    Task(
      title: "Oddac raport",
      deadline: "dzisiaj",
      done: true,
      priority: "wysoki",
    ),
    Task(
      title: "Powtorzyc widgety",
      deadline: "w piatek",
      done: false,
      priority: "sredni",
    ),
  ];
}