import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx_example/src/home/home_screen.dart';
import 'package:flutter_blocx_example/src/list/users/ui/users_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
      ),
      home: HomeScreen(),
    );
  }
}
