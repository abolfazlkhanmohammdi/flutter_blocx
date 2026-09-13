import 'package:flutter/cupertino.dart';

abstract class BlocxCollectionWidget<Payload> extends StatefulWidget {
  final Payload? payload;
  const BlocxCollectionWidget({super.key, this.payload});
}
