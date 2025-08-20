import 'package:blocx/blocx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/src/list/list_widget.dart';
import 'package:flutter_blocx/src/screen_manager/screen_manager_state.dart';
import 'package:flutter_blocx/src/widgets/animated_infinite_list.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';

abstract class AnimatedListWidgetState<W extends ListWidget<P>, T extends ListEntity<T>, P>
    extends ScreenManagerState<W> {
  final ListBloc<T, P> bloc;
  AnimatedListWidgetState({required this.bloc}) : super(managerCubit: bloc.screenManagerCubit);

  @override
  void initState() {
    bloc.add(ListEventLoadInitialPage<T, P>(payload: widget.payload));
    super.initState();
  }

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return BlocProvider<ListBloc<T, P>>.value(
      value: bloc, // externally provided; don't dispose here
      child: BlocConsumer<ListBloc<T, P>, ListState<T>>(
        buildWhen: (_, s) => s.shouldRebuild,
        listenWhen: (_, s) => s.shouldListen,
        listener: _listListener,
        builder: listBuilder,
      ),
    );
  }

  Widget listBuilder(BuildContext context, ListState<T> state) {
    final listOrLoading = isLoading
        ? loadingWidget(context, state)
        : AnimatedInfiniteList<T>(
            refreshOnSwipe: bloc.isRefreshable ? refreshData : null,
            loadBottomData: bloc.isInfinite ? loadNextPage : null,
            itemBuilder: itemBuilder,
            items: state.list,
            bloc: bloc.infiniteListBloc,
            deleteAnimation: deleteAnimation,
            insertAnimation: insertAnimation,
            separatorBuilder: separatorBuilder,
            options: listOptions,
          );

    final top = topWidget(context, state);
    final bottom = bottomWidget(context, state);

    // if neither top nor bottom exists, return list directly
    if (top == null && bottom == null) return listOrLoading;

    return Container(
      color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: topBottomAndListSpacing,
        children: [
          ?top,
          Expanded(child: listOrLoading),
          ?bottom,
        ],
      ),
    );
  }

  /// Spacing inserted between top/bottom widgets and the list.
  double get topBottomAndListSpacing => 8.0;

  /// Optional header above the list.
  Widget? topWidget(BuildContext context, ListState<T> state) => null;

  /// Optional footer below the list.
  Widget? bottomWidget(BuildContext context, ListState<T> state) => null;

  /// Renders a single list item.
  Widget itemBuilder(BuildContext context, T item);

  void _listListener(BuildContext context, ListState<T> state) {}

  bool get isLoading => bloc.state is ListStateLoading;

  void search(String text) {
    bloc.add(ListEventSearch<T>(searchText: text));
  }

  @override
  Widget errorWidget(BuildContext context, ScreenManagerCubitStateDisplayErrorPage state) {
    return SizedBox();
  }

  Widget loadingWidget(BuildContext context, ListState<T> state) {
    return Column(
      spacing: 24,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        Text(
          loadingText.isNotEmpty ? loadingText : "loading data please wait",
          style: textTheme(context).bodyLarge?.copyWith(color: theme(context).colorScheme.primary),
        ),
        Row(),
      ],
    );
  }

  ThemeData theme(BuildContext context) => Theme.of(context);
  TextTheme textTheme(BuildContext context) => theme(context).textTheme;

  String get loadingText => "";

  void refreshData() {
    bloc.add(ListEventRefreshData<T>());
  }

  void loadNextPage() {
    bloc.add(ListEventLoadNextPage<T>());
  }

  AnimatedInfiniteListOptions get listOptions => AnimatedInfiniteListOptions.defaultOptions();

  AnimatedChildBuilder? get deleteAnimation => null;

  AnimatedChildBuilder? get insertAnimation => null;

  Widget separatorBuilder(BuildContext context, int index) {
    return SizedBox.shrink();
  }

  P? get payload => widget.payload;
}
