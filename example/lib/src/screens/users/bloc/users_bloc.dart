import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/users/bloc/use_cases/use_case_delete_user.dart';
import 'package:example/src/screens/users/bloc/use_cases/use_case_get_users.dart';
import 'package:example/src/screens/users/bloc/use_cases/use_case_search_users.dart';
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
      UseCaseGetUsers(loadCount: loadCount, offset: 0);

  @override
  PaginationUseCase<User, dynamic>? get loadNextPageUseCase =>
      UseCaseGetUsers(loadCount: loadCount, offset: offset);

  @override
  BaseUseCase<bool>? deleteItemUseCase(User item) {
    return UseCaseDeleteUser(user: item);
  }

  @override
  SearchUseCase<User>? searchUseCase(String searchText, {int? loadCount, int? offset}) {
    return UseCaseSearchUsers(
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
