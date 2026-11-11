import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocx_form_scope.dart';

/// Builder callback invoked by [BlocxFormSubmitBuilder] with the latest
/// immutable [BlocxFormState] along with ready-to-wire [submitForm] and
/// [cancelForm] callbacks.
typedef BlocxFormSubmitWidgetBuilder<
  F extends BlocxBaseFormEntity<F, E>,
  E extends Enum
> =
    Widget Function(
      BuildContext context,
      BlocxFormState<F, E> state,
      VoidCallback? submitForm,
      VoidCallback cancelForm,
    );

/// Decouples custom submit and cancel actions from [BlocxFormWidgetState].
///
/// Place [BlocxFormSubmitBuilder] anywhere in a screen's widget tree—including
/// an `AppBar`, `bottomNavigationBar`, modal footer, or split button bar—and it
/// reactively rebuilds whenever the active [BlocxFormBloc] state changes.
class BlocxFormSubmitBuilder<
  F extends BlocxBaseFormEntity<F, E>,
  P,
  E extends Enum
>
    extends StatelessWidget {
  /// Optional explicit form bloc.
  ///
  /// When omitted, resolves the nearest [BlocxFormScope] or ancestor
  /// [BlocProvider]`<BlocxFormBloc<F, P, E>>`.
  final BlocxFormBloc<F, P, E>? bloc;

  /// Builds custom submit/cancel controls from the current [BlocxFormState].
  final BlocxFormSubmitWidgetBuilder<F, E> builder;

  /// When `true`, passes `null` for `submitForm` unless
  /// [BlocxFormState.canSubmit] is `true`.
  ///
  /// Defaults to `false`, allowing `FormValidationMode.onSubmit` forms to
  /// remain clickable after displaying validation errors while still disabling
  /// submission during prefetching, unique-field checks, and active submits.
  final bool disableWhenInvalid;

  /// Optional callback invoked when `cancelForm` is called.
  ///
  /// When omitted, dispatches [BlocxFormEventReset] if [resetOnCancel] is
  /// `true`, or calls `Navigator.of(context).maybePop()` otherwise.
  final VoidCallback? onCancel;

  /// Whether default `cancelForm` behavior resets the form via
  /// [BlocxFormEventReset] instead of calling `Navigator.of(context).maybePop()`.
  final bool resetOnCancel;

  /// Creates a decoupled form submit/cancel builder.
  const BlocxFormSubmitBuilder({
    super.key,
    this.bloc,
    required this.builder,
    this.disableWhenInvalid = false,
    this.onCancel,
    this.resetOnCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBloc =
        bloc ??
        BlocxFormScope.maybeOf<F, P, E>(context)?.bloc ??
        context.read<BlocxFormBloc<F, P, E>>();

    return BlocBuilder<BlocxFormBloc<F, P, E>, BlocxFormState<F, E>>(
      bloc: resolvedBloc,
      buildWhen: (_, current) => current.shouldRebuild,
      builder: (context, state) {
        final canTrigger = disableWhenInvalid
            ? state.canSubmit
            : (!state.isSubmittingForm &&
                  !state.isPrefetching &&
                  !state.hasPendingUniqueChecks);

        final VoidCallback? submitForm = canTrigger
            ? () => resolvedBloc.add(BlocxFormEventSubmit())
            : null;

        void cancelForm() {
          if (onCancel != null) {
            onCancel!();
          } else if (resetOnCancel) {
            resolvedBloc.add(const BlocxFormEventReset());
          } else {
            Navigator.of(context).maybePop();
          }
        }

        return KeyedSubtree(
          key: const ValueKey<String>('blocx_submit_builder'),
          child: builder(context, state, submitForm, cancelForm),
        );
      },
    );
  }
}
