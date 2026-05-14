class Task {
  // definicja nowej klasy
  final int id;
  final String title; // tytul zadania
  final String deadline; // informacja o terminie
  bool done;
  final String priority;

  // final - po utworzeniu obiektu wartosc nie bedzie zmieniana
  Task({
    required this.id,
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });

// required - parametr musi zostac przekazany przy tworzeniu obiektu
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "deadline": deadline,
      "priority": priority,
      "done": done,
    };
  }

  factory Task.fromMap(Map map) {
    return Task(
      id: map["id"],
      title: map["title"],
      deadline: map["deadline"],
      priority: map["priority"],
      done: map["done"],
    );
  }
}

