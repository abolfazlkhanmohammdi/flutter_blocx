import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blocx_flutter/list_widget.dart';
import 'package:blocx_flutter/src/screen_manager/screen_manager_state.dart';
import 'package:blocx_flutter/src/widgets/infinite_list.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

abstract class ListWidgetState<W extends ListWidget<P>, T extends BaseEntity, P>
    extends ScreenManagerState<W> {
  late final ListBloc<T, P> bloc;
  ScrollController? scrollController;
  ListWidgetState({required this.bloc}) : super(managerCubit: bloc.screenManagerCubit);

  @override
  void initState() {
    setScrollController();
    bloc.add(ListEventLoadInitialPage<T, P>(payload: widget.payload));

    super.initState();
  }

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return BlocProvider<ListBloc<T, P>>.value(
      value: bloc, // externally provided; don't dispose here
      child: BlocConsumer<ListBloc<T, P>, ListState<T>>(
        buildWhen: (_, s) => s.shouldRebuild,
        listenWhen: (_, s) => s.shouldListen,
        listener: _listListener,
        builder: listBuilder,
      ),
    );
  }

  Widget listBuilder(BuildContext context, ListState<T> state) {
    final top = topWidget(context, state);
    final bottom = bottomWidget(context, state);
    bool hasTopOrBottomWidget = top != null || bottom != null;
    final listOrLoading = isLoading || isSearching
        ? loadingWidget(context, state)
        : state.list.isEmpty
        ? emptyWidget(context, state)
        : InfiniteList<T>(
            scrollController: scrollController,
            refreshOnSwipe: bloc.isRefreshable ? refreshData : null,
            loadBottomData: bloc.isInfinite ? loadNextPage : null,
            itemBuilder: itemBuilder,
            items: state.list,
            bloc: bloc.infiniteListBloc,
            deleteAnimation: deleteAnimation,
            insertAnimation: insertAnimation,
            separatorBuilder: separatorBuilder,
            options: listOptions.copyWith(padding: padding),
            refreshWidgetBuilder: refreshWidgetBuilder,
            loadMoreWidgetBuilder: loadMoreWidgetBuilder,
          );

    // if neither top nor bottom exists, return list directly
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

  /// Spacing inserted between top/bottom widgets and the list.
  double get topBottomAndListSpacing => 8.0;

  /// Optional header above the list.
  Widget? topWidget(BuildContext context, ListState<T> state) => null;

  /// Optional footer below the list.
  Widget? bottomWidget(BuildContext context, ListState<T> state) => null;

  /// Renders a single list item.
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

  @override
  Widget errorWidget(BuildContext context, ScreenManagerCubitStateDisplayErrorPage state) {
    return SizedBox();
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

  ThemeData get theme => Theme.of(context);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
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

  // does not work with animated list variant
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
    // Ensure the bloc has the scrollable mixin
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
}
