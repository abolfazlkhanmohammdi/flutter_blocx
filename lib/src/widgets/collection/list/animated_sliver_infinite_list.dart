import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart'
    show
        BlocxInfiniteListBloc,
        BlocxInfiniteListState,
        BlocxInfiniteListStateRefresh,
        BlocxInfiniteListEventVerticalDragUpdated,
        BlocxInfiniteListEventVerticalDragStarted,
        BlocxInfiniteListEventVerticalDragEnded,
        BlocxInfiniteListEventOnScroll;
import 'package:flutter/rendering.dart';
import 'package:flutter_blocx/src/widgets/collection/options/animated_sliver_infinite_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

Animation<double> _driveDefaultAnimation(Animation<double> parent) {
  return CurvedAnimation(parent: parent, curve: Curves.easeInOutQuad).drive(Tween<double>(begin: 0, end: 1));
}

Widget _defaultAnimation(BuildContext context, Widget child, Animation<double> animation) {
  return SizeTransition(
    sizeFactor: _driveDefaultAnimation(animation),
    child: FadeTransition(opacity: _driveDefaultAnimation(animation), child: child),
  );
}

class AnimatedSliverInfiniteList<Entity extends BlocxBaseEntity> extends StatefulWidget {
  final AnimatedSliverInfiniteListOptions options;

  final List<Entity> items;
  final BlocxInfiniteListBloc bloc;

