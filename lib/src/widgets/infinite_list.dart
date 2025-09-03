import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

class InfiniteList<Entity extends BaseEntity> extends StatefulWidget {
  final InfiniteListOptions options;
  final Widget Function(BuildContext context, Entity item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final AnimatedChildBuilder? deleteAnimation;
  final AnimatedChildBuilder? insertAnimation;
  final InfiniteListBloc bloc;
  final void Function()? loadBottomData;
  final void Function()? loadTopData;
  final void Function()? refreshOnSwipe;
  final List<Entity> items;
  final ScrollController? scrollController;
  final Widget? Function(BuildContext context, bool isLoadingMore)? loadMoreWidgetBuilder;
  final Widget? Function(BuildContext context, double swipeRefreshHeight)? refreshWidgetBuilder;
  const InfiniteList({
    super.key,
    required this.options,
    required this.items,
    this.refreshWidgetBuilder,
    this.loadMoreWidgetBuilder,
    required this.itemBuilder,
    required this.bloc,
    this.separatorBuilder,
    this.deleteAnimation,
    this.insertAnimation,
    this.refreshOnSwipe,
    this.loadBottomData,
    this.loadTopData,
    this.scrollController,
  });

  @override
  InfiniteListWidgetState createState() => InfiniteListWidgetState<Entity>();
}

class InfiniteListWidgetState<Entity extends BaseEntity> extends State<InfiniteList<Entity>> {
  late final String uuid;

  late ScrollController scrollController = widget.scrollController ?? ScrollController();

  @override
  void initState() {
    super.initState();
    uuid = 'InfiniteList-${identityHashCode(this)}';
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.scrollController == null) scrollController.dispose();
  }

  InfiniteListBloc get bloc => widget.bloc;
  InfiniteListOptions get options => widget.options;
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
                    child: listWidget(context, state),
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

  // was: atTop && isScrollingUp && !isRefreshing && refreshOnSwipe!=null
  bool get maySwipe => _atRefreshEdge && !bloc.state.isRefreshing && widget.refreshOnSwipe != null;

  // bool get maySwipe {
  //   final cond1 = bloc.state.isAtTop;
  //   final cond2 = bloc.state.isScrollingUp;
  //   final cond3 = !bloc.state.isRefreshing;
  //   final cond4 = widget.refreshOnSwipe != null;
  //   final result = cond1 && cond2 && cond3 && cond4;
  //   return result;
  // }

  Widget _itemBuilder(BuildContext context, Entity data, InfiniteListState state) {
    int index = widget.items.indexOf(data);
    bool isBottomLoadingTrigger =
        index == (widget.items.length - options.loadMoreTriggerItemDistance) && !state.hasReachedEnd;
    var itemWidget = widget.itemBuilder(context, data);
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

    // Edge detection
    final isAtTop = n.metrics.extentBefore <= 0.0;
    final isAtBottom = n.metrics.extentAfter <= 0.0;

    // Direction relative to visual "up"
    bool isScrollingUp;
    if (options.reverse) {
      // in reverse lists, 'reverse' means "visually up"
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
    Widget? externalWidget;
    if (widget.loadMoreWidgetBuilder != null) {
      externalWidget = widget.loadMoreWidgetBuilder!(context, state.isLoadingMore);
    }
    if (externalWidget != null) return externalWidget;
    var colorsScheme = Theme.of(context).colorScheme;
    var primaryColor = Theme.of(context).colorScheme.primary;
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      child: state.isLoadingMore
          ? Container(
              padding: EdgeInsets.all(16),
              color: primaryColor,
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: colorsScheme.onPrimary),
                ),
              ),
            )
          : SizedBox(),
    );
  }

  Widget swipeRefreshWidget(BuildContext context, InfiniteListState state) {
    var externalRefreshWidget = widget.refreshWidgetBuilder == null
        ? null
        : widget.refreshWidgetBuilder!(context, state.swipeRefreshHeight);
    if (externalRefreshWidget != null) return externalRefreshWidget;
    var primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      color: primaryColor,
      height: state.swipeRefreshHeight,
      child: Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }

  void blocListener(BuildContext context, InfiniteListState state) {
    if (state is InfiniteListStateRefresh) {
      widget.refreshOnSwipe!();
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

  Widget listWidget(BuildContext context, InfiniteListState state) {
    if (options.useAnimatedList) {
      return ImplicitlyAnimatedList<Entity>(
        controller: scrollController,
        initialAnimation: options.animateAtStart,
        physics: options.scrollPhysics ?? AlwaysScrollableScrollPhysics(),
        itemData: widget.items,
        shrinkWrap: options.shrinkWrap,
        padding: options.padding,
        reverse: options.reverse,
        insertAnimation: widget.insertAnimation ?? _defaultAnimation,
        deleteAnimation: widget.deleteAnimation ?? _defaultAnimation,
        itemBuilder: (c, i) => _itemBuilder(c, i, state),
        itemEquality: (BaseEntity f, BaseEntity s) => f.identifier == s.identifier,
      );
    }
    return ListView.separated(
      controller: widget.scrollController,
      physics: options.scrollPhysics ?? AlwaysScrollableScrollPhysics(),
      shrinkWrap: options.shrinkWrap,
      itemCount: widget.items.length,
      padding: options.padding,
      reverse: options.reverse,
      separatorBuilder: widget.separatorBuilder ?? (_, __) => SizedBox(height: 8),
      itemBuilder: (c, i) => _itemBuilder(c, widget.items[i], state),
    );
  }
}

class InfiniteListOptions {
  final bool useAnimatedList;
  final bool reverse;
  final bool animateAtStart;
  final EdgeInsets? padding;
  final Duration? animationDuration;
  final AnimatedChildBuilder? deleteAnimation;
  final AnimatedChildBuilder? insertAnimation;
  final int loadMoreTriggerItemDistance;
  final AlwaysScrollableScrollPhysics? scrollPhysics;
  final bool shrinkWrap;

  const InfiniteListOptions({
    this.reverse = false,
    this.animateAtStart = true,
    this.padding,
    this.animationDuration,
    this.deleteAnimation,
    this.insertAnimation,
    this.useAnimatedList = true,
    this.loadMoreTriggerItemDistance = 2,
    this.scrollPhysics,
    this.shrinkWrap = false,
  });

  /// default options
  factory InfiniteListOptions.defaultOptions() => const InfiniteListOptions();

  /// copyWith to selectively override fields
  InfiniteListOptions copyWith({
    bool? reverse,
    bool? animateAtStart,
    EdgeInsets? padding,
    Duration? animationDuration,
    AnimatedChildBuilder? deleteAnimation,
    AnimatedChildBuilder? insertAnimation,
    bool Function(Object first, Object second)? itemEquality,
    int? topLoadingTriggerItemDistance,
    int? bottomLoadingTriggerItemDistance,
    AlwaysScrollableScrollPhysics? scrollPhysics,
    bool? shrinkWrap,
    bool? useAnimatedList,
  }) {
    return InfiniteListOptions(
      useAnimatedList: useAnimatedList ?? this.useAnimatedList,
      reverse: reverse ?? this.reverse,
      animateAtStart: animateAtStart ?? this.animateAtStart,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      deleteAnimation: deleteAnimation ?? this.deleteAnimation,
      insertAnimation: insertAnimation ?? this.insertAnimation,
      loadMoreTriggerItemDistance: bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
    );
  }
}
