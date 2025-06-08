import 'package:flutter/material.dart';

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: const Text("Gestion des Salles UNZ"),),
      body: Center(child: Text("Hello"))
    );
  }
}
