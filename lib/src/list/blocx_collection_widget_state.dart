import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx/src/core/localizations/loc_provider.dart';
import 'package:flutter_blocx/src/screen_manager/blocx_screen_manager_state.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

abstract class BlocxCollectionWidgetState<W extends BlocxCollectionWidget<P>, T extends BlocxBaseEntity, P>
    extends BlocxScreenManagerState<W> {
  late final BlocxCollectionBloc<T, P> _bloc;
  ScrollController? scrollController;
  @override
  void initState() {
    _bloc = generateBloc;
    setScrollController();
    if (loadOnInit) {
      _bloc.add(BlocxCollectionEventLoadInitialPage<T, P>(payload: widget.payload));
    }
    super.initState();
  }

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return BlocProvider<BlocxCollectionBloc<T, P>>.value(
      value: _bloc,
      child: BlocConsumer<BlocxCollectionBloc<T, P>, BlocxCollectionState<T>>(
        buildWhen: (_, s) => s.shouldRebuild,
        listenWhen: (_, s) => s.shouldListen,
        listener: _listListener,
        builder: collectionWrapperBuilder,
      ),
    );
  }

  Widget collectionWrapperBuilder(BuildContext context, BlocxCollectionState<T> state) {
    final top = topWidget(context, state);
    final bottom = bottomWidget(context, state);
    final bool isLoadingOrSearching = isLoading || isSearching;
    final bool isEmpty = !isLoading && state.list.isEmpty;
    final Widget coreBox = (isLoadingOrSearching || isEmpty)
        ? (isLoadingOrSearching ? loadingWidget(context, state) : emptyWidget(context, state))
        : collectionWidget(context, state); // must return a regular Widget*

    final children = <Widget>[
      if (top != null) top,
      if (top != null) SizedBox(height: topBottomAndListSpacing),
      _collectionOptions.shrinkWrap ? coreBox : Expanded(child: coreBox),
      if (bottom != null) SizedBox(height: topBottomAndListSpacing),
      if (bottom != null) bottom,
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  double get topBottomAndListSpacing => 8.0;

  Widget? topWidget(BuildContext context, BlocxCollectionState<T> state) => null;

  Widget? bottomWidget(BuildContext context, BlocxCollectionState<T> state) => null;

  Widget? sliverTopWidget(BuildContext context, BlocxCollectionState<T> state) => null;

  Widget? sliverBottomWidget(BuildContext context, BlocxCollectionState<T> state) => null;

  Widget itemBuilder(BuildContext context, T item);

  void _listListener(BuildContext context, BlocxCollectionState<T> state) {
    if (state is BlocxCollectionStateScrollToItem<T>) {
      var sc = scrollController as AutoScrollController;
      sc.scrollToIndex(state.index, preferPosition: AutoScrollPosition.middle);
    }
    blocListener(context, state);
  }

  void blocListener(BuildContext context, BlocxCollectionState<T> state) {
    if (state is BlocxCollectionStateSelectionChanged<T>) {
      onSelectionChanged(context, state.selectionData);
    }
  }

  bool get isLoading => _bloc.state is BlocxCollectionStateLoading;
  bool get isSearching => _bloc.state.isSearching;
  void search(String text) {
    _bloc.add(BlocxCollectionEventSearch<T>(searchText: text));
  }

  Widget loadingWidget(BuildContext context, BlocxCollectionState<T> state) {
    return Column(
      spacing: 24,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        Text(
          state.isSearching ? searchingText : loc.loadingText,
          style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary),
        ),
        Row(),
      ],
    );
  }

  void refreshData() {
    _bloc.add(BlocxCollectionEventRefreshData<T>());
  }

  void loadNextPage() {
    _bloc.add(BlocxCollectionEventLoadNextPage<T>());
  }

  AnimatedChildBuilder? get deleteAnimation => null;

  AnimatedChildBuilder? get insertAnimation => null;

  Widget separatorBuilder(BuildContext context, int index) {
    return SizedBox.shrink();
  }

  P? get payload => widget.payload;

  String get searchingText => "Searching data, please wait";

  Widget emptyWidget(BuildContext context, BlocxCollectionState<T> state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.data_object_rounded, size: 80, color: theme.colorScheme.primary),
        SizedBox(height: 8),
        Text(loc.emptyListText, style: textTheme.titleMedium, textAlign: TextAlign.center),
      ],
    );
  }

  void scrollToItem(T item, {bool highlightItem = false}) {
    if (!_bloc.isScrollable) {
      throw StateError(
        'scrollToIndex can only be used on a bloc that mixes in '
        'ScrollableBlocxCollectionBlocMixin<$T, $P>.',
      );
    }
    final bloc = _bloc as BlocxCollectionBlocScrollableMixin<T, P>;
    bloc.add(BlocxCollectionEventScrollToItem<T>(item: item, highlightItem: highlightItem));
  }

  ScrollController? get scrollControllerProvider => null;
  void setScrollController() {
    scrollController ??=
        scrollControllerProvider ?? (_bloc.isScrollable ? AutoScrollController() : ScrollController());
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
      _bloc.add(BlocxCollectionEventHighlightScrolledToItems());
    }
  }

  Widget? loadMoreWidgetBuilder(BuildContext context, bool isLoadingMore) {
    return null;
  }

  deleteMultipleItems(List<T> items) {
    _bloc.add(BlocxCollectionEventRemoveMultipleItems<T>(items: items));
  }

  deselectMultipleItems(List<T> items) {
    _bloc.add(BlocxCollectionEventDeselectMultipleItems(items: items));
  }

  CollectionWidgetStateType get _collectionDisplayType => settings.type;
  CollectionOptions get _collectionOptions => settings.options;
  CollectionSettings get settings => CollectionSettings(
    type: CollectionWidgetStateType.animatedList,
    options: AnimatedInfiniteListOptions(),
  );

  bool get autoDisposeBloc => true;

  bool get loadOnInit => true;

  BlocxCollectionBloc<T, P> get generateBloc;
  BlocxCollectionBloc<T, P> get bloc => _bloc;

  Widget collectionWidget(BuildContext context, BlocxCollectionState<T> state) {
    final opts = _collectionOptions;
    opts.assertCorrectType(_collectionDisplayType);

    switch (_collectionDisplayType) {
      case CollectionWidgetStateType.list:
        return InfiniteList<T>(
          options: opts.asOrThrow<InfiniteListOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          isRefreshable: bloc.isRefreshable,
          bloc: _bloc.infiniteListBloc,
          scrollController: scrollController,
          separatorBuilder: separatorBuilder,
          refreshOnSwipe: _bloc.isRefreshable ? refreshData : null,
          loadBottomData: _bloc.isInfinite ? loadNextPage : null,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
        );

      case CollectionWidgetStateType.sliverList:
        return SliverInfiniteList<T>(
          options: opts.asOrThrow<SliverInfiniteListOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          bloc: _bloc.infiniteListBloc,
          scrollController: scrollController,
          refreshOnSwipe: _bloc.isRefreshable ? refreshData : null,
          loadBottomData: _bloc.isInfinite ? loadNextPage : null,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
          loading: loadingWidget(context, state),
          empty: emptyWidget(context, state),
          isEmpty: state.list.isEmpty,
          isLoading: isLoading,
          sliverBottom: sliverBottomWidget(context, state),
          sliverTop: sliverTopWidget(context, state),
        );

      case CollectionWidgetStateType.animatedList:
        return AnimatedInfiniteList<T>(
          isRefreshable: _bloc.isRefreshable,
          options: opts.asOrThrow<AnimatedInfiniteListOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          bloc: _bloc.infiniteListBloc,
          scrollController: scrollController,
          refreshOnSwipe: _bloc.isRefreshable ? refreshData : null,
          loadBottomData: _bloc.isInfinite ? loadNextPage : null,
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
          bloc: _bloc.infiniteListBloc,
          separatorBuilder: separatorBuilder,
          refreshOnSwipe: _bloc.isRefreshable ? refreshData : null,
          loadBottomData: _bloc.isInfinite ? loadNextPage : null,
          loadTopData: null,
          isLoading: isLoading,
          isEmpty: state.list.isEmpty,
          scrollController: scrollController,
          sliverTop: sliverTopWidget(context, state),
          sliverBottom: sliverBottomWidget(context, state),
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
          loading: loadingWidget(context, state),
          empty: emptyWidget(context, state),
        );

      case CollectionWidgetStateType.grid:
        return InfiniteGrid<T>(
          options: opts.asOrThrow<InfiniteGridOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          bloc: _bloc.infiniteListBloc,
          scrollController: scrollController,
          refreshOnSwipe: _bloc.isRefreshable ? refreshData : null,
          loadBottomData: _bloc.isInfinite ? loadNextPage : null,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
        );

      case CollectionWidgetStateType.sliverGrid:
        return SliverInfiniteGrid<T>(
          options: opts.asOrThrow<SliverInfiniteGridOptions>(),
          items: state.list,
          itemBuilder: itemBuilder,
          bloc: _bloc.infiniteListBloc,
          scrollController: scrollController,
          refreshOnSwipe: _bloc.isRefreshable ? refreshData : null,
          loadBottomData: _bloc.isInfinite ? loadNextPage : null,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          refreshWidgetBuilder: refreshWidgetBuilder,
        );
    }
  }

  addToList(T item, {int index = 0}) {
    _bloc.add(BlocxCollectionEventAddItem(item: item, index: index));
  }

  @override
  void dispose() {
    super.dispose();
    if (autoDisposeBloc) _bloc.close();
  }

  @override
  ScreenManagerCubit get managerCubit => _bloc.screenManagerCubit;

  void onSelectionChanged(BuildContext context, SelectionChangedData<T> selectionData) {}
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

class CollectionSettings {
  final CollectionWidgetStateType type;
  final CollectionOptions options;
  CollectionSettings({required this.type, required this.options});
}
