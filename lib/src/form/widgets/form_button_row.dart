import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter/src/core/widgets/blocx_stateless_widget.dart';
import 'package:flutter/material.dart';

import 'form_register_button.dart';

/// A horizontal row of two buttons:
/// 1) A [FormRegisterButton] for submitting a form.
/// 2) A secondary button that pops the current route.
///
/// ### Features
/// - Equal-width layout with configurable spacing.
/// - Pass-through configuration for the register button (texts, type, styles).
/// - The secondary button can be styled; by default it's an [OutlinedButton].
/// - Optionally disable the pop button while the form is submitting.
/// - Optional pre-pop callback (e.g., for analytics or side-effects).
class FormButtonRow extends BlocxStatelessWidget {
  /// Current form state used by [FormRegisterButton].
  final FormBlocState formState;

  /// Text shown on the register button when idle.
  final String registerText;

  /// Text shown on the register button while submitting.
  final String registerSubmittingText;

  /// Visual style for the register button.
  final RegisterButtonType registerType;

  /// Called when the register button is pressed (disabled while submitting).
  final VoidCallback? onRegisterPressed;

  /// Label for the pop (secondary) button.
  final String popButtonText;

  /// Optional style for the pop (secondary) button.
  final ButtonStyle? popButtonStyle;

  /// If true, disables the pop button while the form is submitting.
  final bool disablePopWhileSubmitting;

  /// Called right before attempting to pop. Return value is ignored; if set,
  /// it runs and then a pop is attempted via [Navigator.maybePop].
  final VoidCallback? onBeforePop;

  /// Horizontal gap between the two buttons.
  final double spacing;

  /// If true, both buttons expand equally to fill the row.
  final bool expandEqually;

  const FormButtonRow({
    super.key,
    required this.formState,
    required this.registerText,
    required this.registerSubmittingText,
    this.registerType = RegisterButtonType.filled,
    this.onRegisterPressed,
    this.popButtonText = 'Cancel',
    this.popButtonStyle,
    this.disablePopWhileSubmitting = false,
    this.onBeforePop,
    this.spacing = 12.0,
    this.expandEqually = true,
  });

  bool get _isSubmitting => formState is FormStateSubmittingForm;

  @override
  Widget build(BuildContext context) {
    final left = _buildRegisterButton(context);
    final right = _buildPopButton(context);

    if (expandEqually) {
      return Row(
        children: [
          Expanded(child: left),
          SizedBox(width: spacing),
          Expanded(child: right),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        left,
        SizedBox(width: spacing),
        right,
      ],
    );
  }

  /// Builds the left-side [FormRegisterButton].
  Widget _buildRegisterButton(BuildContext context) {
    return FormRegisterButton(
      state: formState,
      buttonText: registerText,
      submitText: registerSubmittingText,
      type: registerType,
      onPressed: onRegisterPressed,
    );
  }

  /// Builds the right-side “pop” button (defaults to [OutlinedButton]).
  ///
  /// Pressing it will attempt to close the current route via [Navigator.maybePop].
  /// It can be disabled while submitting if [disablePopWhileSubmitting] is true.
  Widget _buildPopButton(BuildContext context) {
    final disabled = disablePopWhileSubmitting && _isSubmitting;

    return OutlinedButton(
      style: popButtonStyle,
      onPressed: disabled
          ? null
          : () async {
              onBeforePop?.call();
              // Try to pop if possible (no-op if we're at the root).
              await Navigator.of(context).maybePop();
            },
      child: Text(popButtonText),
    );
  }
}
