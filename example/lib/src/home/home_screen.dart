import 'package:flutter/material.dart';
import 'package:flutter_blocx_example/src/list/users/ui/users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(padding: EdgeInsets.all(8), children: [listItem(context, "users")]),
    );
  }

  Widget listItem(BuildContext context, String title) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => UsersScreen())),
      child: SizedBox(
        height: 160,
        child: Card(
          shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(8)),

          child: Center(child: Text(title)),
        ),
      ),
    );
  }
}
