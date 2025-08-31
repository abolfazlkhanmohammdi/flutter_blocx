import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter/src/core/base/bloc_x_widget_state.dart';
import 'package:blocx_flutter/src/screen_manager/blocx_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blocx_flutter/src/widgets/blocx_snack_bar.dart';

abstract class ScreenManagerState<T extends StatefulWidget> extends BlocXWidgetState<T> {
  final ScreenManagerCubit _managerCubit;
  ScreenManagerState({required ScreenManagerCubit managerCubit}) : _managerCubit = managerCubit;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScreenManagerCubit>.value(
      value: _managerCubit,
      child: BlocConsumer<ScreenManagerCubit, ScreenManagerCubitState>(
        buildWhen: (_, c) => c.shouldRebuild,
        listenWhen: (_, c) => c.shouldListen,
        builder: _managerBuilder,
        listener: _managerListener,
      ),
    );
  }

  Widget _managerBuilder(BuildContext context, ScreenManagerCubitState state) {
    final body = state is ScreenManagerCubitStateDisplayErrorPage
        ? errorWidget(context, state)
        : mainWidget(context, state);
    return wrapInScaffold ? scaffoldWidget(context, body) : SafeArea(child: body);
  }

  void _managerListener(BuildContext context, ScreenManagerCubitState state) {
    if (state is ScreenManagerCubitStateDisplaySnackbar) {
      displaySnackBar(context, state.message, state.title, state.snackbarType);
    }
  }

  void displaySnackBar(BuildContext context, String message, String? title, BlocXSnackbarType snackbarType) {
    BlocxSnackBar.show(context, message: message, type: snackbarType, title: title);
  }

  bool get wrapInScaffold => false;

  @protected
  Widget errorWidget(BuildContext context, ScreenManagerCubitStateDisplayErrorPage state) {
    return BlocxErrorWidget.fromState(state);
  }

  @protected
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state);

  @protected
  Scaffold scaffoldWidget(BuildContext context, Widget body) {
    throw UnimplementedError(
      'wrapInScaffold is true, but scaffoldWidget() is not overridden. '
      'Either override scaffoldWidget() to provide a Scaffold, or set wrapInScaffold to false.',
    );
  }
}
