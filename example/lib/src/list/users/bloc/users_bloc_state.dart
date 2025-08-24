part of 'users_bloc.dart';

class UsersBlocStateLoaded extends ListStateLoaded<User> {
  final int scrollToIndex;
  const UsersBlocStateLoaded({
    required this.scrollToIndex,
    required super.list,
    required super.hasReachedEnd,
    required super.isLoadingNextPage,
    required super.isRefreshing,
    required super.isSearching,
    required super.selectedItemIds,
    required super.beingSelectedItemIds,
    required super.highlightedItemIds,
    required super.beingRemovedItemIds,
    required super.expandedItemIds,
  });

  @override
  get additionalInfo => scrollToIndex;
}