  final Widget Function(BuildContext context, Entity item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  final VoidCallback? loadBottomData;
  final VoidCallback? loadTopData;
  final VoidCallback? refreshOnSwipe;

  final ScrollController? scrollController;
  final Widget? Function(BuildContext context, bool isLoadingMore)? loadMoreWidgetBuilder;
  final Widget? Function(BuildContext context, double swipeRefreshHeight)? refreshWidgetBuilder;
  final Widget loading;
  final Widget empty;
  final bool? isLoading;
  final bool? isEmpty;
  final Widget? sliverTop;
  final Widget? sliverBottom;

  const AnimatedSliverInfiniteList({
    super.key,
    required this.options,
    required this.items,
    required this.itemBuilder,
    required this.bloc,
    required this.loading,
    required this.empty,
    this.separatorBuilder,
    this.refreshOnSwipe,
    this.loadBottomData,
    this.loadTopData,
    this.scrollController,
    this.loadMoreWidgetBuilder,
    this.refreshWidgetBuilder,
    this.isLoading,
    this.isEmpty,
    this.sliverTop,
    this.sliverBottom,
  });

  @override
  AnimatedSliverBlocxInfiniteListState<Entity> createState() =>
      AnimatedSliverBlocxInfiniteListState<Entity>();
}

class AnimatedSliverBlocxInfiniteListState<Entity extends BlocxBaseEntity>
    extends State<AnimatedSliverInfiniteList<Entity>> {
  late final String uuid = 'AnimatedSliverInfiniteList-${identityHashCode(this)}';
  late final ScrollController _internalController = ScrollController();

  BlocxInfiniteListBloc get bloc => widget.bloc;
  AnimatedSliverInfiniteListOptions get options => widget.options;
  ScrollController get effectiveController => widget.scrollController ?? _internalController;

  @override
  void dispose() {
    if (widget.scrollController == null) _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocxInfiniteListBloc>.value(
      value: widget.bloc,
      child: BlocConsumer<BlocxInfiniteListBloc, BlocxInfiniteListState>(
        bloc: widget.bloc,
        listenWhen: (_, s) => s.shouldListen,
        buildWhen: (_, s) => s.shouldRebuild,
        listener: (context, state) {
          if (state is BlocxInfiniteListStateRefresh) {
            widget.refreshOnSwipe?.call();
          }
        },
        builder: (context, state) {
          final bool showLoading = widget.isLoading ?? false;
          final bool showEmpty = !showLoading && (widget.isEmpty ?? widget.items.isEmpty);
          final slivers = <Widget>[];

          if (widget.sliverTop != null) {
            slivers.add(widget.sliverTop!);
          }

          final refresh = _buildSwipeRefresh(context, state);
          if (refresh != null) {
            slivers.add(SliverToBoxAdapter(child: refresh));
          }
          if (showLoading || showEmpty) {
            slivers.add(SliverFillRemaining(child: showLoading ? widget.loading : widget.empty));
          } else {
            final core = _buildAnimatedList(context, state);
            slivers.add(_maybePad(core, options.padding));
          }

          final bottomLoader = _buildLoadMore(context, state);
          if (bottomLoader != null) {
            slivers.add(SliverToBoxAdapter(child: bottomLoader));
          }

          if (widget.sliverBottom != null) {
            slivers.add(widget.sliverBottom!);
          }

          return NotificationListener<UserScrollNotification>(
            onNotification: (n) => _onScroll(n),
            child: Listener(
              onPointerDown: (d) =>
                  bloc.add(BlocxInfiniteListEventVerticalDragStarted(globalY: d.position.dy)),
              onPointerUp: (_) => bloc.add(BlocxInfiniteListEventVerticalDragEnded()),
              onPointerMove: _maySwipe(state)
                  ? (d) => bloc.add(BlocxInfiniteListEventVerticalDragUpdated(globalY: d.position.dy))
                  : null,
              onPointerCancel: _maySwipe(state)
                  ? (_) => bloc.add(BlocxInfiniteListEventVerticalDragUpdated(globalY: null))
                  : null,
              child: CustomScrollView(
                controller: effectiveController,
                reverse: options.reverse,
                physics: options.scrollPhysics,
                slivers: slivers,
              ),
            ),
          );
        },
      ),
    );
  }

  bool _onScroll(UserScrollNotification n) {
    final isIdle = n.direction == ScrollDirection.idle;
    final isAtTop = n.metrics.extentBefore <= 0.0;
    final isAtBottom = n.metrics.extentAfter <= 0.0;

    final isScrollingUp = options.reverse
        ? (!isIdle && n.direction == ScrollDirection.reverse)
        : (!isIdle && n.direction == ScrollDirection.forward);

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

  bool get _atTopByController => effectiveController.hasClients && effectiveController.position.pixels <= 0.0;

  bool get _atBottomByController =>
      effectiveController.hasClients &&
      (effectiveController.position.pixels >= effectiveController.position.maxScrollExtent - 1.0);

  bool _atRefreshEdge(BlocxInfiniteListState state) =>
      options.reverse ? (state.isAtBottom || _atBottomByController) : (state.isAtTop || _atTopByController);

  bool _maySwipe(BlocxInfiniteListState state) =>
      _atRefreshEdge(state) && !state.isRefreshing && widget.refreshOnSwipe != null;

  Widget? _buildSwipeRefresh(BuildContext context, BlocxInfiniteListState state) {
    final external = widget.refreshWidgetBuilder?.call(context, state.swipeRefreshHeight);
    if (external != null) return external;

    if (state.swipeRefreshHeight <= 0) return null;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      color: primary,
      height: state.swipeRefreshHeight,
      child: const Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }

  Widget? _buildLoadMore(BuildContext context, BlocxInfiniteListState state) {
    final external = widget.loadMoreWidgetBuilder?.call(context, state.isLoadingMore);
    if (external != null) return external;

    if (!state.isLoadingMore) return null;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      color: scheme.primary,
      child: Center(
        child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: scheme.onPrimary)),
      ),
    );
  }

  Widget _maybePad(Widget sliver, EdgeInsets? padding) {
    if (padding == null) return sliver;
    return SliverPadding(padding: padding, sliver: sliver);
  }

  void _onVisibilityChanged(VisibilityInfo c, BlocxInfiniteListState state) {
    if (c.visibleFraction < 0.5 ||
        state.isLoadingMore ||
        widget.loadBottomData == null ||
        state.isScrollingUp) {
      return;
    }
    bloc.setLoadingBottomStatus(true);
    widget.loadBottomData!.call();
  }

  Widget _wrapInAutoScrollTag(Widget child, Entity data, int index) {
    final c = effectiveController;
    if (c is! AutoScrollController) return child;
    return AutoScrollTag(key: ValueKey(data.identifier), controller: c, index: index, child: child);
  }

  Widget _animatedItemWithOptionalSeparator(BuildContext context, Entity data, BlocxInfiniteListState state) {
    final index = widget.items.indexOf(data);

    final isBottomLoadingTrigger =
        index == (widget.items.length - options.loadMoreTriggerItemDistance) && !state.hasReachedEnd;

    Widget child = widget.itemBuilder(context, data);

    if (widget.separatorBuilder != null && index < widget.items.length - 1) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [child, widget.separatorBuilder!(context, index)],
      );
    }

    if (isBottomLoadingTrigger && !state.hasReachedEnd) {
      child = VisibilityDetector(
        key: Key("${uuid}_LoadMore_$index"),
        onVisibilityChanged: (c) => _onVisibilityChanged(c, state),
        child: child,
      );
    }

    return _wrapInAutoScrollTag(child, data, index);
  }

  Widget _buildAnimatedList(BuildContext context, BlocxInfiniteListState state) {
    return SliverImplicitlyAnimatedList<Entity>(
      itemData: widget.items,
      itemBuilder: (c, data) => _animatedItemWithOptionalSeparator(c, data, state),
      itemEquality: (a, b) => a.identifier == b.identifier,
      initialAnimation: options.initialAnimation,
      insertDuration: options.insertDuration,
      deleteDuration: options.deleteDuration,
      insertAnimation: options.insertAnimation ?? _defaultAnimation,
      deleteAnimation: options.deleteAnimation ?? _defaultAnimation,
    );
  }
}
