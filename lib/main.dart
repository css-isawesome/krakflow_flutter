import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp( // glowna aplikacja
      home: Scaffold( // scaffold to podsatwowy layout ekranu
        appBar: AppBar( // pasek gorny
          title: Text("KrakFlow"), // glowna zawartosc ekranu
        ),
        body: Center(
          child: Column(
            children: [
              Text("Krakflow"),
              Text("Organizacja studiów"),
              Text("Dzieisjsze zadania"),
            ],
          ),
        )
      )
    );
  }
}