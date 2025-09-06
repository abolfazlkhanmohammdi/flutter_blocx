import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/users/bloc/use_cases/delete_user_use_case.dart';
import 'package:example/src/screens/users/bloc/use_cases/get_users_use_case.dart';
import 'package:example/src/screens/users/bloc/use_cases/search_users_use_case.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class UsersBloc extends ListBloc<User, dynamic>
    with
        InfiniteListBlocMixin<User, dynamic>,
        SearchableListBlocMixin<User, dynamic>,
        DeletableListBlocMixin<User, dynamic>,
        HighlightableListBlocMixin<User, dynamic>,
        SelectableListBlocMixin<User, dynamic> {
  UsersBloc() : super(ScreenManagerCubit(), InfiniteListBloc());

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) {
    return ("error", "an error occurred!");
  }

  @override
  PaginationUseCase<User, dynamic>? get loadInitialPageUseCase =>
      GetUsersUseCase(loadCount: loadCount, offset: 0);

  @override
  PaginationUseCase<User, dynamic>? get loadNextPageUseCase =>
      GetUsersUseCase(loadCount: loadCount, offset: offset);

  @override
  BaseUseCase<bool>? deleteItemUseCase(User item) {
    return DeleteUserUseCase(user: item);
  }

  @override
  SearchUseCase<User>? searchUseCase(String searchText, {int? loadCount, int? offset}) {
    return SearchUsersUseCase(
      searchText: searchText,
      loadCount: loadCount ?? this.loadCount,
      offset: offset ?? 0,
    );
  }

  @override
  ErrorDisplayPolicy get errorDisplayPolicy => ErrorDisplayPolicy.page;

  @override
  bool get isSingleSelect => false;
}
