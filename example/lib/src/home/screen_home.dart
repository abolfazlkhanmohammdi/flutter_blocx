import 'package:flutter/material.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(padding: EdgeInsets.all(8), children: [listItem(context, "users")]),
    );
  }

  Widget listItem(BuildContext context, String title) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(title),
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
