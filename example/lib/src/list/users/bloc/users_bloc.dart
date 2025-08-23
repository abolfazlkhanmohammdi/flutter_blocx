import 'dart:async';

import 'package:blocx/blocx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';
import 'package:flutter_blocx_example/src/list/users/data/user_repository.dart';
import 'package:flutter_blocx_example/src/list/users/use_case/use_case_search_users.dart';
part 'users_bloc_event.dart';
part 'users_bloc_state.dart';

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
    with
        RefreshableListBlocMixin<User, dynamic>,
        InfiniteListBlocMixin<User, dynamic>,
        SearchableListBlocMixin<User, dynamic>,
        HighlightableListBlocMixin<User, dynamic>,
        ScrollableListBlocMixin<User, dynamic> {
  UserRepository repository = UserRepository();
  int scrollToIndex = 1;
  UsersBloc() : super(ScreenManagerCubit(), InfiniteListBloc()) {
    on<UsersEventChangeScrollIndex>(changeScrollIndex);
  }

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) {
    return ("error", "an ErrorOccurred");
  }

  @override
  Future loadInitialPage(ListEventLoadInitialPage<User, dynamic> event, Emitter<ListState<User>> emit) async {
    emit(ListStateLoading());
    var users = await repository.getUsers(loadCount, 0);
    await insertToList(users, users.length < loadCount, DataInsertSource.init);
    emitState(emit);
  }

  @override
  Future loadNextPage(ListEventLoadNextPage<User> event, Emitter<ListState<User>> emit) async {
    isLoadingNextPage = true;
    emitState(emit);
    var users = await repository.getUsers(loadCount, offset);
    await insertToList(users, users.length < loadCount, DataInsertSource.nextPage);
    isLoadingNextPage = false;
    emitState(emit);
  }

  @override
  Future refreshPage(ListEventRefreshData<User> event, Emitter<ListState<User>> emit) async {
    if (searchText.isNotEmpty) {
      add(ListEventSearchRefresh());
      return;
    }
    isRefreshing = true;
    emitState(emit);
    var users = await repository.refreshUsers(list.length, 0);
    clearList();
    await insertToList(users, users.length < list.length, DataInsertSource.refresh);
    emitState(emit);
  }

  @override
  SearchUseCase<User, dynamic>? searchUseCase(String searchText, {int? loadCount, int? offset}) {
    return UseCaseSearchUsers(
      searchQuery: SearchQuery(
        searchText: searchText,
        payload: payload,
        loadCount: loadCount ?? this.loadCount,
        offset: offset ?? this.offset,
      ),
    );
  }

  @override
  int get loadCount => 20;

  @override
  Duration get searchDebounceDuration => Duration(milliseconds: 300);

  FutureOr<void> changeScrollIndex(UsersEventChangeScrollIndex event, Emitter<ListState<User>> emit) {
    scrollToIndex = event.index;
    if (event.index < 0) {
      scrollToIndex = list.length;
    }
    emitState(emit);
  }

  @override
  emitState(Emitter<ListState<User>> emit) {
    emit(
      UsersBlocStateLoaded(
        scrollToIndex: scrollToIndex,
        list: list,
        hasReachedEnd: hasReachedEnd,
        isLoadingNextPage: isLoadingNextPage,
        isRefreshing: isRefreshing,
        isSearching: isSearching,
      ),
    );
  }
}
