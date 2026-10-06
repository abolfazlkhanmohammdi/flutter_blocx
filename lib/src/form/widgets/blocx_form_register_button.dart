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
/// Set [BlocxFormRegisterButtonOptions.disableWhenInvalid] to `true` if the
/// button should be disabled when [BlocxFormState.errors] is not empty.
class BlocxFormRegisterButton<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>
    extends BlocxStatelessWidget {
  /// The current form state.
  ///
  /// Used to determine the loading state, disabled state, and label text.
  final BlocxFormState<F, E> state;

  /// The visual variant of the button.
  ///
  /// Defaults to [RegisterButtonType.filled].
  final RegisterButtonType type;

  /// The label displayed while the form is idle.
  final String buttonText;

  /// The label displayed while the form is submitting.
  final String submitText;

  /// Visual and behavioral configuration for the button.
  final BlocxFormRegisterButtonOptions buttonOptions;

  /// Called when the button is tapped while idle.
  ///
  /// When omitted, the button calls `submit` on the nearest ancestor
  /// [BlocxFormWidgetState].
  final VoidCallback? onPressed;

  /// Creates a form register button.
  const BlocxFormRegisterButton({
    super.key,
    required this.state,
    required this.buttonText,
    required this.submitText,
    this.type = RegisterButtonType.filled,
    this.buttonOptions = const BlocxFormRegisterButtonOptions(),
    this.onPressed,
  });

  /// Whether the form is currently submitting.
  bool get isSubmittingForm {
    return state is BlocxFormStateSubmittingForm<F, E>;
  }

  /// Whether any unique-field checks are currently running.
  bool get isCheckingUniqueFields {
    return state.checkingUniqueFields.isNotEmpty;
  }

  /// Whether any required field information is currently being fetched.
  bool get isFetchingFieldInfo {
    return state.fieldsFetchingInfo.isNotEmpty;
  }

  /// Whether the state currently contains validation errors.
  bool get hasValidationErrors => state.errors.isNotEmpty;

  /// Whether the button should display a loading indicator.
  bool get isBusy {
    return isSubmittingForm || isCheckingUniqueFields || isFetchingFieldInfo;
  }

  /// Whether the button should be disabled.
  bool get isDisabled {
    return isBusy || (buttonOptions.disableWhenInvalid && !state.isFormValid) || state.errors.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final disabled = isDisabled;
    final label = isSubmittingForm ? submitText : buttonText;

    var widget = switch (type) {
      RegisterButtonType.elevated => buildElevatedButton(
          context,
          label: label,
          disabled: disabled,
        ),
      RegisterButtonType.filled => buildFilledButton(
          context,
          label: label,
          disabled: disabled,
        ),
      RegisterButtonType.text => buildTextButton(
          context,
          label: label,
          disabled: disabled,
        ),
      RegisterButtonType.outlined => buildOutlinedButton(
          context,
          label: label,
          disabled: disabled,
        ),
      RegisterButtonType.other => buildOtherButton(
          context,
          label: label,
          disabled: disabled,
        ),
    };

    return Tooltip(message: state.errors.values.join(".\n"), child: widget);
  }

  /// Builds an [ElevatedButton] variant.
  ///
  /// Override this method in a subclass for deeper control over the elevated
  /// button implementation.
  @protected
  Widget buildElevatedButton(
    BuildContext context, {
    required String label,
    required bool disabled,
  }) {
    return ElevatedButton(
      style: buttonOptions.style ?? buttonOptions.elevatedStyle,
      onPressed: _resolveOnPressed(context, disabled),
      child: _buildContent(context, label: label),
    );
  }

  /// Builds a [FilledButton] variant.
  ///
  /// Override this method in a subclass for deeper control over the filled
  /// button implementation.
  @protected
  Widget buildFilledButton(
    BuildContext context, {
    required String label,
    required bool disabled,
  }) {
    return FilledButton(
      style: buttonOptions.filledStyle ?? buttonOptions.style,
      onPressed: _resolveOnPressed(context, disabled),
      child: _buildContent(context, label: label),
    );
  }

  /// Builds a [TextButton] variant.
  ///
  /// Override this method in a subclass for deeper control over the text
  /// button implementation.
  @protected
  Widget buildTextButton(
    BuildContext context, {
    required String label,
    required bool disabled,
  }) {
    return TextButton(
      style: buttonOptions.style ?? buttonOptions.textStyle,
      onPressed: _resolveOnPressed(context, disabled),
      child: _buildContent(context, label: label),
    );
  }

  /// Builds an [OutlinedButton] variant.
  ///
  /// Override this method in a subclass for deeper control over the outlined
  /// button implementation.
  @protected
  Widget buildOutlinedButton(
    BuildContext context, {
    required String label,
    required bool disabled,
  }) {
    return OutlinedButton(
      style: buttonOptions.style ?? buttonOptions.outlinedStyle,
      onPressed: _resolveOnPressed(context, disabled),
      child: _buildContent(context, label: label),
    );
  }

  /// Builds a fully custom button variant.
  ///
  /// The default implementation returns a [SizedBox.shrink]. Override this
  /// method to provide a custom button while retaining the form-state logic.
  @protected
  Widget buildOtherButton(
    BuildContext context, {
    required String label,
    required bool disabled,
  }) {
    return const SizedBox.shrink();
  }

  /// Retrieves the nearest ancestor [BlocxFormWidgetState].
  ///
  /// Used internally to submit the form when [onPressed] is omitted.
  BlocxFormWidgetState<BlocxFormWidget<P>, F, P, E> getState(
    BuildContext context,
  ) {
    final formState = context.findAncestorStateOfType<BlocxFormWidgetState<BlocxFormWidget<P>, F, P, E>>();

    if (formState == null) {
      throw FlutterError(
        'BlocxFormRegisterButton could not find a matching '
        'BlocxFormWidgetState<BlocxFormWidget<$P>, $F, $P, $E> ancestor.',
      );
    }

    return formState;
  }

  /// Resolves the effective button callback.
  VoidCallback? _resolveOnPressed(
    BuildContext context,
    bool disabled,
  ) {
    if (disabled) return null;

    return onPressed ?? getState(context).submit;
  }

  /// Builds the shared button content.
  ///
  /// The loading indicator is only displayed while [isBusy] is `true`.
  Widget _buildContent(
    BuildContext context, {
    required String label,
  }) {
    final text = Text(
      label,
      style: buttonOptions.labelTextStyle,
    );

    if (!isBusy) return text;

    final indicator =
        buttonOptions.loadingIndicatorBuilder?.call(context) ?? _defaultLoadingIndicator(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 16,
          child: Center(child: indicator),
        ),
        SizedBox(width: buttonOptions.spacing),
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

/// Configuration options for [BlocxFormRegisterButton].
///
/// These options control the button's styling, loading indicator, spacing, and
/// validation-related disabling behavior.
class BlocxFormRegisterButtonOptions {
  /// A unified [ButtonStyle] applied to every button variant.
  ///
  /// When provided, this takes precedence over all variant-specific styles.
  final ButtonStyle? style;

  /// Style applied to [RegisterButtonType.elevated].
  ///
  /// Ignored when [style] is provided.
  final ButtonStyle? elevatedStyle;

  /// Style applied to [RegisterButtonType.filled].
  ///
  /// Ignored when [style] is provided.
  final ButtonStyle? filledStyle;

  /// Style applied to [RegisterButtonType.text].
  ///
  /// Ignored when [style] is provided.
  final ButtonStyle? textStyle;

  /// Style applied to [RegisterButtonType.outlined].
  ///
  /// Ignored when [style] is provided.
  final ButtonStyle? outlinedStyle;

  /// Style applied to the inner text label.
  final TextStyle? labelTextStyle;

  /// Builds the loading indicator shown while the form is busy.
  ///
  /// When omitted, a 16×16 [CircularProgressIndicator] is used.
  final WidgetBuilder? loadingIndicatorBuilder;

  /// Horizontal spacing between the loading indicator and label.
  ///
  /// Defaults to `8.0`.
  final double spacing;

  /// Whether validation errors should disable the button.
  ///
  /// Defaults to `false` so [FormValidationMode.onSubmit] forms do not become
  /// stuck after displaying validation errors. Invalid submission is still
  /// blocked by [BlocxFormBloc.isFormSubmittable].
  final bool disableWhenInvalid;

  /// Creates register button configuration options.
  const BlocxFormRegisterButtonOptions({
    this.style,
    this.elevatedStyle,
    this.filledStyle,
    this.textStyle,
    this.outlinedStyle,
    this.labelTextStyle,
    this.loadingIndicatorBuilder,
    this.spacing = 8.0,
    this.disableWhenInvalid = false,
  });
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

  /// Renders a custom button through
  /// [BlocxFormRegisterButton.buildOtherButton].
  other,
}
