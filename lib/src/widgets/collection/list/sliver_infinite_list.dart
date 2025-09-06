import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter/src/widgets/collection/options/sliver_infinite_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SliverInfiniteList<Entity extends BaseEntity> extends StatefulWidget {
  final SliverInfiniteListOptions options;
  final List<Entity> items;
  final InfiniteListBloc bloc;
  final Widget Function(BuildContext context, Entity item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final void Function()? loadBottomData;
  final void Function()? loadTopData;
  final void Function()? refreshOnSwipe;
  final ScrollController? scrollController;
  final Widget? Function(BuildContext context, bool isLoadingMore)? loadMoreWidgetBuilder;
  final Widget? Function(BuildContext context, double swipeRefreshHeight)? refreshWidgetBuilder;
  final Widget? Function(BuildContext context)? topWidgetBuilder;
  final Widget? Function(BuildContext context)? bottomWidgetBuilder;

  const SliverInfiniteList({
    super.key,
    required this.options,
    required this.items,
    required this.itemBuilder,
    required this.bloc,
    this.separatorBuilder,
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
  SliverInfiniteListWidgetState<Entity> createState() => SliverInfiniteListWidgetState<Entity>();
}

class SliverInfiniteListWidgetState<Entity extends BaseEntity> extends State<SliverInfiniteList<Entity>> {
  late final String uuid;

  late final ScrollController _internalController = ScrollController();

  InfiniteListBloc get bloc => widget.bloc;
  SliverInfiniteListOptions get options => widget.options;

  ScrollController get effectiveController => widget.scrollController ?? _internalController;

  @override
  void initState() {
    super.initState();
    uuid = 'SliverInfiniteList-${identityHashCode(this)}';
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
                physics: options.scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
                reverse: options.reverse,
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

    final listSliver = _sliverList(context, state);
    if (options.padding != null) {
      slivers.add(SliverPadding(padding: options.padding!, sliver: listSliver));
    } else {
      slivers.add(listSliver);
    }

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

  void onVisibilityChanged(VisibilityInfo c, InfiniteListState state) {
    if (c.visibleFraction < 0.5 ||
        state.isLoadingMore ||
        widget.loadBottomData == null ||
        state.isScrollingUp) {
      return;
    }
    bloc.setLoadingBottomStatus(true);
    widget.loadBottomData!();
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
          : const SizedBox(),
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

  void blocListener(BuildContext context, InfiniteListState state) {
    if (state is InfiniteListStateRefresh) {
      widget.refreshOnSwipe?.call();
    }
  }

  Widget wrapInAutoScrollTag(Widget itemWidget, Entity data, int index) {
    if (effectiveController is! AutoScrollController) return itemWidget;
    return AutoScrollTag(
      key: ValueKey(data.identifier),
      controller: effectiveController as AutoScrollController,
      index: index,
      child: itemWidget,
    );
  }

  Widget _itemBuilder(BuildContext context, Entity data, InfiniteListState state) {
    final index = widget.items.indexOf(data);
    final isBottomLoadingTrigger =
        index == (widget.items.length - options.loadMoreTriggerItemDistance) && !state.hasReachedEnd;

    Widget itemWidget = widget.itemBuilder(context, data);

    if (isBottomLoadingTrigger && !state.hasReachedEnd) {
      return VisibilityDetector(
        key: Key("$uuid-LoadMore-$index"),
        onVisibilityChanged: (c) => onVisibilityChanged(c, state),
        child: itemWidget,
      );
    }

    itemWidget = wrapInAutoScrollTag(itemWidget, data, index);
    return itemWidget;
  }

  Widget _sliverList(BuildContext context, InfiniteListState state) {
    final hasSeparator = widget.separatorBuilder != null;
    final childCount = hasSeparator
        ? (widget.items.isEmpty ? 0 : widget.items.length * 2 - 1)
        : widget.items.length;

    defaultSemanticIndexCallback(Widget _, int index) {
      if (!hasSeparator) return index;
      return index.isEven ? index ~/ 2 : null;
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (c, i) {
          if (!hasSeparator) {
            return _itemBuilder(c, widget.items[i], state);
          }
          if (i.isEven) {
            final itemIndex = i ~/ 2;
            return _itemBuilder(c, widget.items[itemIndex], state);
          } else {
            final sepIndex = (i - 1) ~/ 2;
            return widget.separatorBuilder!(c, sepIndex);
          }
        },
        childCount: childCount,
        addAutomaticKeepAlives: options.addAutomaticKeepAlives,
        addRepaintBoundaries: options.addRepaintBoundaries,
        addSemanticIndexes: options.addSemanticIndexes,
        semanticIndexCallback: options.semanticIndexCallback ?? defaultSemanticIndexCallback,
        semanticIndexOffset: options.semanticIndexOffset,
      ),
    );
  }
}
