import 'package:flutter/material.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx_example/src/list/inventory/ui/inventory_screen.dart';
import 'package:flutter_blocx_example/src/list/users/bloc/users_bloc.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

class UsersScreen extends ListWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends AnimatedListWidgetState<UsersScreen, User, dynamic> {
  _UsersScreenState() : super(bloc: UsersBloc());

  @override
  Widget itemBuilder(BuildContext context, User item) {
    var textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => InventoryScreen(payload: item))),
      child: Card(
        key: Key(item.identifier),
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(8)),
                ),
                width: 200,
                height: 120,
                child: FadeInImage(
                  image: NetworkImage(item.image),
                  key: Key("image_${item.identifier}"),
                  fit: BoxFit.cover,
                  placeholder: NetworkImage("https://placehold.co/600x400/png"),
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Hero(
                      tag: item.username,
                      child: Text(
                        item.name,
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(item.name, style: textTheme.labelMedium),
                  ],
                ),
              ),
              Text(item.index.toString(), style: textTheme.headlineLarge),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wrapInScaffold => true;

  @override
  Scaffold scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),
      body: body,
    );
  }

  @override
  AnimatedInfiniteListOptions get listOptions => super.listOptions.copyWith();
}
