import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart'
    show
        BlocxInfiniteListBloc,
        BlocxInfiniteListState,
        BlocxInfiniteListStateRefresh,
        BlocxInfiniteListEventVerticalDragUpdated,
        BlocxInfiniteListEventVerticalDragStarted,
        BlocxInfiniteListEventVerticalDragEnded,
        BlocxInfiniteListEventOnScroll;
import 'package:flutter_blocx/src/widgets/collection/options/infinite_grid_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// InfiniteGrid
/// -------------
/// A grid-based equivalent of your InfiniteList with the same interaction model:
/// - Uses the provided `BlocxInfiniteListBloc` for scroll/refresh/load-more signals
/// - Triggers `loadBottomData` when the user nears the end
/// - Optional swipe-to-refresh (custom, like your list)
/// - Supports `AutoScrollController` via `AutoScrollTag`
///
/// Differences from list version:
/// - Uses `GridView.builder` with a configurable grid delegate
/// - No third-party animated grid. For simple entry effects, wrap your
///   `itemBuilder` content in an `AnimatedSwitcher`/`FadeTransition` yourself.
class InfiniteGrid<Entity extends BlocxBaseEntity> extends StatefulWidget {
  final InfiniteGridOptions options;
  final Widget Function(BuildContext context, Entity item) itemBuilder;

  /// Grid-specific builder for a custom SliverGridDelegate.
  /// If null, a default delegate is created from [options].
  final SliverGridDelegate Function(InfiniteGridOptions options)?
  gridDelegateBuilder;

  final BlocxInfiniteListBloc bloc;
  final void Function()? loadBottomData;
  final void Function()? loadTopData; // kept for API parity; not used directly
  final void Function()? refreshOnSwipe;
  final List<Entity> items;
  final ScrollController? scrollController;
  final Widget? Function(BuildContext context, bool isLoadingMore)?
  loadMoreWidgetBuilder;
  final Widget? Function(BuildContext context, double swipeRefreshHeight)?
  refreshWidgetBuilder;

  const InfiniteGrid({
    super.key,
    required this.options,
    required this.items,
    required this.itemBuilder,
    required this.bloc,
    this.gridDelegateBuilder,
    this.refreshWidgetBuilder,
    this.loadMoreWidgetBuilder,
    this.refreshOnSwipe,
    this.loadBottomData,
    this.loadTopData,
    this.scrollController,
  });

  @override
  InfiniteGridState<Entity> createState() => InfiniteGridState<Entity>();
}

