import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A composable widget that binds and listens to a [BlocxFormBloc].
///
/// Unlike [BlocxFormWidgetState], [BlocxFormView] does not require a full screen
/// manager or stateful screen hierarchy, allowing forms to be embedded anywhere.
class BlocxFormView<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>
    extends StatelessWidget {
  /// The form bloc driving this view.
  final BlocxFormBloc<F, P, E> bloc;

  /// Builds the form widgets based on current form state.
  final Widget Function(BuildContext context, BlocxFormState<F, E> state)
  builder;

  /// Optional listener for custom side-effects.
  final void Function(BuildContext context, BlocxFormState<F, E> state)?
  listener;

  /// Optional callback invoked when initial form data is applied.
  final void Function(F formData)? onApplyInitialData;

  /// Optional callback invoked when form submission finishes.
  final void Function(BlocxFormStateFormSubmitted<F, E> state)? onFormSubmitted;

  /// Optional callback invoked when any form field value changes.
  final void Function(F formData, E key, dynamic oldValue, dynamic newValue)?
  onFormUpdated;

  /// Creates a composable form view.
  const BlocxFormView({
    super.key,
    required this.bloc,
    required this.builder,
    this.listener,
    this.onApplyInitialData,
    this.onFormSubmitted,
    this.onFormUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocxFormBloc<F, P, E>>.value(
      value: bloc,
      child: BlocConsumer<BlocxFormBloc<F, P, E>, BlocxFormState<F, E>>(
        buildWhen: (_, current) => current.shouldRebuild,
        listenWhen: (_, current) => current.shouldListen,
        listener: (context, state) {
          if (state is BlocxFormStateApplyInitialDataToForm<F, E>) {
            onApplyInitialData?.call(state.formData);
          } else if (state is BlocxFormStateFormSubmitted<F, E>) {
            onFormSubmitted?.call(state);
          } else if (state is BlocxFormStateFormUpdated<F, E>) {
            onFormUpdated?.call(
              state.formData,
              state.updatedKey,
              state.oldValue,
              state.newValue,
            );
          }
          listener?.call(context, state);
        },
        builder: builder,
      ),
    );
  }
}
