// main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_app/Welcome_page.dart';
import 'package:my_app/home_page.dart';
import 'package:my_app/login_page.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'calculator_provider.dart';


void main() {

  runApp(
    ChangeNotifierProvider(
      create: (_) => CalculatorProvider(),
      child: MyApp(),
    ),
  );
  // debugPaintSizeEnabled = true;  // 开启布局边界显示
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GlobalConstraintWrapper(child: WelcomePage()),
      routes: {
        '/home': (context) => GlobalConstraintWrapper(child: HomePage()),
        '/login': (context) => GlobalConstraintWrapper(child: LoginPage()),
        '/welcome': (context) => GlobalConstraintWrapper(child: LoginPage()),
      },
    );
  }
}

class GlobalConstraintWrapper extends StatelessWidget {
  final Widget child;

  GlobalConstraintWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 1200,
              minHeight: 900,
            ),
            child: child,
          ),
        );
      },
    );
  }
}