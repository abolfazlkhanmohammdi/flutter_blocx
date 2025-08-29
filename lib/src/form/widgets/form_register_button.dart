import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter/src/core/widgets/blocx_stateless_widget.dart';
import 'package:flutter/material.dart';

/// A reusable submit/register button that reacts to a form [state].
///
/// - While the form is submitting (`FormStateSubmittingForm`) the button:
///   - disables `onPressed`
///   - swaps `buttonText` with `submitText`
///   - shows a small progress indicator (customizable)
///
/// - Choose the visual style via [type].
/// - Customize per-type styles using the provided `*Style` parameters.
/// - Override `buildOtherButton` in a subclass to provide a custom button.
///   The base `other` implementation returns a [SizedBox.shrink] by design.
class FormRegisterButton extends BlocxStatelessWidget {
  /// Current form state (used to detect submitting).
  final FormBlocState state;

  /// Which visual variant to render.
  final RegisterButtonType type;

  /// Label when idle.
  final String buttonText;

  /// Label shown while submitting.
  final String submitText;

  /// Callback when pressed (disabled while submitting).
  final VoidCallback? onPressed;

  // -------- Styling hooks (Material) --------
  /// Optional style for [RegisterButtonType.elevated].
  final ButtonStyle? elevatedStyle;

  /// Optional style for [RegisterButtonType.filled].
  final ButtonStyle? filledStyle;

  /// Optional style for [RegisterButtonType.text].
  final ButtonStyle? textStyle;

  /// Optional style for [RegisterButtonType.outlined].
  final ButtonStyle? outlinedStyle;

  // -------- Content / behavior hooks --------
  /// Optional text style applied to the inner [Text].
  final TextStyle? labelTextStyle;

  /// Builder for the loading indicator (material & cupertino).
  /// If null, a platform-appropriate default spinner is used.
  final WidgetBuilder? loadingIndicatorBuilder;

  /// Spacing between spinner and text.
  final double spacing;

  const FormRegisterButton({
    super.key,
    required this.state,
    required this.buttonText,
    required this.submitText,
    this.type = RegisterButtonType.filled,
    this.onPressed,
    this.elevatedStyle,
    this.filledStyle,
    this.textStyle,
    this.outlinedStyle,
    // Content / behavior
    this.labelTextStyle,
    this.loadingIndicatorBuilder,
    this.spacing = 8.0,
  });

  /// True while the form is in submitting state.
  bool get isSubmittingForm => state is FormStateSubmittingForm;

  @override
  Widget build(BuildContext context) {
    final disabled = isSubmittingForm;
    final label = disabled ? submitText : buttonText;

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
        // Intentionally minimal so child classes can override.
        return buildOtherButton(context, label: label, disabled: disabled);
    }
  }

  // ---------------------------------------------------------------------------
  // Per-type builders (override these in subclasses if you need deeper control)
  // ---------------------------------------------------------------------------

  /// Builds an [ElevatedButton] variant.
  @protected
  Widget buildElevatedButton(BuildContext context, {required String label, required bool disabled}) {
    return ElevatedButton(
      style: elevatedStyle,
      onPressed: disabled ? null : onPressed,
      child: _buildContent(context, label: label, disabled: disabled),
    );
  }

  /// Builds a [FilledButton] (Material 3) variant.
  @protected
  Widget buildFilledButton(BuildContext context, {required String label, required bool disabled}) {
    return FilledButton(
      style: filledStyle,
      onPressed: disabled ? null : onPressed,
      child: _buildContent(context, label: label, disabled: disabled),
    );
  }

  /// Builds a [TextButton] variant.
  @protected
  Widget buildTextButton(BuildContext context, {required String label, required bool disabled}) {
    return TextButton(
      style: textStyle,
      onPressed: disabled ? null : onPressed,
      child: _buildContent(context, label: label, disabled: disabled),
    );
  }

  /// Builds an [OutlinedButton] variant.
  @protected
  Widget buildOutlinedButton(BuildContext context, {required String label, required bool disabled}) {
    return OutlinedButton(
      style: outlinedStyle,
      onPressed: disabled ? null : onPressed,
      child: _buildContent(context, label: label, disabled: disabled),
    );
  }

  /// Default implementation for custom/other style.
  ///
  /// Returns an empty box so that concrete subclasses can override this
  /// method to provide their own look (e.g., a Neumorphic or glassmorphic
  /// button, or a Cupertino button).
  @protected
  Widget buildOtherButton(BuildContext context, {required String label, required bool disabled}) {
    return const SizedBox.shrink();
  }

  // ---------------------------------------------------------------------------
  // Shared content
  // ---------------------------------------------------------------------------

  /// Common inner content: optional spinner + label.
  Widget _buildContent(BuildContext context, {required String label, required bool disabled}) {
    final text = Text(label, style: labelTextStyle);

    if (!disabled) return text;

    final indicator = loadingIndicatorBuilder?.call(context) ?? _defaultLoadingIndicator(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 16, height: 16, child: Center(child: indicator)),
        SizedBox(width: spacing),
        text,
      ],
    );
  }

  Widget _defaultLoadingIndicator(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme(context).primary),
    );
  }
}

/// Available visual variants for [FormRegisterButton].
enum RegisterButtonType {
  elevated,
  filled,
  text,
  outlined,
  // this is intended for use when extending this button for custom designs like glassmorphic or neumorphic buttons
  other,
}
