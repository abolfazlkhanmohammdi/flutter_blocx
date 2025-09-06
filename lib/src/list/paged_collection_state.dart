import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx/src/screen_manager/screen_manager_state.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

abstract class CollectionWidgetState<W extends CollectionWidget<P>, T extends BaseEntity, P>
    extends ScreenManagerState<W> {
  late final ListBloc<T, P> bloc;
  ScrollController? scrollController;
  CollectionWidgetState({required this.bloc}) : super(managerCubit: bloc.screenManagerCubit);

  @override
  void initState() {
    setScrollController();
    bloc.add(ListEventLoadInitialPage<T, P>(payload: widget.payload));
    super.initState();
  }

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return BlocProvider<ListBloc<T, P>>.value(
      value: bloc,
      child: BlocConsumer<ListBloc<T, P>, ListState<T>>(
        buildWhen: (_, s) => s.shouldRebuild,
        listenWhen: (_, s) => s.shouldListen,
        listener: _listListener,
        builder: _collectionDisplayType.isSliver ? sliverWrapperBuilder : listWrapperBuilder,
      ),
    );
  }

  Widget sliverWrapperBuilder(BuildContext context, ListState<T> state) {
    return collectionWidget(context, state);
  }

  Widget listWrapperBuilder(BuildContext context, ListState<T> state) {
    final top = topWidget(context, state);
    final bottom = bottomWidget(context, state);
    bool hasTopOrBottomWidget = top != null || bottom != null;
    final listOrLoading = isLoading || isSearching
        ? loadingWidget(context, state)
        : state.list.isEmpty
        ? emptyWidget(context, state)
        : collectionWidget(context, state);

    if (!hasTopOrBottomWidget) return listOrLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: topBottomAndListSpacing,
      children: [
        ?top,
        Expanded(child: listOrLoading),
        ?bottom,
      ],
    );
  }

  double get topBottomAndListSpacing => 8.0;

  Widget? topWidget(BuildContext context, ListState<T> state) => null;

  Widget? bottomWidget(BuildContext context, ListState<T> state) => null;

  Widget itemBuilder(BuildContext context, T item);

  void _listListener(BuildContext context, ListState<T> state) {
    if (state is ListStateScrollToItem<T>) {
      var sc = scrollController as AutoScrollController;
      sc.scrollToIndex(state.index, preferPosition: AutoScrollPosition.middle);
    }
  }

  bool get isLoading => bloc.state is ListStateLoading;
  bool get isSearching => bloc.state.isSearching;
  void search(String text) {
    bloc.add(ListEventSearch<T>(searchText: text));
  }

  Widget loadingWidget(BuildContext context, ListState<T> state) {
    return Column(
      spacing: 24,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        Text(
          state.isSearching ? searchingText : loadingText,
          style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary),
        ),
        Row(),
      ],
    );
  }

  String get loadingText => "loading data please wait";

  void refreshData() {
    bloc.add(ListEventRefreshData<T>());
  }

  void loadNextPage() {
    bloc.add(ListEventLoadNextPage<T>());
  }

  InfiniteListOptions get listOptions => InfiniteListOptions.defaultOptions();

  AnimatedChildBuilder? get deleteAnimation => null;

  AnimatedChildBuilder? get insertAnimation => null;

  Widget separatorBuilder(BuildContext context, int index) {
    return SizedBox.shrink();
  }

  P? get payload => widget.payload;
  EdgeInsets get padding => EdgeInsets.all(8);

  String get emptyListText => "No data";

  String get searchingText => "Searching data, please wait";

  Widget emptyWidget(BuildContext context, ListState<T> state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.data_object_rounded, size: 80, color: theme.colorScheme.primary),
        SizedBox(height: 8),
        Text(emptyListText, style: textTheme.titleMedium, textAlign: TextAlign.center),
      ],
    );
  }

  void scrollToItem(T item, {bool highlightItem = false}) {
    if (!this.bloc.isScrollable) {
      throw StateError(
        'scrollToIndex can only be used on a bloc that mixes in '
        'ScrollableListBlocMixin<$T, $P>.',
      );
    }
    final bloc = this.bloc as ScrollableListBlocMixin<T, P>;
    bloc.add(ListEventScrollToItem<T>(item: item, highlightItem: highlightItem));
  }

  void setScrollController() {
    scrollController = bloc.isScrollable ? AutoScrollController() : ScrollController();
    if (scrollController is AutoScrollController) {
      (scrollController as AutoScrollController).addListener(_onScroll);
    }
  }

  Widget? refreshWidgetBuilder(BuildContext context, double swipeRefreshHeight) {
    return null;
  }

  bool _hasAutoScrolled = false;
  void _onScroll() {
    var sc = scrollController as AutoScrollController;
    if (sc.isAutoScrolling) {
      _hasAutoScrolled = true;
    }
    if (_hasAutoScrolled && !sc.isAutoScrolling) {
      _hasAutoScrolled = false;
      bloc.add(ListEventHighlightScrolledToItems());
    }
  }

  Widget? loadMoreWidgetBuilder(BuildContext context, bool isLoadingMore) {
    return null;
  }

  deleteMultipleItems(List<T> items) {
    bloc.add(ListEventRemoveMultipleItems(items: items));
  }

  deselectMultipleItems(List<T> items) {
    bloc.add(ListEventDeselectMultipleItems(items: items));
  }

  CollectionWidgetStateType get _collectionDisplayType => settings.type;
  CollectionOptions get _collectionOptions => settings.options;
  CollectionInput get settings => CollectionInput(
    type: CollectionWidgetStateType.animatedList,
    options: AnimatedInfiniteListOptions.defaultOptions(),
  );

  Widget collectionWidget(BuildContext context, ListState<T> state) {
    final opts = _collectionOptions;
    opts.assertCorrectType(_collectionDisplayType);
    opts.verifyOrThrow(_collectionDisplayType);

    switch (_collectionDisplayType) {
      case CollectionWidgetStateType.list:
        return InfiniteList<T>(
          options: opts.asOrThrow<InfiniteListOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          bloc: bloc.infiniteListBloc,
          scrollController: scrollController,
          separatorBuilder: separatorBuilder,
          refreshOnSwipe: bloc.isRefreshable ? refreshData : null,
          loadBottomData: bloc.isInfinite ? loadNextPage : null,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
        );

      case CollectionWidgetStateType.sliverList:
        return SliverInfiniteList<T>(
          options: opts.asOrThrow<SliverInfiniteListOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          bloc: bloc.infiniteListBloc,
          scrollController: scrollController,
          refreshOnSwipe: bloc.isRefreshable ? refreshData : null,
          loadBottomData: bloc.isInfinite ? loadNextPage : null,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
          topWidgetBuilder: (c) => topWidget(c, state),
          bottomWidgetBuilder: (c) => bottomWidget(c, state),
        );

      case CollectionWidgetStateType.animatedList:
        return AnimatedInfiniteList<T>(
          options: opts.asOrThrow<AnimatedInfiniteListOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          bloc: bloc.infiniteListBloc,
          scrollController: scrollController,
          refreshOnSwipe: bloc.isRefreshable ? refreshData : null,
          loadBottomData: bloc.isInfinite ? loadNextPage : null,
          loadTopData: null,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
          separatorBuilder: separatorBuilder,
          deleteAnimation: deleteAnimation,
          insertAnimation: insertAnimation,
        );

      case CollectionWidgetStateType.animatedSliverList:
        return AnimatedSliverInfiniteList<T>(
          options: opts.asOrThrow<AnimatedSliverInfiniteListOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          bloc: bloc.infiniteListBloc,
          separatorBuilder: separatorBuilder,
          refreshOnSwipe: bloc.isRefreshable ? refreshData : null,
          loadBottomData: bloc.isInfinite ? loadNextPage : null,
          loadTopData: null,
          scrollController: scrollController,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
          topWidgetBuilder: (c) => topWidget(c, state),
          bottomWidgetBuilder: (c) => bottomWidget(c, state),
        );

      case CollectionWidgetStateType.grid:
        return InfiniteGrid<T>(
          options: opts.asOrThrow<InfiniteGridOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          bloc: bloc.infiniteListBloc,
          scrollController: scrollController,
          refreshOnSwipe: bloc.isRefreshable ? refreshData : null,
          loadBottomData: bloc.isInfinite ? loadNextPage : null,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
        );

      case CollectionWidgetStateType.sliverGrid:
        return SliverInfiniteGrid<T>(
          options: opts.asOrThrow<SliverInfiniteGridOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          bloc: bloc.infiniteListBloc,
          scrollController: scrollController,
          refreshOnSwipe: bloc.isRefreshable ? refreshData : null,
          loadBottomData: bloc.isInfinite ? loadNextPage : null,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
          topWidgetBuilder: (c) => topWidget(c, state),
          bottomWidgetBuilder: (c) => bottomWidget(c, state),
        );
    }
  }

  addToList(T item, {int index = 0}) {
    bloc.add(ListEventAddItem(item: item, index: index));
  }
}

enum CollectionWidgetStateType {
  list(false),
  sliverList(true),
  animatedList(false),
  animatedSliverList(true),
  grid(false),
  sliverGrid(true);

  final bool isSliver;
  const CollectionWidgetStateType(this.isSliver);
}

class CollectionInput {
  final CollectionWidgetStateType type;
  final CollectionOptions options;
  CollectionInput({required this.type, required this.options});
}
