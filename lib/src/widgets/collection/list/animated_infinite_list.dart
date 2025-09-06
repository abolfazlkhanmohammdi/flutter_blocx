import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter/src/widgets/collection/options/animated_infinite_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimatedInfiniteList<Entity extends BaseEntity> extends StatefulWidget {
  final AnimatedInfiniteListOptions options;

  final List<Entity> items;
  final InfiniteListBloc bloc;

  final Widget Function(BuildContext context, Entity item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder; // ignored here

  final AnimatedChildBuilder? deleteAnimation;
  final AnimatedChildBuilder? insertAnimation;

  final void Function()? loadBottomData;
  final void Function()? loadTopData;
  final void Function()? refreshOnSwipe;

  final ScrollController? scrollController;
  final Widget? Function(BuildContext context, bool isLoadingMore)? loadMoreWidgetBuilder;
  final Widget? Function(BuildContext context, double swipeRefreshHeight)? refreshWidgetBuilder;

  const AnimatedInfiniteList({
    super.key,
    required this.options,
    required this.items,
    required this.itemBuilder,
    required this.bloc,
    this.separatorBuilder, // not used by animated list
    this.deleteAnimation,
    this.insertAnimation,
    this.refreshOnSwipe,
    this.loadBottomData,
    this.loadTopData,
    this.scrollController,
    this.loadMoreWidgetBuilder,
    this.refreshWidgetBuilder,
  });

  @override
  AnimatedInfiniteListState<Entity> createState() => AnimatedInfiniteListState<Entity>();
}

class AnimatedInfiniteListState<Entity extends BaseEntity> extends State<AnimatedInfiniteList<Entity>> {
  late final String uuid;
  late final ScrollController scrollController = widget.scrollController ?? ScrollController();

  InfiniteListBloc get bloc => widget.bloc;
  AnimatedInfiniteListOptions get options => widget.options;

  @override
  void initState() {
    super.initState();
    uuid = 'AnimatedInfiniteList-${identityHashCode(this)}';
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.scrollController == null) scrollController.dispose();
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
                    child: _animatedList(context, state),
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

  bool get _atTopByController =>
      widget.scrollController?.hasClients == true && widget.scrollController!.position.pixels <= 0.0;

  bool get _atBottomByController =>
      widget.scrollController?.hasClients == true &&
      (widget.scrollController!.position.pixels >= widget.scrollController!.position.maxScrollExtent - 1.0);

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
    return AutoScrollTag(
      key: ValueKey(data.identifier),
      controller: widget.scrollController as AutoScrollController,
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
        key: Key("$uuid-LoadMore"),
        onVisibilityChanged: (c) => onVisibilityChanged(c, state),
        child: itemWidget,
      );
    }

    if (widget.scrollController is AutoScrollController) {
      itemWidget = wrapInAutoScrollTag(itemWidget, data, index);
    }

    return itemWidget;
  }

  Widget _animatedList(BuildContext context, InfiniteListState state) {
    return ImplicitlyAnimatedList<Entity>(
      controller: scrollController,
      initialAnimation: options.animateAtStart,
      physics: options.scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
      itemData: widget.items,
      shrinkWrap: options.shrinkWrap,
      padding: options.padding,
      reverse: options.reverse,
      insertAnimation: widget.insertAnimation ?? _defaultAnimation,
      deleteAnimation: widget.deleteAnimation ?? _defaultAnimation,
      itemBuilder: (c, item) => _itemBuilder(c, item, state),
      itemEquality: (BaseEntity f, BaseEntity s) => f.identifier == s.identifier,
    );
  }

  Widget _defaultAnimation(BuildContext context, Widget child, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: _driveDefaultAnimation(animation),
      child: FadeTransition(opacity: _driveDefaultAnimation(animation), child: child),
    );
  }

  Animation<double> _driveDefaultAnimation(Animation<double> parent) {
    return CurvedAnimation(
      parent: parent,
      curve: Curves.easeInOutQuad,
    ).drive(Tween<double>(begin: 0, end: 1));
  }
}
