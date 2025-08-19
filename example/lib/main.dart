import 'package:flutter/material.dart';
import 'package:flutter_blocx_example/src/home/screen_home.dart';
import 'package:flutter_blocx_example/src/list/users/ui/screen_users.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: {"users": (_) => ScreenUsers()}, home: ScreenHome());
  }
}
