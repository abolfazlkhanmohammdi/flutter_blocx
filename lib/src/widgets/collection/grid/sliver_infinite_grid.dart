import 'package:blocx_core/blocx_core.dart';
import 'package:flutter_blocx/src/widgets/collection/options/sliver_infinite_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SliverInfiniteGrid<Entity extends BaseEntity> extends StatefulWidget {
  final SliverInfiniteGridOptions options;
  final List<Entity> items;
  final InfiniteListBloc bloc;

  /// Builder for each grid item.
  final Widget Function(BuildContext context, Entity item) itemBuilder;

  /// (Optional) Provide your own grid delegate builder.
  /// If null, a `SliverGridDelegateWithFixedCrossAxisCount` is made from [options].
  final SliverGridDelegate Function(SliverInfiniteGridOptions options)? gridDelegateBuilder;

  /// Load-more / refresh / misc.
  final void Function()? loadBottomData;
  final void Function()? loadTopData; // kept for parity
  final void Function()? refreshOnSwipe;

  /// Scroll control
  final ScrollController? scrollController;

  /// Optional UI overrides
  final Widget? Function(BuildContext context, bool isLoadingMore)? loadMoreWidgetBuilder;
  final Widget? Function(BuildContext context, double swipeRefreshHeight)? refreshWidgetBuilder;

  /// Top/Bottom sliver builders (placed outside the grid sliver).
  final Widget? Function(BuildContext context)? topWidgetBuilder;
  final Widget? Function(BuildContext context)? bottomWidgetBuilder;

  const SliverInfiniteGrid({
    super.key,
    required this.options,
    required this.items,
    required this.itemBuilder,
    required this.bloc,
    this.gridDelegateBuilder,
    this.refreshOnSwipe,
    this.loadBottomData,
    this.loadTopData,
    this.scrollController,
    this.loadMoreWidgetBuilder,
    this.refreshWidgetBuilder,
    this.topWidgetBuilder,
    this.bottomWidgetBuilder,
  });

  @override
  SliverInfiniteGridState<Entity> createState() => SliverInfiniteGridState<Entity>();
}

class SliverInfiniteGridState<Entity extends BaseEntity> extends State<SliverInfiniteGrid<Entity>> {
  late final String uuid;
  late final ScrollController _internalController = ScrollController();

  InfiniteListBloc get bloc => widget.bloc;
  SliverInfiniteGridOptions get options => widget.options;

  ScrollController get effectiveController => widget.scrollController ?? _internalController;

