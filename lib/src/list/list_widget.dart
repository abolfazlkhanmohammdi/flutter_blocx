import 'package:flutter/cupertino.dart';

abstract class ListWidget<P> extends StatefulWidget {
  final P? payload;
  const ListWidget({super.key, this.payload});
}
