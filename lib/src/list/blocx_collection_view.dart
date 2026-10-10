import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx/src/screen_manager/blocx_error_widget.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/// A composable widget that renders a [BlocxCollectionBloc].
///
/// Unlike [BlocxCollectionWidgetState], [BlocxCollectionView] is a standalone
/// widget that can be embedded anywhere in a Flutter widget tree without
/// requiring a full screen-level state subclass.
class BlocxCollectionView<Entity extends BlocxBaseEntity, Payload>
    extends StatefulWidget {
  /// The collection bloc driving this view.
  final BlocxCollectionBloc<Entity, Payload> bloc;

  /// Builds a visual item for [item].
  final Widget Function(BuildContext context, Entity item) itemBuilder;

  /// Rendering configuration and options.
  final CollectionSettings? settings;

  /// Optional external scroll controller.
  ///
  /// If omitted, a managed controller is created and disposed internally.
  final ScrollController? scrollController;

  /// Spacing between optional top/bottom widgets and the core collection.
  final double topBottomAndListSpacing;

  /// Optional widget displayed above the collection.
  final Widget? Function(
      BuildContext context, BlocxCollectionState<Entity> state)? topWidget;

  /// Optional widget displayed below the collection.
  final Widget? Function(
      BuildContext context, BlocxCollectionState<Entity> state)? bottomWidget;

  /// Optional sliver displayed above sliver collections.
  final Widget? Function(
          BuildContext context, BlocxCollectionState<Entity> state)?
      sliverTopWidget;

  /// Optional sliver displayed below sliver collections.
  final Widget? Function(
          BuildContext context, BlocxCollectionState<Entity> state)?
      sliverBottomWidget;

  /// Builder for the loading state.
  final Widget Function(
      BuildContext context, BlocxCollectionState<Entity> state)? loadingWidget;

  /// Builder for the empty state.
  final Widget Function(
      BuildContext context, BlocxCollectionState<Entity> state)? emptyWidget;

  /// Builder for the initial-load error state.
  final Widget Function(
          BuildContext context, BlocxCollectionStateError<Entity> state)?
      errorWidget;

  /// Builds a separator between list items.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Optional delete animation builder for animated lists.
  final AnimatedChildBuilder? deleteAnimation;

  /// Optional insert animation builder for animated lists.
  final AnimatedChildBuilder? insertAnimation;

  /// Builds a custom refresh indicator.
  final Widget? Function(BuildContext context, double swipeRefreshHeight)?
      refreshWidgetBuilder;

  /// Builds a custom load-more indicator.
  final Widget? Function(BuildContext context, bool isLoadingMore)?
      loadMoreWidgetBuilder;

  /// Callback invoked when item selection changes.
  final void Function(
          BuildContext context, SelectionChangedData<Entity> selectionData)?
      onSelectionChanged;

  /// Optional custom listener for listen-only states.
  final void Function(BuildContext context, BlocxCollectionState<Entity> state)?
      listener;

  /// Optional override for the concrete collection widget builder.
  final Widget Function(
          BuildContext context, BlocxCollectionState<Entity> state)?
      collectionWidgetBuilder;

  /// Optional override for the outer wrapper builder surrounding the collection.
  final Widget Function(
      BuildContext context, BlocxCollectionState<Entity> state)? wrapperBuilder;

  /// Callback invoked when the user taps retry on the default error widget.
  final VoidCallback? onRetry;

  /// Creates a composable collection view.
  const BlocxCollectionView({
    super.key,
    required this.bloc,
    required this.itemBuilder,
    this.settings,
    this.scrollController,
    this.topBottomAndListSpacing = 8.0,
    this.topWidget,
    this.bottomWidget,
    this.sliverTopWidget,
    this.sliverBottomWidget,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.separatorBuilder,
    this.deleteAnimation,
    this.insertAnimation,
    this.refreshWidgetBuilder,
    this.loadMoreWidgetBuilder,
    this.onSelectionChanged,
    this.listener,
    this.collectionWidgetBuilder,
    this.wrapperBuilder,
    this.onRetry,
  });

  @override
  State<BlocxCollectionView<Entity, Payload>> createState() =>
      _BlocxCollectionViewState<Entity, Payload>();
}

