import 'package:flutter/material.dart';
import 'bolas.dart';
import 'bolas.dart'; // Importe a tela de jogo

void main() {
  runApp(MyApp()); // Inicializa o aplicativo
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: JogoScreen(), // Define a tela de jogo como a tela principal
      debugShowCheckedModeBanner: false,
    );
  }
}