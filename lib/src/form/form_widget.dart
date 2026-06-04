import 'package:flutter/cupertino.dart';

abstract class BlocxFormWidget<P> extends StatefulWidget {
  final P? payload;
  const BlocxFormWidget({super.key, this.payload});
}
