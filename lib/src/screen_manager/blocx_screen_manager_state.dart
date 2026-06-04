import 'package:blocx_core/blocx_core.dart';
import 'package:flutter_blocx/src/core/base/bloc_x_widget_state.dart';
import 'package:flutter_blocx/src/core/localizations/loc_provider.dart';
import 'package:flutter_blocx/src/screen_manager/blocx_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/src/widgets/blocx_snack_bar.dart';

/// Base state class for screens that are managed by a [ScreenManagerCubit].
///
/// Handles all cubit-driven UI side-effects automatically:
/// - Snackbar display ([ScreenManagerCubitStateDisplaySnackbar] and
///   [ScreenManagerCubitStateDisplaySnackbarByErrorCode])
/// - Full-page error display ([ScreenManagerCubitStateDisplayErrorPage] and
///   [ScreenManagerCubitStateDisplayErrorPageByErrorCode])
/// - Back-navigation via [ScreenManagerCubitStatePop]
///
/// ## Minimal implementation
///
/// Subclasses must provide [managerCubit] and implement [mainWidget]:
///
/// ```dart
/// class MyScreenState extends BlocxScreenManagerState<MyScreen> {
///   @override
///   ScreenManagerCubit get managerCubit => bloc.screenManagerCubit;
///
///   @override
///   Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
///     return MyContent();
///   }
/// }
/// ```
///
/// ## Scaffold wrapping
///
/// Set [wrapInScaffold] to `true` and override [scaffoldWidget] to wrap the
/// body in a [Scaffold]:
///
/// ```dart
/// @override
/// bool get wrapInScaffold => true;
///
/// @override
/// Widget scaffoldWidget(BuildContext context, Widget body) {
///   return Scaffold(appBar: AppBar(title: Text('My Screen')), body: body);
/// }
/// ```
abstract class BlocxScreenManagerState<T extends StatefulWidget> extends BlocXWidgetState<T> {
  late final ScreenManagerCubit _managerCubit;

  @override
  void initState() {
    super.initState();
    _managerCubit = managerCubit;
  }

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
    final Widget body;

    if (state is ScreenManagerCubitStateDisplayErrorPage) {
      body = errorWidget(context, state);
    } else if (state is ScreenManagerCubitStateDisplayErrorPageByErrorCode) {
      body = errorWidgetByErrorCode(context, state);
    } else {
      body = mainWidget(context, state);
    }

    return wrapInScaffold ? decorateScaffold(scaffoldWidget(context, body)) : SafeArea(child: body);
  }

  void _managerListener(BuildContext context, ScreenManagerCubitState state) {
    if (state is ScreenManagerCubitStateDisplaySnackbar) {
      displaySnackBar(context, state.message, state.title, state.snackbarType);
    } else if (state is ScreenManagerCubitStateDisplaySnackbarByErrorCode) {
      final message = loc.errorCodeMessage(state.errorCode);
      displaySnackBar(context, message, null, state.snackbarType);
    } else if (state is ScreenManagerCubitStatePop) {
      Navigator.of(context).maybePop();
    }
  }

  /// Shows a [BlocxSnackBar] with the given parameters.
  ///
  /// Override to customise snackbar presentation (e.g. use a different widget
  /// or delivery mechanism).
  void displaySnackBar(
    BuildContext context,
    String message,
    String? title,
    BlocXSnackbarType snackbarType,
  ) {
    BlocxSnackBar.show(context, message: message, type: snackbarType, title: title);
  }

  /// Whether the body should be wrapped in a [Scaffold].
  ///
  /// When `true`, [scaffoldWidget] must be overridden.
  bool get wrapInScaffold => false;

  /// The [ScreenManagerCubit] that drives this screen's side-effects.
  ///
  /// Typically `bloc.screenManagerCubit` from the nearest form or collection
  /// bloc.
  ScreenManagerCubit get managerCubit;

  /// Hook to decorate the scaffold returned by [scaffoldWidget].
  ///
  /// Called only when [wrapInScaffold] is `true`. Override to wrap the
  /// scaffold with additional widgets (e.g. a [WillPopScope]).
  @protected
  Widget decorateScaffold(Widget scaffold) => scaffold;

  /// Builds the full-page error widget for [ScreenManagerCubitStateDisplayErrorPage].
  ///
  /// Override to customise the error UI (e.g. branded illustration, retry
  /// logic, deep-link to support).
  @protected
  Widget errorWidget(
    BuildContext context,
    ScreenManagerCubitStateDisplayErrorPage state,
  ) {
    return BlocxErrorWidget.fromState(state);
  }

  /// Builds the full-page error widget for
  /// [ScreenManagerCubitStateDisplayErrorPageByErrorCode].
  ///
  /// Converts [state.errorCode] to a human-readable message via
  /// [BlocXLocalizations.errorCodeMessage] and renders a [BlocxErrorWidget].
  ///
  /// Override to customise per-error-code UI or to add retry / reporting
  /// callbacks.
  @protected
  Widget errorWidgetByErrorCode(
    BuildContext context,
    ScreenManagerCubitStateDisplayErrorPageByErrorCode state,
  ) {
    final readable = ReadableError(
      message: loc.errorCodeMessage(state.errorCode),
      error: state.error,
      stackTrace: state.stackTrace,
    );
    return BlocxErrorWidget(error: readable);
  }

  /// The primary screen content.
  ///
  /// Called when no error page state is active. [state] is the current
  /// [ScreenManagerCubitState] and can be inspected if needed, but most
  /// implementations can ignore it.
  @protected
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state);

  /// Wraps [body] in a [Scaffold].
  ///
  /// Only called when [wrapInScaffold] is `true`. Must be overridden, or a
  /// descriptive [UnimplementedError] is thrown at runtime.
  @protected
  Widget scaffoldWidget(BuildContext context, Widget body) {
    throw UnimplementedError(
      'wrapInScaffold is true, but scaffoldWidget() is not overridden. '
      'Either override scaffoldWidget() to provide a Scaffold, '
      'or set wrapInScaffold to false.',
    );
  }
}
