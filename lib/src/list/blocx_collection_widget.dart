import 'package:flutter/cupertino.dart';

abstract class BlocxCollectionWidget<P> extends StatefulWidget {
  final P? payload;
  const BlocxCollectionWidget({super.key, this.payload});
}
