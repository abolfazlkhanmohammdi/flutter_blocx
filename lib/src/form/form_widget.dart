import 'package:flutter/cupertino.dart';

abstract class FormWidget<P> extends StatefulWidget {
  final P? payload;
  const FormWidget({super.key, this.payload});
}
