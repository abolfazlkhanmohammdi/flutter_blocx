import 'package:blocx_core/blocx_core.dart';
import 'package:flutter_blocx/src/widgets/collection/options/infinite_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// InfiniteGrid
/// -------------
/// A grid-based equivalent of your InfiniteList with the same interaction model:
/// - Uses the provided `InfiniteListBloc` for scroll/refresh/load-more signals
/// - Triggers `loadBottomData` when the user nears the end
/// - Optional swipe-to-refresh (custom, like your list)
/// - Supports `AutoScrollController` via `AutoScrollTag`
///
/// Differences from list version:
/// - Uses `GridView.builder` with a configurable grid delegate
/// - No third-party animated grid. For simple entry effects, wrap your
///   `itemBuilder` content in an `AnimatedSwitcher`/`FadeTransition` yourself.
class InfiniteGrid<Entity extends BaseEntity> extends StatefulWidget {
  final InfiniteGridOptions options;
  final Widget Function(BuildContext context, Entity item) itemBuilder;

  /// Grid-specific builder for a custom SliverGridDelegate.
  /// If null, a default delegate is created from [options].
  final SliverGridDelegate Function(InfiniteGridOptions options)? gridDelegateBuilder;

  final InfiniteListBloc bloc;
  final void Function()? loadBottomData;
  final void Function()? loadTopData; // kept for API parity; not used directly
  final void Function()? refreshOnSwipe;
  final List<Entity> items;
  final ScrollController? scrollController;
  final Widget? Function(BuildContext context, bool isLoadingMore)? loadMoreWidgetBuilder;
  final Widget? Function(BuildContext context, double swipeRefreshHeight)? refreshWidgetBuilder;

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

class InfiniteGridState<Entity extends BaseEntity> extends State<InfiniteGrid<Entity>> {
  late final String uuid;

  @override
  void initState() {
    super.initState();
    uuid = 'InfiniteGrid-${identityHashCode(this)}';
  }

  InfiniteListBloc get bloc => widget.bloc;
  InfiniteGridOptions get options => widget.options;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfiniteListBloc>.value(
      value: widget.bloc,
      child: BlocConsumer<InfiniteListBloc, InfiniteListState>(
        listener: blocListener,
        bloc: widget.bloc,
        buildWhen: (_, c) => c.shouldRebuild,
        builder: (BuildContext context, InfiniteListState state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              options.reverse ? loadMoreWidget(context, state) : swipeRefreshWidget(context, state),
              Expanded(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: onScroll,
                  child: Listener(
                    onPointerDown: (d) =>
                        bloc.add(InfiniteListEventVerticalDragStarted(globalY: d.position.dy)),
                    onPointerUp: (d) => bloc.add(InfiniteListEventVerticalDragEnded()),
                    onPointerMove: maySwipe
                        ? (d) => bloc.add(InfiniteListEventVerticalDragUpdated(globalY: d.position.dy))
                        : null,
                    onPointerCancel: maySwipe
                        ? (_) => bloc.add(InfiniteListEventVerticalDragUpdated(globalY: null))
                        : null,
                    child: gridWidget(context, state),
                  ),
                ),
              ),
              options.reverse ? swipeRefreshWidget(context, state) : loadMoreWidget(context, state),
            ],
          );
        },
      ),
    );
  }

  bool get maySwipe {
    final s = bloc.state;
    return s.isAtTop && s.isScrollingUp && !s.isRefreshing && widget.refreshOnSwipe != null;
  }

  void blocListener(BuildContext context, InfiniteListState state) {
    if (state is InfiniteListStateRefresh) {
      widget.refreshOnSwipe?.call();
    }
  }

  bool onScroll(UserScrollNotification notification) {
    final isIdle = notification.direction == ScrollDirection.idle;
    final isScrollingUp = !isIdle && notification.direction == ScrollDirection.forward;
    final isAtTop = notification.metrics.pixels < 40;
    final isAtBottom = notification.metrics.pixels == notification.metrics.maxScrollExtent;
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

  Widget gridWidget(BuildContext context, InfiniteListState state) {
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
      physics: options.scrollPhysics,
      shrinkWrap: options.shrinkWrap,
      padding: options.padding,
      reverse: options.reverse,
      gridDelegate: delegate,
      itemCount: widget.items.length,
      itemBuilder: (c, i) => _itemBuilder(c, widget.items[i], i, state),
    );
  }

  Widget _itemBuilder(BuildContext context, Entity data, int index, InfiniteListState state) {
    final isBottomTrigger =
        index == (widget.items.length - options.loadMoreTriggerItemDistance) && !state.hasReachedEnd;

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

    if (isBottomTrigger && !state.hasReachedEnd) {
      return VisibilityDetector(
        key: Key("$uuid-LoadMore-$index"),
        onVisibilityChanged: (c) => onVisibilityChanged(c, state),
        child: child,
      );
    }

    return child;
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