class _BlocxCollectionViewState<Entity extends BlocxBaseEntity, Payload>
    extends State<BlocxCollectionView<Entity, Payload>> {
  ScrollController? _internalScrollController;
  bool _ownsScrollController = false;
  bool _autoScrollListenerAttached = false;
  bool _hasAutoScrolled = false;

  ScrollController get _activeScrollController =>
      widget.scrollController ?? _internalScrollController!;

  CollectionSettings get _effectiveSettings =>
      widget.settings ??
      CollectionSettings(
        type: CollectionWidgetStateType.animatedList,
        options: AnimatedInfiniteListOptions(),
      );

  @override
  void initState() {
    super.initState();
    _initScrollController();
  }

  @override
  void didUpdateWidget(
      covariant BlocxCollectionView<Entity, Payload> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _detachAutoScrollListener();
      if (_ownsScrollController) {
        _internalScrollController?.dispose();
        _internalScrollController = null;
        _ownsScrollController = false;
      }
      _initScrollController();
    }
  }

  void _initScrollController() {
    if (widget.scrollController == null) {
      _internalScrollController = widget.bloc.isScrollable
          ? AutoScrollController()
          : ScrollController();
      _ownsScrollController = true;
    } else {
      _ownsScrollController = false;
    }

    final controller = _activeScrollController;
    if (controller is AutoScrollController && !_autoScrollListenerAttached) {
      controller.addListener(_onScroll);
      _autoScrollListenerAttached = true;
    }
  }

  void _detachAutoScrollListener() {
    final controller = _activeScrollController;
    if (_autoScrollListenerAttached && controller is AutoScrollController) {
      controller.removeListener(_onScroll);
      _autoScrollListenerAttached = false;
    }
  }

  void _onScroll() {
    final controller = _activeScrollController;
    if (controller is! AutoScrollController) return;

    if (controller.isAutoScrolling) {
      _hasAutoScrolled = true;
    }

    if (_hasAutoScrolled && !controller.isAutoScrolling) {
      _hasAutoScrolled = false;
      widget.bloc.add(BlocxCollectionEventHighlightScrolledToItems());
    }
  }

  @override
  void dispose() {
    _detachAutoScrollListener();
    if (_ownsScrollController) {
      _internalScrollController?.dispose();
      _internalScrollController = null;
    }
    super.dispose();
  }

  void _handleListener(
      BuildContext context, BlocxCollectionState<Entity> state) {
    if (state is BlocxCollectionStateScrollToItem<Entity>) {
      final controller = _activeScrollController;
      if (controller is AutoScrollController) {
        controller.scrollToIndex(
          state.index,
          preferPosition: AutoScrollPosition.middle,
        );
      }
    }

    if (state is BlocxCollectionStateSelectionChanged<Entity>) {
      widget.onSelectionChanged?.call(context, state.selectionData);
    }

    widget.listener?.call(context, state);
  }

  void _refreshData() {
    widget.bloc.add(BlocxCollectionEventRefreshData<Entity>());
  }

  void _loadNextPage() {
    widget.bloc.add(BlocxCollectionEventLoadNextPage<Entity>());
  }

  void _retryInitialPage() {
    if (widget.onRetry != null) {
      widget.onRetry!();
    } else {
      widget.bloc.add(
        BlocxCollectionEventLoadInitialPage<Entity, Payload>(payload: null),
      );
    }
  }

  Widget _defaultLoadingWidget(
      BuildContext context, BlocxCollectionState<Entity> state) {
    final theme = Theme.of(context);
    final loc = widget.bloc.localizations;
    return Column(
      spacing: 24,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        Text(
          state.isSearching ? loc.searchingText : loc.loadingText,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const Row(),
      ],
    );
  }

  Widget _defaultEmptyWidget(
      BuildContext context, BlocxCollectionState<Entity> state) {
    final theme = Theme.of(context);
    final loc = widget.bloc.localizations;
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
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _defaultErrorWidget(
      BuildContext context, BlocxCollectionStateError<Entity> state) {
    return Center(
      child: BlocxErrorWidget(
        error: ReadableError(message: state.message),
        onRetry: _retryInitialPage,
      ),
    );
  }

  Widget _buildCollectionWidget(
      BuildContext context, BlocxCollectionState<Entity> state) {
    if (widget.collectionWidgetBuilder != null) {
      return widget.collectionWidgetBuilder!(context, state);
    }

    final settings = _effectiveSettings;
    final opts = settings.options;
    opts.assertCorrectType(settings.type);
    final bloc = widget.bloc;
    final scrollCtrl = _activeScrollController;
    final separator =
        widget.separatorBuilder ?? (_, __) => const SizedBox.shrink();

    switch (settings.type) {
      case CollectionWidgetStateType.list:
        return InfiniteList<Entity>(
          options: opts.asOrThrow<InfiniteListOptions>(),
          items: state.list,
          itemBuilder: widget.itemBuilder,
          isRefreshable: bloc.isRefreshable,
          bloc: bloc.infiniteListBloc,
          scrollController: scrollCtrl,
          separatorBuilder: separator,
          refreshOnSwipe: bloc.isRefreshable ? _refreshData : null,
          loadBottomData: bloc.isInfinite ? _loadNextPage : null,
          loadMoreWidgetBuilder: widget.loadMoreWidgetBuilder,
          refreshWidgetBuilder: widget.refreshWidgetBuilder,
        );

      case CollectionWidgetStateType.sliverList:
        return SliverInfiniteList<Entity>(
          options: opts.asOrThrow<SliverInfiniteListOptions>(),
          items: state.list,
          itemBuilder: widget.itemBuilder,
          bloc: bloc.infiniteListBloc,
          scrollController: scrollCtrl,
          refreshOnSwipe: bloc.isRefreshable ? _refreshData : null,
          loadBottomData: bloc.isInfinite ? _loadNextPage : null,
          loadMoreWidgetBuilder: widget.loadMoreWidgetBuilder,
          refreshWidgetBuilder: widget.refreshWidgetBuilder,
          loading: widget.loadingWidget?.call(context, state) ??
              _defaultLoadingWidget(context, state),
          empty: widget.emptyWidget?.call(context, state) ??
              _defaultEmptyWidget(context, state),
          isEmpty: state.list.isEmpty,
          isLoading: state is BlocxCollectionStateLoading<Entity>,
          sliverBottom: widget.sliverBottomWidget?.call(context, state),
          sliverTop: widget.sliverTopWidget?.call(context, state),
        );

      case CollectionWidgetStateType.animatedList:
        return AnimatedInfiniteList<Entity>(
          isRefreshable: bloc.isRefreshable,
          options: opts.asOrThrow<AnimatedInfiniteListOptions>(),
          items: state.list,
          itemBuilder: widget.itemBuilder,
          bloc: bloc.infiniteListBloc,
          scrollController: scrollCtrl,
          refreshOnSwipe: bloc.isRefreshable ? _refreshData : null,
          loadBottomData: bloc.isInfinite ? _loadNextPage : null,
          loadTopData: null,
          loadMoreWidgetBuilder: widget.loadMoreWidgetBuilder,
          refreshWidgetBuilder: widget.refreshWidgetBuilder,
          separatorBuilder: separator,
          deleteAnimation: widget.deleteAnimation,
          insertAnimation: widget.insertAnimation,
        );

      case CollectionWidgetStateType.animatedSliverList:
        return AnimatedSliverInfiniteList<Entity>(
          options: opts.asOrThrow<AnimatedSliverInfiniteListOptions>(),
          items: state.list,
          itemBuilder: widget.itemBuilder,
          bloc: bloc.infiniteListBloc,
          separatorBuilder: separator,
          refreshOnSwipe: bloc.isRefreshable ? _refreshData : null,
          loadBottomData: bloc.isInfinite ? _loadNextPage : null,
          loadTopData: null,
          isLoading: state is BlocxCollectionStateLoading<Entity>,
          isEmpty: state.list.isEmpty,
          scrollController: scrollCtrl,
          sliverTop: widget.sliverTopWidget?.call(context, state),
          sliverBottom: widget.sliverBottomWidget?.call(context, state),
          loadMoreWidgetBuilder: widget.loadMoreWidgetBuilder,
          refreshWidgetBuilder: widget.refreshWidgetBuilder,
          loading: widget.loadingWidget?.call(context, state) ??
              _defaultLoadingWidget(context, state),
          empty: widget.emptyWidget?.call(context, state) ??
              _defaultEmptyWidget(context, state),
        );

      case CollectionWidgetStateType.grid:
        return InfiniteGrid<Entity>(
          options: opts.asOrThrow<InfiniteGridOptions>(),
          items: state.list,
          itemBuilder: widget.itemBuilder,
          bloc: bloc.infiniteListBloc,
          scrollController: scrollCtrl,
          refreshOnSwipe: bloc.isRefreshable ? _refreshData : null,
          loadBottomData: bloc.isInfinite ? _loadNextPage : null,
          loadMoreWidgetBuilder: widget.loadMoreWidgetBuilder,
          refreshWidgetBuilder: widget.refreshWidgetBuilder,
        );

      case CollectionWidgetStateType.sliverGrid:
        return SliverInfiniteGrid<Entity>(
          options: opts.asOrThrow<SliverInfiniteGridOptions>(),
          items: state.list,
          itemBuilder: widget.itemBuilder,
          bloc: bloc.infiniteListBloc,
          scrollController: scrollCtrl,
          refreshOnSwipe: bloc.isRefreshable ? _refreshData : null,
          loadBottomData: bloc.isInfinite ? _loadNextPage : null,
          loadMoreWidgetBuilder: widget.loadMoreWidgetBuilder,
          refreshWidgetBuilder: widget.refreshWidgetBuilder,
        );
    }
  }

  Widget _buildWrapper(
      BuildContext context, BlocxCollectionState<Entity> state) {
    final top = widget.topWidget?.call(context, state);
    final bottom = widget.bottomWidget?.call(context, state);
    final isErrorState = state is BlocxCollectionStateError<Entity>;
    final isLoadingOrSearching =
        (state is BlocxCollectionStateLoading<Entity>) || state.isSearching;
    final isEmpty =
        !isLoadingOrSearching && !isErrorState && state.list.isEmpty;

    final Widget coreBox;
    if (isErrorState && state.list.isEmpty) {
      coreBox = widget.errorWidget?.call(context, state) ??
          _defaultErrorWidget(context, state);
    } else if (isLoadingOrSearching) {
      coreBox = widget.loadingWidget?.call(context, state) ??
          _defaultLoadingWidget(context, state);
    } else if (isEmpty) {
      coreBox = widget.emptyWidget?.call(context, state) ??
          _defaultEmptyWidget(context, state);
    } else {
      coreBox = _buildCollectionWidget(context, state);
    }

    final settings = _effectiveSettings;
    final children = <Widget>[
      if (top != null) top,
      if (top != null) SizedBox(height: widget.topBottomAndListSpacing),
      settings.options.shrinkWrap ? coreBox : Expanded(child: coreBox),
      if (bottom != null) SizedBox(height: widget.topBottomAndListSpacing),
      if (bottom != null) bottom,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocxCollectionBloc<Entity, Payload>>.value(
      value: widget.bloc,
      child: BlocConsumer<BlocxCollectionBloc<Entity, Payload>,
          BlocxCollectionState<Entity>>(
        buildWhen: (_, current) => current.shouldRebuild,
        listenWhen: (_, current) => current.shouldListen,
        listener: _handleListener,
        builder: widget.wrapperBuilder ?? _buildWrapper,
      ),
    );
  }
}
