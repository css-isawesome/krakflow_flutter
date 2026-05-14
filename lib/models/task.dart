import 'main.dart';

class Task {
  // definicja nowej klasy
  final String title; // tytul zadania
  final String deadline; // informacja o terminie
  bool done;
  final String priority;

  // final - po utworzeniu obiektu wartosc nie bedzie zmieniana
  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });

// required - parametr musi zostac przekazany przy tworzeniu obiektu
}