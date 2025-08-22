import 'package:flutter/material.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx_example/src/list/inventory/bloc/inventory_bloc.dart';
import 'package:flutter_blocx_example/src/list/inventory/data/models/product.dart';
import 'package:flutter_blocx_example/src/list/inventory/ui/product_card.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

class InventoryScreen extends ListWidget<User> {
  // don't forget to add super.payload
  const InventoryScreen({super.key, super.payload});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends AnimatedListWidgetState<InventoryScreen, Product, User> {
  _InventoryScreenState() : super(bloc: InventoryBloc());

  @override
  Widget itemBuilder(BuildContext context, Product item) {
    return ProductCard(item: item);
  }

  @override
  bool get wrapInScaffold => true;

  @override
  Scaffold scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(tag: payload?.username ?? "", child: Text("${payload?.name ?? "User"}'s inventory")),
      ),

      /// always pass parameter [body] to scaffold
      body: body,
    );
  }

  @override
  AnimatedInfiniteListOptions get listOptions => super.listOptions.copyWith(reverse: true);
}
