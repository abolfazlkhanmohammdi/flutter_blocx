import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/widgets.dart';

/// Exposes an active [BlocxFormBloc] to descendant form controls and
/// detached action builders such as [BlocxFormSubmitBuilder] and
/// [BlocxFormStepBuilder].
///
/// Both [BlocxFormView] and [BlocxFormWidgetState] install a [BlocxFormScope]
/// automatically so controls placed anywhere inside the screen scaffold (such
/// as `appBar` or `bottomNavigationBar`) can resolve the active form bloc
/// without manually threading a controller or `GlobalKey<FormState>`.
class BlocxFormScope<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>
    extends InheritedWidget {
  /// The active form bloc exposed to descendants.
  final BlocxFormBloc<F, P, E> bloc;

  /// Creates a scope exposing [bloc] to [child] and its descendants.
  const BlocxFormScope({super.key, required this.bloc, required super.child});

  /// Returns the nearest enclosing [BlocxFormScope], or `null` if none exists.
  static BlocxFormScope<F, P, E>? maybeOf<
    F extends BlocxBaseFormEntity<F, E>,
    P,
    E extends Enum
  >(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BlocxFormScope<F, P, E>>();
  }

  /// Returns the nearest enclosing [BlocxFormScope], throwing a descriptive
  /// [FlutterError] when none is found in [context].
  static BlocxFormScope<F, P, E> of<
    F extends BlocxBaseFormEntity<F, E>,
    P,
    E extends Enum
  >(BuildContext context) {
    final scope = maybeOf<F, P, E>(context);
    if (scope == null) {
      throw FlutterError(
        'BlocxFormScope.of<$F, $P, $E>(context) called with a context that '
        'does not contain a BlocxFormScope<$F, $P, $E>.\n'
        'Ensure the widget is inside a BlocxFormView or BlocxFormWidgetState.',
      );
    }
    return scope;
  }

  @override
  bool updateShouldNotify(BlocxFormScope<F, P, E> oldWidget) =>
      bloc != oldWidget.bloc;
}
