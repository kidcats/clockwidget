// main.dart
import 'package:flutter/material.dart';
import 'package:my_app/Welcome_page.dart';
import 'package:my_app/home_page.dart';
import 'package:my_app/login_page.dart';
import 'package:provider/provider.dart';
import 'calculator_provider.dart';
import 'package:win32/win32.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 获取主显示器的尺寸
  final hMonitor = MonitorFromWindow(NULL, MONITOR_DEFAULTTOPRIMARY);
  final lpmi = calloc<MONITORINFO>()..ref.cbSize = sizeOf<MONITORINFO>();
  GetMonitorInfo(hMonitor, lpmi);

  final screenWidth = lpmi.ref.rcMonitor.right - lpmi.ref.rcMonitor.left;
  final screenHeight = lpmi.ref.rcMonitor.bottom - lpmi.ref.rcMonitor.top;

  free(lpmi);

  // 设置窗口大小和位置
  SetWindowPos(
    GetActiveWindow(),
    0,
    0,
    0,
    screenWidth,
    screenHeight,
    SWP_SHOWWINDOW,
  );

  // 移除窗口边框
  // final style = GetWindowLong(GetActiveWindow(), GWL_STYLE);
  // SetWindowLong(GetActiveWindow(), GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);

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