class InfiniteGridState<Entity extends BlocxBaseEntity>
    extends State<InfiniteGrid<Entity>> {
  static const double _edgeTolerance = 1.0;

  late final String uuid;

  bool _isTrackingRefreshDrag = false;
  double? _refreshDragStartY;

  @override
  void initState() {
    super.initState();
    uuid = 'InfiniteGrid-${identityHashCode(this)}';
  }

  BlocxInfiniteListBloc get bloc => widget.bloc;
  InfiniteGridOptions get options => widget.options;

  // ── scroll-controller edge helpers ──────────────────────────────────────────

  bool get _atTopByController {
    final c = widget.scrollController;
    if (c == null || !c.hasClients) return false;
    return c.position.pixels <= c.position.minScrollExtent + _edgeTolerance;
  }

  bool get _atBottomByController {
    final c = widget.scrollController;
    if (c == null || !c.hasClients) return false;
    return c.position.pixels >= c.position.maxScrollExtent - _edgeTolerance;
  }

  bool get _atRefreshEdge {
    final c = widget.scrollController;
    if (c != null && c.hasClients) {
      return options.reverse ? _atBottomByController : _atTopByController;
    }
    return options.reverse ? bloc.state.isAtBottom : bloc.state.isAtTop;
  }

  bool get _canStartRefreshDrag {
    return widget.refreshOnSwipe != null &&
        !bloc.state.isRefreshing &&
        _atRefreshEdge;
  }

  // ── pointer handlers ─────────────────────────────────────────────────────────

  void _onPointerDown(PointerDownEvent event) {
    if (!_canStartRefreshDrag) {
      _cancelLocalRefreshTracking();
      return;
    }

    _isTrackingRefreshDrag = true;
    _refreshDragStartY = event.position.dy;

    bloc.add(
      BlocxInfiniteListEventVerticalDragStarted(globalY: event.position.dy),
    );
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isTrackingRefreshDrag) return;

    final startY = _refreshDragStartY;
    if (startY == null) {
      _cancelLocalRefreshTracking();
      return;
    }

    final currentY = event.position.dy;

    // A normal grid refreshes by pulling downward.
    // A reversed grid refreshes from the opposite edge by pulling upward.
    final isMovingTowardRefreshEdge = options.reverse
        ? currentY <= startY
        : currentY >= startY;

    // Sending the original start coordinate collapses the indicator to zero
    // when the user moves in the wrong direction.
    final effectiveY = isMovingTowardRefreshEdge ? currentY : startY;

    bloc.add(BlocxInfiniteListEventVerticalDragUpdated(globalY: effectiveY));
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_isTrackingRefreshDrag) return;
    _cancelLocalRefreshTracking();
    bloc.add(BlocxInfiniteListEventVerticalDragEnded());
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_isTrackingRefreshDrag) return;
    _cancelLocalRefreshTracking();
    // A cancelled pointer must reset the pull indicator without triggering refresh.
    bloc.hideRefreshWidget();
  }

  void _cancelLocalRefreshTracking() {
    _isTrackingRefreshDrag = false;
    _refreshDragStartY = null;
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocxInfiniteListBloc>.value(
      value: widget.bloc,
      child: BlocConsumer<BlocxInfiniteListBloc, BlocxInfiniteListState>(
        listener: blocListener,
        bloc: widget.bloc,
        buildWhen: (_, c) => c.shouldRebuild,
        builder: (BuildContext context, BlocxInfiniteListState state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              options.reverse
                  ? loadMoreWidget(context, state)
                  : swipeRefreshWidget(context, state),
              Expanded(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: onScroll,
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: _onPointerCancel,
                    child: gridWidget(context, state),
                  ),
                ),
              ),
              options.reverse
                  ? swipeRefreshWidget(context, state)
                  : loadMoreWidget(context, state),
            ],
          );
        },
      ),
    );
  }

  void blocListener(BuildContext context, BlocxInfiniteListState state) {
    if (state is BlocxInfiniteListStateRefresh) {
      widget.refreshOnSwipe?.call();
    }
  }

  bool onScroll(UserScrollNotification notification) {
    final isIdle = notification.direction == ScrollDirection.idle;
    final isAtTop = notification.metrics.extentBefore <= _edgeTolerance;
    final isAtBottom = notification.metrics.extentAfter <= _edgeTolerance;

    final bool isScrollingUp;
    if (options.reverse) {
      isScrollingUp =
          !isIdle && notification.direction == ScrollDirection.reverse;
    } else {
      isScrollingUp =
          !isIdle && notification.direction == ScrollDirection.forward;
    }

    bloc.add(
      BlocxInfiniteListEventOnScroll(
        isAtTop: isAtTop,
        isScrollingUp: isScrollingUp,
        isAtBottom: isAtBottom,
        isIdle: isIdle,
      ),
    );
    return false;
  }

  Widget gridWidget(BuildContext context, BlocxInfiniteListState state) {
    final delegate =
        widget.gridDelegateBuilder?.call(options) ??
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: options.crossAxisCount,
          mainAxisSpacing: options.mainAxisSpacing,
          crossAxisSpacing: options.crossAxisSpacing,
          childAspectRatio: options.childAspectRatio,
        );

    return GridView.builder(
      controller: widget.scrollController,
      physics: options.scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: options.shrinkWrap,
      padding: options.padding,
      reverse: options.reverse,
      gridDelegate: delegate,
      itemCount: widget.items.length,
      itemBuilder: (c, i) => _itemBuilder(c, widget.items[i], i, state),
    );
  }

  Widget _itemBuilder(
    BuildContext context,
    Entity data,
    int index,
    BlocxInfiniteListState state,
  ) {
    final isBottomTrigger =
        index == (widget.items.length - options.loadMoreTriggerItemDistance) &&
        !state.hasReachedEnd;

    Widget child = widget.itemBuilder(context, data);

    // Optional AutoScrollTag support
    if (widget.scrollController is AutoScrollController) {
      child = AutoScrollTag(
        key: ValueKey(data.identifier),
        controller: widget.scrollController as AutoScrollController,
        index: index,
        child: child,
      );
    }

    if (isBottomTrigger) {
      return VisibilityDetector(
        key: Key("$uuid-LoadMore-$index"),
        onVisibilityChanged: (c) => onVisibilityChanged(c, state),
        child: child,
      );
    }

    return child;
  }

  void onVisibilityChanged(VisibilityInfo c, BlocxInfiniteListState state) {
    if (c.visibleFraction < 0.5 ||
        state.isLoadingMore ||
        widget.loadBottomData == null ||
        state.isScrollingUp) {
      return;
    }
    bloc.setLoadingBottomStatus(true);
    widget.loadBottomData!.call();
  }

  Widget loadMoreWidget(BuildContext context, BlocxInfiniteListState state) {
    final external = widget.loadMoreWidgetBuilder?.call(
      context,
      state.isLoadingMore,
    );
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

  Widget swipeRefreshWidget(
    BuildContext context,
    BlocxInfiniteListState state,
  ) {
    if (widget.refreshOnSwipe == null || state.swipeRefreshHeight <= 0) {
      return const SizedBox.shrink();
    }
    final external = widget.refreshWidgetBuilder?.call(
      context,
      state.swipeRefreshHeight,
    );
    if (external != null) return external;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      color: primary,
      height: state.swipeRefreshHeight,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
