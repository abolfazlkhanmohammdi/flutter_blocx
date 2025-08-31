import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/users/bloc/use_cases/use_case_get_users.dart';
import 'package:example/src/screens/users/bloc/use_cases/use_case_search_users.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class UsersBloc extends ListBloc<User, dynamic>
    with InfiniteListBlocMixin<User, dynamic>, SearchableListBlocMixin<User, dynamic> {
  UsersBloc() : super(ScreenManagerCubit(), InfiniteListBloc());

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) {
    return ("error", "an error occurred!");
  }

  @override
  PaginationUseCase<User, dynamic>? get loadInitialPageUseCase => UseCaseGetUsers(
    queryInput: PaginationQuery(payload: "", loadCount: loadCount, offset: 0),
  );

  @override
  PaginationUseCase<User, dynamic>? get loadNextPageUseCase => UseCaseGetUsers(
    queryInput: PaginationQuery(payload: "", loadCount: loadCount, offset: offset),
  );

  @override
  SearchUseCase<User, dynamic>? searchUseCase(String searchText, {int? loadCount, int? offset}) {
    return UseCaseSearchUsers(
      searchQuery: SearchQuery(
        searchText: searchText,
        payload: payload,
        loadCount: loadCount ?? this.loadCount,
        offset: offset ?? 0,
      ),
    );
  }

  @override
  ErrorDisplayPolicy get errorDisplayPolicy => ErrorDisplayPolicy.page;
}
