import 'package:flutter/cupertino.dart';

abstract class CollectionWidget<P> extends StatefulWidget {
  final P? payload;
  const CollectionWidget({super.key, this.payload});
}
