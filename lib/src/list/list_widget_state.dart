import 'package:blocx/blocx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/src/list/list_widget.dart';
import 'package:flutter_blocx/src/screen_manager/screen_manager_state.dart';
import 'package:flutter_blocx/src/widgets/animated_infinite_list.dart';

abstract class AnimatedListWidgetState<W extends ListWidget<P>, T extends ListEntity<T>, P>
    extends ScreenManagerState<W> {
  final ListBloc<T, P> bloc;
  AnimatedListWidgetState({required this.bloc}) : super(managerCubit: bloc.screenManagerCubit);

  @override
  void initState() {
    bloc.add(ListBlocEventLoadInitialPage(payload: widget.payload));
    super.initState();
  }

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return BlocProvider<ListBloc<T, P>>.value(
      value: bloc, // externally provided; don't dispose here
      child: BlocConsumer<ListBloc<T, P>, ListBlocState<T>>(
        buildWhen: (_, s) => s.shouldRebuild,
        listenWhen: (_, s) => s.shouldListen,
        listener: _listListener,
        builder: listBuilder,
      ),
    );
  }

  Widget listBuilder(BuildContext context, ListBlocState<T> state) {
    final listOrLoading = isLoading
        ? loadingWidget(context, state)
        : AnimatedInfiniteList<T>(
            refreshOnSwipe: bloc.isRefreshable ? refreshData : null,
            loadBottomData: bloc.isInfinite ? loadNextPage : null,
            itemBuilder: itemBuilder,
            items: state.list,
            bloc: bloc.infiniteListBloc,
            itemEquality: (f, s) => f.identifier == s.identifier,
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
  Widget? topWidget(BuildContext context, ListBlocState<T> state) => null;

  /// Optional footer below the list.
  Widget? bottomWidget(BuildContext context, ListBlocState<T> state) => null;

  /// Renders a single list item.
  Widget itemBuilder(BuildContext context, T item);

  void _listListener(BuildContext context, ListBlocState<T> state) {}

  bool get isLoading => bloc.state is ListBlocStateLoading;

  void search(String text) {
    bloc.add(ListBlocEventSearch(searchText: text));
  }

  @override
  Widget errorWidget(BuildContext context, ScreenManagerCubitStateDisplayErrorPage state) {
    return SizedBox();
  }

  Widget loadingWidget(BuildContext context, ListBlocState<T> state) {
    return Column(children: [Text("loading data please wait"), CircularProgressIndicator()]);
  }

  void refreshData() {
    bloc.add(ListBlocEventRefreshData<T>());
  }

  void loadNextPage() {
    bloc.add(ListBlocEventLoadNextPage<T>());
  }
}
