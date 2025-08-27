import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:blocx_flutter/list_widget.dart';
import 'package:blocx_flutter_example/src/list/users/bloc/users_bloc.dart';
import 'package:blocx_flutter_example/src/list/users/data/models/user.dart';
import 'package:blocx_flutter_example/src/list/users/ui/scroll_controller_bar.dart';
import 'package:blocx_flutter_example/src/list/users/ui/user_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UsersScreen extends ListWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ListWidgetState<UsersScreen, User, dynamic> {
  late final TextEditingController searchController;

  _UsersScreenState() : super(bloc: UsersBloc());

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget? topWidget(BuildContext context, ListState<User> state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 16,
        children: [
          BlocxSearchField<User, dynamic>(controller: searchController),
          if (!isLoading) ...[ScrollControllerBar(currentIndex: state.additionalInfo ?? 1)],
        ],
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
      appBar: AppBar(title: Text("Users")),
      body: body,
    );
  }

  @override
  InfiniteListOptions get listOptions => super.listOptions.copyWith(useAnimatedList: false, reverse: false);

  @override
  Widget? refreshWidgetBuilder(BuildContext context, double swipeRefreshHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(8)),
      // always apply swipeRefreshHeight
      width: MediaQuery.sizeOf(context).width,
      height: swipeRefreshHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitDoubleBounce(color: theme.colorScheme.onPrimary, size: swipeRefreshHeight / 2),
          Text(
            "refreshing the screen, please wait",
            style: TextStyle(fontSize: swipeRefreshHeight / 4, color: theme.colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  @override
  Widget? loadMoreWidgetBuilder(BuildContext context, bool isLoadingMore) {
    return AnimatedSize(
      duration: Duration(milliseconds: 100),
      child: isLoadingMore
          ? Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(16)),
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitDoubleBounce(color: theme.colorScheme.onPrimary, size: 32),
                  Text(
                    "Loading more items, please wait",
                    style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
                  ),
                ],
              ),
            )
          : SizedBox(),
    );
  }
}
