import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter/src/widgets/collection/options/animated_sliver_infinite_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

class AnimatedSliverInfiniteList<Entity extends BaseEntity> extends StatefulWidget {
  final AnimatedSliverInfiniteListOptions options;

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

  const AnimatedSliverInfiniteList({
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
  AnimatedSliverInfiniteListState<Entity> createState() => AnimatedSliverInfiniteListState<Entity>();
}

class AnimatedSliverInfiniteListState<Entity extends BaseEntity>
    extends State<AnimatedSliverInfiniteList<Entity>> {
  late final String uuid = 'AnimatedSliverInfiniteList-${identityHashCode(this)}';
  late final ScrollController _internalController = ScrollController();

  InfiniteListBloc get bloc => widget.bloc;
  AnimatedSliverInfiniteListOptions get options => widget.options;
  ScrollController get effectiveController => widget.scrollController ?? _internalController;

  @override
  void dispose() {
    if (widget.scrollController == null) _internalController.dispose();
    super.dispose();
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

    final listSliver = _sliverAnimatedList(context, state);
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

  bool get _atRefreshEdge => options.reverse
      ? (bloc.state.isAtBottom || _atBottomByController)
      : (bloc.state.isAtTop || _atTopByController);

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

    final isScrollingUp = options.reverse
        ? (!isIdle && n.direction == ScrollDirection.reverse)
        : (!isIdle && n.direction == ScrollDirection.forward);

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

  void blocListener(BuildContext context, InfiniteListState state) {
    if (state is InfiniteListStateRefresh) {
      widget.refreshOnSwipe?.call();
    }
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

  Widget wrapInAutoScrollTag(Widget child, Entity data, int index) {
    final c = effectiveController;
    if (c is! AutoScrollController) return child;
    return AutoScrollTag(key: ValueKey(data.identifier), controller: c, index: index, child: child);
  }

  Widget _animatedItemWithOptionalSeparator(BuildContext context, Entity data, InfiniteListState state) {
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
        key: Key("$uuid-LoadMore-$index"),
        onVisibilityChanged: (c) => onVisibilityChanged(c, state),
        child: child,
      );
    }

    return wrapInAutoScrollTag(child, data, index);
  }

  Widget _sliverAnimatedList(BuildContext context, InfiniteListState state) {
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
