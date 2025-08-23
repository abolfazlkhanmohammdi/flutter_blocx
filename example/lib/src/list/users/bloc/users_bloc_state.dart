part of 'users_bloc.dart';

class UsersBlocStateLoaded extends ListStateLoaded<User> {
  final int scrollToIndex;
  UsersBlocStateLoaded({
    required this.scrollToIndex,
    required super.list,
    required super.hasReachedEnd,
    required super.isLoadingNextPage,
    required super.isRefreshing,
    required super.isSearching,
  });

  @override
  get additionalInfo => scrollToIndex;
}
