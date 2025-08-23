import 'package:blocx/blocx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx_example/src/list/inventory/bloc/inventory_bloc.dart';
import 'package:flutter_blocx_example/src/list/inventory/data/models/product.dart';
import 'package:flutter_blocx_example/src/list/inventory/ui/product_card.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

class InventoryScreen extends ListWidget<User> {
  // don't forget to add super.payload
  const InventoryScreen({super.key, required super.payload});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ListWidgetState<InventoryScreen, Product, User> {
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
  Widget? bottomWidget(BuildContext context, ListState<Product> state) {
    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      child: Row(
        children: [
          Expanded(child: Text("selected item count: ${state.selectedCount}")),
          IconButton(
            onPressed: () => deleteMultipleItems(state.selectedItems),
            icon: Icon(Icons.delete, color: Colors.red, size: 24),
          ),
        ],
      ),
    );
  }
}
