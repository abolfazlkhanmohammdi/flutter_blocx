import 'package:blocx/blocx.dart' show ScreenManagerCubitState;
import 'package:flutter/material.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx_example/src/list/users/bloc/users_bloc.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

class ScreenUsers extends ListWidget {
  const ScreenUsers({super.key});

  @override
  State<ScreenUsers> createState() => _ScreenUsersState();
}

class _ScreenUsersState extends AnimatedListWidgetState<ScreenUsers, User, dynamic> {
  _ScreenUsersState() : super(bloc: UsersBloc());

  @override
  Widget itemBuilder(BuildContext context, User item) {
    var textTheme = Theme.of(context).textTheme;
    return Card(
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
              child: Image.network(item.image, key: Key("image_${item.identifier}"), fit: BoxFit.cover),
            ),
            SizedBox(width: 24),
            Expanded(
              child: Column(
                spacing: 8,
                children: [
                  Text(item.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(item.name, style: textTheme.labelMedium),
                ],
              ),
            ),
            Text(item.index.toString(), style: textTheme.headlineLarge),
          ],
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
}
