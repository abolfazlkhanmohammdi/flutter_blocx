import 'package:flutter/material.dart';

abstract class BlocxStatelessWidget extends StatelessWidget {
  const BlocxStatelessWidget({super.key});

  ThemeData theme(BuildContext context) => Theme.of(context);
  TextTheme textTheme(BuildContext context) => theme(context).textTheme;
  ColorScheme colorScheme(BuildContext context) => theme(context).colorScheme;
  double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  double height(BuildContext context) => MediaQuery.sizeOf(context).height;
}
