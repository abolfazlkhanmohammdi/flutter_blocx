import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/form_widget.dart';
import 'package:flutter_blocx/src/core/widgets/blocx_stateless_widget.dart';

/// A reusable submit button that reacts to the current [BlocxFormState].
///
/// Automatically handles these visual states:
///
/// - idle: shows [buttonText] and submits when tapped.
/// - submitting: disables the button, shows [submitText], and displays loading.
/// - checking unique fields: disables the button and displays loading.
/// - fetching required field info: disables the button and displays loading.
///
/// Validation errors do not disable the button by default. This is intentional:
/// the form bloc must be the final authority that validates and blocks invalid
/// submission. This prevents [FormValidationMode.onSubmit] forms from getting
/// stuck after the first failed submit.
///
/// Set [disableWhenInvalid] to `true` if you explicitly want the button disabled
/// when [BlocxFormState.errors] is not empty.
class BlocxFormRegisterButton<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>
    extends BlocxStatelessWidget {
  /// The current form state.
  ///
  /// Used to determine button loading, disabled state, and label text.
  final BlocxFormState<F, E> state;

  /// The visual variant of the button.
  ///
  /// Defaults to [RegisterButtonType.filled].
  final RegisterButtonType type;

  /// The label displayed when the form is idle.
  final String buttonText;

  /// The label displayed while the form is submitting.
  final String submitText;

  /// Optional style applied to [RegisterButtonType.elevated] buttons.
  ///
  /// Ignored when [style] is provided.
  final ButtonStyle? elevatedStyle;

  /// Optional style applied to [RegisterButtonType.filled] buttons.
  ///
  /// Ignored when [style] is provided.
  final ButtonStyle? filledStyle;

  /// Optional style applied to [RegisterButtonType.text] buttons.
  ///
  /// Ignored when [style] is provided.
  final ButtonStyle? textStyle;

  /// Optional style applied to [RegisterButtonType.outlined] buttons.
  ///
  /// Ignored when [style] is provided.
  final ButtonStyle? outlinedStyle;

  /// Optional style applied to the inner [Text] label.
  final TextStyle? labelTextStyle;

  /// Builds a custom loading indicator shown while submitting or checking fields.
  ///
  /// If null, a [CircularProgressIndicator] sized to 16×16 is used.
  final WidgetBuilder? loadingIndicatorBuilder;

  /// Horizontal spacing between the loading indicator and the label text.
  ///
  /// Defaults to `8.0`.
  final double spacing;

  /// A unified [ButtonStyle] that takes precedence over all per-type style
  /// parameters.
  final ButtonStyle? style;

  /// Called when the button is tapped while idle.
  ///
  /// If null, the button calls `submit` on the nearest ancestor
  /// [BlocxFormWidgetState].
  final VoidCallback? onPressed;

  /// Whether validation errors should disable the button.
  ///
  /// Defaults to `false` so [FormValidationMode.onSubmit] forms do not get stuck
  /// after validation errors are shown. Invalid submission is still blocked by
  /// [BlocxFormBloc.isFormSubmittable].
  final bool disableWhenInvalid;

  /// Creates a [BlocxFormRegisterButton].
  const BlocxFormRegisterButton({
    super.key,
    required this.state,
    required this.buttonText,
    required this.submitText,
    required this.onPressed,
    this.type = RegisterButtonType.filled,
    this.elevatedStyle,
    this.filledStyle,
    this.textStyle,
    this.outlinedStyle,
    this.labelTextStyle,
    this.loadingIndicatorBuilder,
    this.spacing = 8.0,
    this.style,
    this.disableWhenInvalid = false,
  });

  /// Whether the form is currently submitting.
  bool get isSubmittingForm => state is BlocxFormStateSubmittingForm<F, E>;

  /// Whether any unique-field checks are currently running.
  bool get isCheckingUniqueFields => state.checkingUniqueFields.isNotEmpty;

  /// Whether any required field info is currently being fetched.
  bool get isFetchingFieldInfo => state.fieldsFetchingInfo.isNotEmpty;

  /// Whether the state currently contains validation errors.
  bool get hasValidationErrors => state.errors.isNotEmpty;

  /// Whether the button should show a loading indicator.
  bool get isBusy => isSubmittingForm || isCheckingUniqueFields || isFetchingFieldInfo;

  /// Whether the button should be disabled.
  bool get isDisabled {
    return isBusy || (disableWhenInvalid && hasValidationErrors);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = isDisabled;
    final label = isSubmittingForm ? submitText : buttonText;

    switch (type) {
      case RegisterButtonType.elevated:
        return buildElevatedButton(context, label: label, disabled: disabled);

      case RegisterButtonType.filled:
        return buildFilledButton(context, label: label, disabled: disabled);

      case RegisterButtonType.text:
        return buildTextButton(context, label: label, disabled: disabled);

      case RegisterButtonType.outlined:
        return buildOutlinedButton(context, label: label, disabled: disabled);

      case RegisterButtonType.other:
        return buildOtherButton(context, label: label, disabled: disabled);
    }
  }

  /// Builds an [ElevatedButton] variant.
  ///
  /// Override in a subclass for deeper control over the elevated style.
  @protected
  Widget buildElevatedButton(
    BuildContext context, {
    required String label,
    required bool disabled,
  }) {
    return ElevatedButton(
      style: style ?? elevatedStyle,
      onPressed: disabled ? null : onPressed ?? getState(context).submit,
      child: _buildContent(context, label: label),
    );
  }

  /// Builds a [FilledButton] variant.
  ///
  /// Override in a subclass for deeper control over the filled style.
  @protected
  Widget buildFilledButton(
    BuildContext context, {
    required String label,
    required bool disabled,
  }) {
    return FilledButton(
      style: style ?? filledStyle,
      onPressed: disabled ? null : onPressed ?? getState(context).submit,
      child: _buildContent(context, label: label),
    );
  }

  /// Retrieves the nearest ancestor [BlocxFormWidgetState].
  ///
  /// Used internally to call `submit` when [onPressed] is null.
  BlocxFormWidgetState<BlocxFormWidget<P>, F, P, E> getState(BuildContext context) {
    final state = context.findAncestorStateOfType<BlocxFormWidgetState<BlocxFormWidget<P>, F, P, E>>();

    if (state == null) {
      throw FlutterError(
        'BlocxFormRegisterButton could not find a matching '
        'BlocxFormWidgetState<BlocxFormWidget<$P>, $F, $P, $E> ancestor.',
      );
    }

    return state;
  }

  /// Builds a [TextButton] variant.
  ///
  /// Override in a subclass for deeper control over the text style.
  @protected
  Widget buildTextButton(
    BuildContext context, {
    required String label,
    required bool disabled,
  }) {
    return TextButton(
      style: style ?? textStyle,
      onPressed: disabled ? null : onPressed ?? getState(context).submit,
      child: _buildContent(context, label: label),
    );
  }

  /// Builds an [OutlinedButton] variant.
  ///
  /// Override in a subclass for deeper control over the outlined style.
  @protected
  Widget buildOutlinedButton(
    BuildContext context, {
    required String label,
    required bool disabled,
  }) {
    return OutlinedButton(
      style: style ?? outlinedStyle,
      onPressed: disabled ? null : onPressed ?? getState(context).submit,
      child: _buildContent(context, label: label),
    );
  }

  /// Builds a fully custom button variant.
  ///
  /// The default implementation returns a [SizedBox.shrink]. Override this in
  /// a subclass to provide a custom design while retaining state management.
  @protected
  Widget buildOtherButton(
    BuildContext context, {
    required String label,
    required bool disabled,
  }) {
    return const SizedBox.shrink();
  }

  /// Builds the shared inner content.
  ///
  /// The loading indicator is only shown while [isBusy] is true.
  Widget _buildContent(
    BuildContext context, {
    required String label,
  }) {
    final text = Text(label, style: labelTextStyle);

    if (!isBusy) return text;

    final indicator = loadingIndicatorBuilder?.call(context) ?? _defaultLoadingIndicator(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: Center(child: indicator),
        ),
        SizedBox(width: spacing),
        text,
      ],
    );
  }

  /// Builds the default loading indicator.
  Widget _defaultLoadingIndicator(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: colorScheme(context).primary,
      ),
    );
  }
}

/// The available visual variants for [BlocxFormRegisterButton].
enum RegisterButtonType {
  /// Renders an [ElevatedButton].
  elevated,

  /// Renders a [FilledButton].
  filled,

  /// Renders a [TextButton].
  text,

  /// Renders an [OutlinedButton].
  outlined,

  /// Renders a custom button via [BlocxFormRegisterButton.buildOtherButton].
  other,
}
