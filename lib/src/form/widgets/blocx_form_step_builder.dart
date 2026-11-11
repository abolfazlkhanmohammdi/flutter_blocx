import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocx_form_scope.dart';

/// Immutable step-navigation snapshot and action callbacks supplied to
/// [BlocxFormStepBuilder].
@immutable
class BlocxFormStepControls {
  /// Zero-based active step index from [BlocxFormState.step].
  final int currentStep;

  /// Maximum valid zero-based step index.
  final int maxStep;

  /// `true` when [currentStep] is `0` or less.
  final bool isFirstStep;

  /// `true` when [currentStep] is greater than or equal to [maxStep].
  final bool isLastStep;

  /// Whether the current step was reached by stepping backward.
  final bool comesFromPreviousStep;

  /// Advances to the next step, or `null` when on the last step or busy.
  final VoidCallback? nextStep;

  /// Returns to the previous step, or `null` when on the first step or
  /// submitting.
  final VoidCallback? previousStep;

  /// Navigates directly to a specific step index.
  final ValueChanged<int> goToStep;

  /// Triggers form submission when [BlocxFormState.canSubmit] is `true`, or
  /// `null` otherwise.
  final VoidCallback? submitForm;

  /// Creates step-navigation controls.
  const BlocxFormStepControls({
    required this.currentStep,
    required this.maxStep,
    required this.isFirstStep,
    required this.isLastStep,
    required this.comesFromPreviousStep,
    required this.nextStep,
    required this.previousStep,
    required this.goToStep,
    required this.submitForm,
  });

  /// Alias for [currentStep].
  int get step => currentStep;
}

/// Builder callback invoked by [BlocxFormStepBuilder] with the current
/// [BlocxFormState] and step-navigation [BlocxFormStepControls].
typedef BlocxFormStepWidgetBuilder<
  F extends BlocxBaseFormEntity<F, E>,
  E extends Enum
> =
    Widget Function(
      BuildContext context,
      BlocxFormState<F, E> state,
      BlocxFormStepControls controls,
    );

/// Decouples custom multi-step navigation bars, steppers, and progress headers
/// from [BlocxFormWidgetState].
///
/// Works with stepped [BlocxFormBloc] instances using [BlocxFormSteppedMixin]
/// and can be placed anywhere inside [BlocxFormScope] (such as an `AppBar`,
/// header, or `bottomNavigationBar`).
class BlocxFormStepBuilder<
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

  /// Optional maximum zero-based step index override.
  ///
  /// When omitted, reads `BlocxFormSteppedMixin.maxStep` if the resolved bloc
  /// mixes in [BlocxFormSteppedMixin], defaulting to `0` otherwise.
  final int? maxStep;

  /// Builds step controls or step content from the current [BlocxFormState]
  /// and [BlocxFormStepControls].
  final BlocxFormStepWidgetBuilder<F, E> builder;

  /// Creates a decoupled form step builder.
  const BlocxFormStepBuilder({
    super.key,
    this.bloc,
    this.maxStep,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBloc =
        bloc ??
        BlocxFormScope.maybeOf<F, P, E>(context)?.bloc ??
        context.read<BlocxFormBloc<F, P, E>>();

    final resolvedMaxStep =
        maxStep ??
        (resolvedBloc is BlocxFormSteppedMixin<F, P, E>
            ? resolvedBloc.maxStep
            : 0);

    return BlocBuilder<BlocxFormBloc<F, P, E>, BlocxFormState<F, E>>(
      bloc: resolvedBloc,
      buildWhen: (_, current) => current.shouldRebuild,
      builder: (context, state) {
        final currentStep = state.step;
        final isFirstStep = currentStep <= 0;
        final isLastStep = currentStep >= resolvedMaxStep;
        final isBusy =
            state.isSubmittingForm ||
            state.isPrefetching ||
            state.hasPendingUniqueChecks;

        final VoidCallback? onNext = (!isLastStep && !isBusy)
            ? () => resolvedBloc.add(BlocxFormEventNextStep())
            : null;

        final VoidCallback? onPrevious =
            (!isFirstStep && !state.isSubmittingForm)
            ? () => resolvedBloc.add(BlocxFormEventPreviousStep())
            : null;

        final VoidCallback? onSubmit = state.canSubmit
            ? () => resolvedBloc.add(BlocxFormEventSubmit())
            : null;

        void onGoToStep(int index) {
          resolvedBloc.add(BlocxFormEventGoToStep(index));
        }

        final controls = BlocxFormStepControls(
          currentStep: currentStep,
          maxStep: resolvedMaxStep,
          isFirstStep: isFirstStep,
          isLastStep: isLastStep,
          comesFromPreviousStep: state.comesFromPreviousStep,
          nextStep: onNext,
          previousStep: onPrevious,
          goToStep: onGoToStep,
          submitForm: onSubmit,
        );

        return KeyedSubtree(
          key: const ValueKey<String>('blocx_step_builder'),
          child: builder(context, state, controls),
        );
      },
    );
  }
}
