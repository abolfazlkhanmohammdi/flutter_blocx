import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart';
import 'package:example/src/core/blocs/collection_bloc.dart';
import 'package:example/src/screens/users/bloc/use_cases/delete_user_use_case.dart';
import 'package:example/src/screens/users/bloc/use_cases/get_users_use_case.dart';
import 'package:example/src/screens/users/bloc/use_cases/search_users_use_case.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class UsersBloc extends CollectionBloc<User, void>
    with
        BlocxCollectionInfiniteMixin<User, void>,
        BlocxCollectionSearchableMixin<User, void>,
        BlocxCollectionDeletableMixin<User, void>,
        BlocxCollectionHighlightableMixin<User, void>,
        BlocxCollectionSelectableMixin<User, void> {
  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedUseCase<BlocxPaginationInput, User>, BlocxPaginationInput>?
  get paginationTask => BlocxPaginatedUseCaseTask(
    useCase: GetUsersUseCase(),
    inputBuilder: (offset, limit) => BlocxPaginationInput(limit: limit, offset: offset),
  );

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedUseCase<BlocxSearchInput, User>, BlocxSearchInput>?
  get searchUseCaseTask => BlocxPaginatedUseCaseTask(
    useCase: SearchUsersUseCase(),
    inputBuilder: (offset, limit) => SearchUsersInput(searchText: searchText, limit: limit, offset: offset),
  );

  @override
  ErrorDisplayPolicy get errorDisplayPolicy => ErrorDisplayPolicy.page;

  @override
  bool get isSingleSelect => false;

  @override
  BlocxBaseUseCase<User, bool>? get deleteItemUseCase => DeleteUserUseCase();
}
