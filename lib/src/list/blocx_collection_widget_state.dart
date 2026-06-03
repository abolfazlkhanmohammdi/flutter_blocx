import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx/src/core/localizations/loc_provider.dart';
import 'package:flutter_blocx/src/screen_manager/blocx_screen_manager_state.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/// Base state class for screens that host a [BlocxCollectionBloc].
///
/// Provides standard list rendering, pagination, refresh handling, search,
/// selection callbacks, scroll-to-item support, and screen-manager integration.
///
/// Type parameters:
///
/// - [W]: The [BlocxCollectionWidget] subclass this state belongs to.
/// - [T]: The collection item entity type.
/// - [P]: The optional payload type used during initial loading.
abstract class BlocxCollectionWidgetState<W extends BlocxCollectionWidget<P>, T extends BlocxBaseEntity, P>
    extends BlocxScreenManagerState<W> {
  late final BlocxCollectionBloc<T, P> _bloc;

  /// The active scroll controller used by the rendered collection widget.
  ScrollController? scrollController;

  bool _ownsScrollController = false;
  bool _autoScrollListenerAttached = false;
  bool _hasAutoScrolled = false;

  @override
  void initState() {
    _bloc = generateBloc;
    setScrollController();

    if (loadOnInit) {
      _bloc.add(
        BlocxCollectionEventLoadInitialPage<T, P>(
          payload: widget.payload,
        ),
      );
    }

    super.initState();
  }

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return BlocProvider<BlocxCollectionBloc<T, P>>.value(
      value: _bloc,
      child: BlocConsumer<BlocxCollectionBloc<T, P>, BlocxCollectionState<T>>(
        buildWhen: (_, current) => current.shouldRebuild,
        listenWhen: (_, current) => current.shouldListen,
        listener: _listListener,
        builder: collectionWrapperBuilder,
      ),
    );
  }

  /// Wraps the main collection widget with optional top and bottom widgets.
  Widget collectionWrapperBuilder(
    BuildContext context,
    BlocxCollectionState<T> state,
  ) {
    final top = topWidget(context, state);
    final bottom = bottomWidget(context, state);
    final isLoadingOrSearching = isLoading || isSearching;
    final isEmpty = !isLoading && state.list.isEmpty;

    final coreBox = isLoadingOrSearching || isEmpty
        ? isLoadingOrSearching
            ? loadingWidget(context, state)
            : emptyWidget(context, state)
        : collectionWidget(context, state);

    final children = <Widget>[
      if (top != null) top,
      if (top != null) SizedBox(height: topBottomAndListSpacing),
      _collectionOptions.shrinkWrap ? coreBox : Expanded(child: coreBox),
      if (bottom != null) SizedBox(height: topBottomAndListSpacing),
      if (bottom != null) bottom,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  /// Vertical spacing between optional top/bottom widgets and the collection.
  double get topBottomAndListSpacing => 8.0;

  /// Optional widget displayed above the collection.
  Widget? topWidget(BuildContext context, BlocxCollectionState<T> state) => null;

  /// Optional widget displayed below the collection.
  Widget? bottomWidget(BuildContext context, BlocxCollectionState<T> state) => null;

  /// Optional sliver displayed above sliver collections.
  Widget? sliverTopWidget(BuildContext context, BlocxCollectionState<T> state) => null;

  /// Optional sliver displayed below sliver collections.
  Widget? sliverBottomWidget(
    BuildContext context,
    BlocxCollectionState<T> state,
  ) =>
      null;

  /// Builds one visual item for [item].
  Widget itemBuilder(BuildContext context, T item);

  void _listListener(BuildContext context, BlocxCollectionState<T> state) {
    if (state is BlocxCollectionStateScrollToItem<T>) {
      final controller = scrollController;

      if (controller is AutoScrollController) {
        controller.scrollToIndex(
          state.index,
          preferPosition: AutoScrollPosition.middle,
        );
      }
    }

    blocListener(context, state);
  }

  /// Reacts to listen-only collection states.
  void blocListener(BuildContext context, BlocxCollectionState<T> state) {
    if (state is BlocxCollectionStateSelectionChanged<T>) {
      onSelectionChanged(context, state.selectionData);
    }
  }

  /// Whether the collection is currently loading its initial data.
  bool get isLoading => _bloc.state is BlocxCollectionStateLoading;

  /// Whether the collection is currently searching.
  bool get isSearching => _bloc.state.isSearching;

  /// Dispatches a search event with [text].
  void search(String text) {
    _bloc.add(BlocxCollectionEventSearch<T>(searchText: text));
  }

  /// Builds the loading widget.
  Widget loadingWidget(BuildContext context, BlocxCollectionState<T> state) {
    return Column(
      spacing: 24,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        Text(
          state.isSearching ? searchingText : loc.loadingText,
          style: textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const Row(),
      ],
    );
  }

  /// Dispatches a refresh event.
  void refreshData() {
    _bloc.add(BlocxCollectionEventRefreshData<T>());
  }

  /// Dispatches a load-next-page event.
  void loadNextPage() {
    _bloc.add(BlocxCollectionEventLoadNextPage<T>());
  }

  /// Optional delete animation builder for animated collection widgets.
  AnimatedChildBuilder? get deleteAnimation => null;

  /// Optional insert animation builder for animated collection widgets.
  AnimatedChildBuilder? get insertAnimation => null;

  /// Builds a separator between list items.
  Widget separatorBuilder(BuildContext context, int index) {
    return const SizedBox.shrink();
  }

  /// The current widget payload.
  P? get payload => widget.payload;

  /// Text shown while search is running.
  String get searchingText => 'Searching data, please wait';

  /// Builds the empty-state widget.
  Widget emptyWidget(BuildContext context, BlocxCollectionState<T> state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.data_object_rounded,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          loc.emptyListText,
          style: textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Scrolls to [item].
  ///
  /// Requires the collection bloc to support [BlocxCollectionScrollableMixin].
  void scrollToItem(T item, {bool highlightItem = false}) {
    if (!_bloc.isScrollable) {
      throw StateError(
        'scrollToIndex can only be used on a bloc that mixes in '
        'BlocxCollectionScrollableMixin<$T, $P>.',
      );
    }

    final scrollableBloc = _bloc as BlocxCollectionScrollableMixin<T, P>;
    scrollableBloc.add(
      BlocxCollectionEventScrollToItem<T>(
        item: item,
        highlightItem: highlightItem,
      ),
    );
  }

  /// Optional external scroll controller provider.
  ///
  /// When this returns a controller, this state does not dispose it.
  ScrollController? get scrollControllerProvider => null;

  /// Creates or attaches the scroll controller used by the collection.
  void setScrollController() {
    if (scrollController == null) {
      final providedController = scrollControllerProvider;

      if (providedController != null) {
        scrollController = providedController;
        _ownsScrollController = false;
      } else {
        scrollController = _bloc.isScrollable ? AutoScrollController() : ScrollController();
        _ownsScrollController = true;
      }
    }

    final controller = scrollController;
    if (controller is AutoScrollController && !_autoScrollListenerAttached) {
      controller.addListener(_onScroll);
      _autoScrollListenerAttached = true;
    }
  }

  /// Builds a custom refresh indicator widget.
  Widget? refreshWidgetBuilder(
    BuildContext context,
    double swipeRefreshHeight,
  ) {
    return null;
  }

  void _onScroll() {
    final controller = scrollController;
    if (controller is! AutoScrollController) return;

    if (controller.isAutoScrolling) {
      _hasAutoScrolled = true;
    }

    if (_hasAutoScrolled && !controller.isAutoScrolling) {
      _hasAutoScrolled = false;
      _bloc.add(BlocxCollectionEventHighlightScrolledToItems());
    }
  }

  /// Builds a custom load-more indicator widget.
  Widget? loadMoreWidgetBuilder(BuildContext context, bool isLoadingMore) {
    return null;
  }

  /// Dispatches a remove-multiple-items event.
  void deleteMultipleItems(List<T> items) {
    _bloc.add(BlocxCollectionEventRemoveMultipleItems<T>(items: items));
  }

  /// Dispatches a deselect-multiple-items event.
  void deselectMultipleItems(List<T> items) {
    _bloc.add(BlocxCollectionEventDeselectMultipleItems<T>(items: items));
  }

  CollectionWidgetStateType get _collectionDisplayType => settings.type;

  CollectionOptions get _collectionOptions => settings.options;

  /// Collection rendering settings.
  CollectionSettings get settings => CollectionSettings(
        type: CollectionWidgetStateType.animatedList,
        options: AnimatedInfiniteListOptions(),
      );

  /// Whether [_bloc] is closed when this state is disposed.
  bool get autoDisposeBloc => true;

  /// Whether initial data should be loaded during [initState].
  bool get loadOnInit => true;

  /// Creates the collection bloc for this state.
  BlocxCollectionBloc<T, P> get generateBloc;

  /// The collection bloc that drives this screen.
  BlocxCollectionBloc<T, P> get bloc => _bloc;

  /// Builds the concrete collection widget for [state].
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

  /// Dispatches an add-item event.
  void addToList(T item, {int index = 0}) {
    _bloc.add(BlocxCollectionEventAddItem<T>(item: item, index: index));
  }

  @override
  void dispose() {
    final controller = scrollController;

    if (_autoScrollListenerAttached && controller is AutoScrollController) {
      controller.removeListener(_onScroll);
      _autoScrollListenerAttached = false;
    }

    if (_ownsScrollController) {
      controller?.dispose();
    }

    scrollController = null;

    if (autoDisposeBloc) {
      _bloc.close();
    }

    super.dispose();
  }

  /// Called when the collection selection changes.
  void onSelectionChanged(
    BuildContext context,
    SelectionChangedData<T> selectionData,
  ) {}

  @override
  ScreenManagerCubit get managerCubit => bloc.screenManagerCubit;
}

/// Collection display type.
enum CollectionWidgetStateType {
  /// Standard box list.
  list(false),

  /// Sliver list.
  sliverList(true),

  /// Animated box list.
  animatedList(false),

  /// Animated sliver list.
  animatedSliverList(true),

  /// Standard box grid.
  grid(false),

  /// Sliver grid.
  sliverGrid(true);

  /// Whether this display type must be used inside a sliver context.
  final bool isSliver;

  /// Creates a collection display type.
  const CollectionWidgetStateType(this.isSliver);
}

/// Settings used by [BlocxCollectionWidgetState] to choose a collection widget.
class CollectionSettings {
  /// The collection display type.
  final CollectionWidgetStateType type;

  /// The options matching [type].
  final CollectionOptions options;

  /// Creates collection settings.
  CollectionSettings({
    required this.type,
    required this.options,
  });
}
