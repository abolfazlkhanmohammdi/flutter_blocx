import 'package:blocx/blocx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';
import 'package:flutter_blocx_example/src/list/users/data/user_repository.dart';

/// This page does not require a payload, so we pass `dynamic` for `P`.
///
/// ### Using `ListBloc`
/// There are two integration options:
///
/// **Option A — Manual control**
/// - Override:
///   - [loadInitialPage] for the first load
///   - [loadNextPage] for pagination if InfiniteListBlocMixin is added
///   - [refreshPage] for refresh if RefreshableListBlocMixin is added
/// - Manage list updates manually. use methods [insertToList], [replaceList], [replaceItemInList],
/// [removeItemFromList] and [list] getter for accessing and manpulating list
///   in this method you must update flags like
///   [isRefreshing], [isSearching], etc. yourself.
///
/// **Option B — Use case driven**
/// - Override:
///   - [loadInitialPageUseCase]
///   - [loadNextPageUseCase] if InfiniteListBlocMixin is added
///   - [refreshPageUseCase] if RefreshableListBlocMixin is added
/// - In this mode, the base class handles list updates and state flags for you.
///
/// This bloc follows **Option A** (manual control).

class UsersBloc extends ListBloc<User, dynamic>
    with RefreshableListBlocMixin<User, dynamic>, InfiniteListBlocMixin<User, dynamic> {
  UserRepository repository = UserRepository();
  UsersBloc() : super(ScreenManagerCubit(), InfiniteListBloc());

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) {
    return ("error", "an ErrorOccurred");
  }

  @override
  Future loadInitialPage(
    ListBlocEventLoadInitialPage<User, dynamic> event,
    Emitter<ListBlocState<User>> emit,
  ) async {
    emit(ListBlocStateLoading());
    var users = await repository.getUsers(loadCount, 0);
    await insertToList(users, users.length < loadCount, DataInsertSource.init);
    emitState(emit);
  }

  @override
  Future loadNextPage(ListBlocEventLoadNextPage<User> event, Emitter<ListBlocState<User>> emit) async {
    isLoadingNextPage = true;
    emitState(emit);
    var users = await repository.getUsers(loadCount, offset);
    await insertToList(users, users.length < loadCount, DataInsertSource.nextPage);
    isLoadingNextPage = false;
    emitState(emit);
  }

  @override
  Future refreshPage(ListBlocEventRefreshData<User> event, Emitter<ListBlocState<User>> emit) async {
    isRefreshing = true;
    emitState(emit);
    var users = await repository.getUsers(list.length, 0);
    await insertToList(users, users.length < list.length, DataInsertSource.refresh);
    emitState(emit);
  }
}
