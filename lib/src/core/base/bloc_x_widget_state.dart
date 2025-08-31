import 'package:flutter/material.dart';

abstract class BlocXWidgetState<W extends StatefulWidget> extends State<W> {
  ThemeData get theme => Theme.of(context);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  double get width => MediaQuery.sizeOf(context).width;
  double get height => MediaQuery.sizeOf(context).height;
}
