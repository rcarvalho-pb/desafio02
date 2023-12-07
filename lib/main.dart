import 'package:epub_kitty_example/app/pages/home/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desafio',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
