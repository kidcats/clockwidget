// main.dart
import 'package:flutter/material.dart';
import 'package:my_app/Welcome_page.dart';
import 'package:my_app/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'calculator_provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CalculatorProvider(),
      child: const MyApp(),
    ),
  );
  // debugPaintSizeEnabled = true;  // 开启布局边界显示
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thermal Relay Calculator',
      home: HomePage(),
      // home: WelcomePage(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true, // Set centerTitle to true
        ),
      ),
    );
  }
}