import 'package:blocx_core/list_bloc.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:example/src/screens/users/bloc/users_bloc.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/presentation/user_card.dart';
import 'package:flutter/material.dart';

class UsersScreen extends BlocxCollectionWidget<dynamic> {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends BlocxCollectionWidgetState<UsersScreen, User, dynamic> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget? topWidget(BuildContext context, BlocxCollectionState<User> state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocxSearchField<User, dynamic>(
        controller: searchController,
        options: BlocxSearchFieldOptions(),
      ),
    );
  }

  @override
  Widget itemBuilder(BuildContext context, User item) {
    return UserCard(item: item);
  }

  @override
  bool get wrapInScaffold => true;

  @override
  Scaffold scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Users", style: theme.appBarTheme.titleTextStyle),
            Text("Select a user to see their note tags", style: textTheme.bodyMedium),
          ],
        ),
      ),
      body: body,
    );
  }

  @override
  CollectionSettings get settings => CollectionSettings(
    type: CollectionWidgetStateType.grid,
    options: InfiniteGridOptions(crossAxisCount: 2).copyWith(childAspectRatio: 0.75),
  );

  @override
  BlocxCollectionBloc<User, dynamic> get generateBloc => UsersBloc();
}