  @override
  void initState() {
    super.initState();
    uuid = 'SliverInfiniteGrid-${identityHashCode(this)}';
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.scrollController == null) _internalController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfiniteListBloc>.value(
      value: widget.bloc,
      child: BlocConsumer<InfiniteListBloc, InfiniteListState>(
        bloc: widget.bloc,
        listener: blocListener,
        buildWhen: (_, c) => c.shouldRebuild,
        builder: (context, state) {
          return NotificationListener<UserScrollNotification>(
            onNotification: onScroll,
            child: Listener(
              onPointerDown: (d) => bloc.add(InfiniteListEventVerticalDragStarted(globalY: d.position.dy)),
              onPointerUp: (d) => bloc.add(InfiniteListEventVerticalDragEnded()),
              onPointerMove: maySwipe
                  ? (d) => bloc.add(InfiniteListEventVerticalDragUpdated(globalY: d.position.dy))
                  : null,
              onPointerCancel: maySwipe
                  ? (_) => bloc.add(InfiniteListEventVerticalDragUpdated(globalY: null))
                  : null,
              child: CustomScrollView(
                controller: effectiveController,
                scrollDirection: options.scrollDirection,
                reverse: options.reverse,
                primary: options.primary,
                physics: options.scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
                cacheExtent: options.cacheExtent,
                anchor: options.anchor,
                clipBehavior: options.clipBehavior,
                keyboardDismissBehavior: options.keyboardDismissBehavior,
                slivers: _buildSlivers(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context, InfiniteListState state) {
    final slivers = <Widget>[];

    // Top section
    if (widget.topWidgetBuilder != null) {
      final w = widget.topWidgetBuilder!(context);
      if (w != null) slivers.add(SliverToBoxAdapter(child: w));
    } else {
      slivers.add(
        SliverToBoxAdapter(
          child: options.reverse ? loadMoreWidget(context, state) : swipeRefreshWidget(context, state),
        ),
      );
    }

    // Grid section
    final gridSliver = _sliverGrid(context, state);
    if (options.gridPadding != null) {
      slivers.add(SliverPadding(padding: options.gridPadding!, sliver: gridSliver));
    } else {
      slivers.add(gridSliver);
    }

    // Bottom section
    if (widget.bottomWidgetBuilder != null) {
      final w = widget.bottomWidgetBuilder!(context);
      if (w != null) slivers.add(SliverToBoxAdapter(child: w));
    } else {
      slivers.add(
        SliverToBoxAdapter(
          child: options.reverse ? swipeRefreshWidget(context, state) : loadMoreWidget(context, state),
        ),
      );
    }

    return slivers;
  }

  bool get _atTopByController => effectiveController.hasClients && effectiveController.position.pixels <= 0.0;

  bool get _atBottomByController =>
      effectiveController.hasClients &&
      (effectiveController.position.pixels >= effectiveController.position.maxScrollExtent - 1.0);

  bool get _atRefreshEdge {
    return options.reverse
        ? (bloc.state.isAtBottom || _atBottomByController)
        : (bloc.state.isAtTop || _atTopByController);
  }

  bool get maySwipe => _atRefreshEdge && !bloc.state.isRefreshing && widget.refreshOnSwipe != null;

  void blocListener(BuildContext context, InfiniteListState state) {
    if (state is InfiniteListStateRefresh) {
      widget.refreshOnSwipe?.call();
    }
  }

  bool onScroll(UserScrollNotification n) {
    final isIdle = n.direction == ScrollDirection.idle;
    final isAtTop = n.metrics.extentBefore <= 0.0;
    final isAtBottom = n.metrics.extentAfter <= 0.0;

    bool isScrollingUp;
    if (options.reverse) {
      isScrollingUp = !isIdle && n.direction == ScrollDirection.reverse;
    } else {
      isScrollingUp = !isIdle && n.direction == ScrollDirection.forward;
    }

    bloc.add(
      InfiniteListEventOnScroll(
        isAtTop: isAtTop,
        isScrollingUp: isScrollingUp,
        isAtBottom: isAtBottom,
        isIdle: isIdle,
      ),
    );
    return false;
  }

  void onVisibilityChanged(VisibilityInfo c, InfiniteListState state) {
    if (c.visibleFraction < 0.5 ||
        state.isLoadingMore ||
        widget.loadBottomData == null ||
        state.isScrollingUp) {
      return;
    }
    bloc.setLoadingBottomStatus(true);
    widget.loadBottomData!.call();
  }

  Widget _sliverGrid(BuildContext context, InfiniteListState state) {
    final delegate =
        widget.gridDelegateBuilder?.call(options) ??
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: options.crossAxisCount,
          mainAxisSpacing: options.mainAxisSpacing,
          crossAxisSpacing: options.crossAxisSpacing,
          childAspectRatio: options.childAspectRatio,
        );

    return SliverGrid(
      gridDelegate: delegate,
      delegate: SliverChildBuilderDelegate(
        (c, index) {
          final data = widget.items[index];
          return _itemBuilder(c, data, index, state);
        },
        childCount: widget.items.length,
        addAutomaticKeepAlives: options.addAutomaticKeepAlives,
        addRepaintBoundaries: options.addRepaintBoundaries,
        addSemanticIndexes: options.addSemanticIndexes,
        semanticIndexCallback: options.semanticIndexCallback??_defaultSemanticIndexCallback,
        semanticIndexOffset: options.semanticIndexOffset,
      ),
    );
  }

  int? _defaultSemanticIndexCallback(Widget _, int index) => index;


  Widget _itemBuilder(BuildContext context, Entity data, int index, InfiniteListState state) {
    final isBottomTrigger =
        index == (widget.items.length - options.loadMoreTriggerItemDistance) && !state.hasReachedEnd;

    Widget child = widget.itemBuilder(context, data);

    // Optional AutoScrollTag
    if (effectiveController is AutoScrollController) {
      child = AutoScrollTag(
        key: ValueKey(data.identifier),
        controller: effectiveController as AutoScrollController,
        index: index,
        child: child,
      );
    }

    if (isBottomTrigger && !state.hasReachedEnd) {
      return VisibilityDetector(
        key: Key("$uuid-LoadMore-$index"),
        onVisibilityChanged: (c) => onVisibilityChanged(c, state),
        child: child,
      );
    }

    return child;
  }

  Widget loadMoreWidget(BuildContext context, InfiniteListState state) {
    final external = widget.loadMoreWidgetBuilder?.call(context, state.isLoadingMore);
    if (external != null) return external;
    final scheme = Theme.of(context).colorScheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: state.isLoadingMore
          ? Container(
              padding: const EdgeInsets.all(16),
              color: scheme.primary,
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: scheme.onPrimary),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget swipeRefreshWidget(BuildContext context, InfiniteListState state) {
    final external = widget.refreshWidgetBuilder?.call(context, state.swipeRefreshHeight);
    if (external != null) return external;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      color: primary,
      height: state.swipeRefreshHeight,
      child: const Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}

