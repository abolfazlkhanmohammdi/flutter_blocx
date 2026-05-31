import 'package:blocx_core/form_bloc.dart';
import 'package:flutter_blocx/form_widget.dart';
import 'package:flutter_blocx/src/core/widgets/blocx_stateless_widget.dart';
import 'package:flutter/material.dart';

/// A reusable submit button that reacts to the current [BlocxFormState].
///
/// Automatically handles three visual states:
/// - **Idle** — shows [buttonText] and calls [onPressed] (or the ancestor
///   form's `submit`) when tapped.
/// - **Submitting** — disables the button, swaps the label to [submitText],
///   and shows a loading indicator.
/// - **Checking unique fields** — disables the button and shows a loading
///   indicator while async field validation is in progress.
/// - **Has errors** — disables the button until all form errors are resolved.
///
/// ## Visual variants
/// Choose a Material style via [type]. Each variant can be individually
/// styled via its corresponding `*Style` parameter, or with the unified
/// [style] shorthand (takes precedence).
///
/// ## Custom variants
/// Extend this class and override [buildOtherButton] to provide a fully
/// custom look (e.g. glassmorphic, neumorphic, or Cupertino-style buttons)
/// while retaining all the built-in state management.
///
/// ## Example
/// ```dart
/// BlocxFormRegisterButton(
///   state: state,
///   buttonText: 'Sign Up',
///   submitText: 'Signing up...',
///   onPressed: null, // uses the ancestor form's submit by default
/// )
/// ```
///
/// See also:
/// - [BlocxFormWidget], which provides the ancestor form state.
/// - [RegisterButtonType], for the available visual variants.
class BlocxFormRegisterButton<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>
    extends BlocxStatelessWidget {
  /// The current form state, used to determine whether the button should be
  /// disabled and which label to display.
  final BlocxFormState state;

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
  /// parameters ([elevatedStyle], [filledStyle], [textStyle], [outlinedStyle]).
  final ButtonStyle? style;

  /// Called when the button is tapped while idle.
  ///
  /// If null, the button will call `submit` on the nearest ancestor
  /// [BlocxFormWidgetState] instead.
  final VoidCallback? onPressed;

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
  });

  /// Whether the form is currently submitting.
  bool get isSubmittingForm => state is BlocxFormStateSubmittingForm;

  /// Whether any fields are currently being validated asynchronously.
  bool get isCheckingFields => state.checkingUniqueFields.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final disabled = isSubmittingForm || isCheckingFields || state.errors.isNotEmpty;
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
  Widget buildElevatedButton(BuildContext context, {required String label, required bool disabled}) {
    return ElevatedButton(
      style: style ?? elevatedStyle,
      onPressed: disabled ? null : onPressed ?? getState(context).submit,
      child: _buildContent(context, label: label, disabled: disabled),
    );
  }

  /// Builds a [FilledButton] (Material 3) variant.
  ///
  /// Override in a subclass for deeper control over the filled style.
  @protected
  Widget buildFilledButton(BuildContext context, {required String label, required bool disabled}) {
    return FilledButton(
      style: style ?? filledStyle,
      onPressed: disabled ? null : onPressed ?? getState(context).submit,
      child: _buildContent(context, label: label, disabled: disabled),
    );
  }

  /// Retrieves the nearest ancestor [BlocxFormWidgetState] from the widget tree.
  ///
  /// Used internally to call `submit` when [onPressed] is null.
  /// Throws if no ancestor state is found.
  BlocxFormWidgetState<BlocxFormWidget<P>, F, P, E> getState(BuildContext context) =>
      context.findAncestorStateOfType<BlocxFormWidgetState<BlocxFormWidget<P>, F, P, E>>()!;

  /// Builds a [TextButton] variant.
  ///
  /// Override in a subclass for deeper control over the text style.
  @protected
  Widget buildTextButton(BuildContext context, {required String label, required bool disabled}) {
    return TextButton(
      style: style ?? textStyle,
      onPressed: disabled ? null : onPressed ?? getState(context).submit,
      child: _buildContent(context, label: label, disabled: disabled),
    );
  }

  /// Builds an [OutlinedButton] variant.
  ///
  /// Override in a subclass for deeper control over the outlined style.
  @protected
  Widget buildOutlinedButton(BuildContext context, {required String label, required bool disabled}) {
    return OutlinedButton(
      style: style ?? outlinedStyle,
      onPressed: disabled ? null : onPressed ?? getState(context).submit,
      child: _buildContent(context, label: label, disabled: disabled),
    );
  }

  /// Builds a fully custom button variant.
  ///
  /// The default implementation returns a [SizedBox.shrink]. Override this in
  /// a subclass to provide a custom design (e.g. glassmorphic, neumorphic, or
  /// Cupertino-style) while retaining all built-in state management.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Widget buildOtherButton(BuildContext context, {required String label, required bool disabled}) {
  ///   return GlassmorphicButton(
  ///     label: label,
  ///     onPressed: disabled ? null : onPressed ?? getState(context).submit,
  ///   );
  /// }
  /// ```
  @protected
  Widget buildOtherButton(BuildContext context, {required String label, required bool disabled}) {
    return const SizedBox.shrink();
  }

  /// Builds the shared inner content: an optional spinner followed by the label.
  ///
  /// The spinner is only shown when [isSubmittingForm] or [isCheckingFields]
  /// is true. The label is always shown.
  Widget _buildContent(BuildContext context, {required String label, required bool disabled}) {
    final text = Text(label, style: labelTextStyle);

    if (!disabled) return text;

    final indicator = loadingIndicatorBuilder?.call(context) ?? _defaultLoadingIndicator(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSubmittingForm || isCheckingFields)
          SizedBox(
            width: 16,
            height: 16,
            child: Center(child: indicator),
          ),
        if (isSubmittingForm || isCheckingFields) SizedBox(width: spacing),
        text,
      ],
    );
  }

  /// The default loading indicator: a 16×16 [CircularProgressIndicator] with
  /// a stroke width of 2, colored with the current theme's primary color.
  Widget _defaultLoadingIndicator(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme(context).primary),
    );
  }
}

/// The available visual variants for [BlocxFormRegisterButton].
///
/// Each variant maps to a standard Material button type, except [other] which
/// is intended for fully custom designs via [BlocxFormRegisterButton.buildOtherButton].
enum RegisterButtonType {
  /// Renders an [ElevatedButton].
  elevated,

  /// Renders a [FilledButton] (Material 3).
  filled,

  /// Renders a [TextButton].
  text,

  /// Renders an [OutlinedButton].
  outlined,

  /// Renders a custom button via [BlocxFormRegisterButton.buildOtherButton].
  ///
  /// The default implementation returns a [SizedBox.shrink]. Extend
  /// [BlocxFormRegisterButton] and override `buildOtherButton` to provide
  /// your own design.
  other,
}
