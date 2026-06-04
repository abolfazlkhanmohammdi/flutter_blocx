import 'package:blocx_core/form_bloc.dart'
    show BlocxBaseFormEntity, BlocxFormState, BlocxFormStateSubmittingForm;
import 'package:flutter/material.dart';
import 'package:flutter_blocx/src/core/widgets/blocx_stateless_widget.dart';

import 'blocx_form_register_button.dart';

/// Displays a horizontal row containing a submit button and a secondary button.
///
/// The left button is a [BlocxFormRegisterButton] used to submit the form.
/// The right button is an [OutlinedButton] that usually cancels or pops the
/// current route.
///
/// Type parameters:
///
/// - [F]: The form entity type.
/// - [P]: The form payload type.
/// - [E]: The form field enum type.
class BlocxFormButtonRow<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>
    extends BlocxStatelessWidget {
  /// Current typed form state used by [BlocxFormRegisterButton].
  final BlocxFormState<F, E> formState;

  /// Text shown on the register button when the form is idle.
  final String registerText;

  /// Text shown on the register button while the form is submitting.
  final String registerSubmittingText;

  /// Visual style used by the register button.
  final RegisterButtonType registerType;

  /// Called when the register button is pressed.
  ///
  /// When null, [BlocxFormRegisterButton] submits through the nearest
  /// [BlocxFormWidgetState].
  final VoidCallback? onRegisterPressed;

  /// Called when the secondary button is pressed.
  ///
  /// When null, the secondary button calls [Navigator.maybePop].
  final VoidCallback? onSecondButtonPressed;

  /// Text shown on the secondary button.
  final String secondButtonText;

  /// Optional style for the secondary button.
  final ButtonStyle? secondButtonStyle;

  /// Optional style for the submit button.
  final ButtonStyle? submitButtonStyle;

  /// Whether the secondary button should be disabled while the form submits.
  final bool disablePopWhileSubmitting;

  /// Whether the submit button should be disabled when validation errors exist.
  ///
  /// Defaults to `false` to avoid deadlocking forms that use
  /// [FormValidationMode.onSubmit].
  final bool disableRegisterWhenInvalid;

  /// Horizontal spacing between the submit and secondary buttons.
  final double spacing;

  /// Whether both buttons should expand equally to fill the row.
  final bool expandEqually;

  /// Optional text style for the register button label.
  final TextStyle? registerTextStyle;

  /// Height of the button row.
  final double height;

  /// Creates a form button row.
  const BlocxFormButtonRow({
    super.key,
    required this.formState,
    required this.registerText,
    required this.registerSubmittingText,
    this.onSecondButtonPressed,
    this.registerTextStyle,
    this.registerType = RegisterButtonType.filled,
    this.onRegisterPressed,
    this.submitButtonStyle,
    this.secondButtonText = 'Cancel',
    this.secondButtonStyle,
    this.disablePopWhileSubmitting = false,
    this.disableRegisterWhenInvalid = false,
    this.spacing = 12.0,
    this.expandEqually = true,
    this.height = 40.0,
  });

  /// Whether the form is currently submitting.
  bool get isSubmitting {
    return formState is BlocxFormStateSubmittingForm<F, E>;
  }

  @override
  Widget build(BuildContext context) {
    final registerButton = _buildRegisterButton(context);
    final secondaryButton = _buildSecondaryButton(context);

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: expandEqually ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (expandEqually) Expanded(child: registerButton) else registerButton,
        SizedBox(width: spacing),
        if (expandEqually) Expanded(child: secondaryButton) else secondaryButton,
      ],
    );

    return SizedBox(height: height, child: row);
  }

  /// Builds the left-side [BlocxFormRegisterButton].
  Widget _buildRegisterButton(BuildContext context) {
    return BlocxFormRegisterButton<F, P, E>(
      style: submitButtonStyle,
      state: formState,
      labelTextStyle: registerTextStyle,
      buttonText: registerText,
      submitText: registerSubmittingText,
      type: registerType,
      onPressed: onRegisterPressed,
      disableWhenInvalid: disableRegisterWhenInvalid,
    );
  }

  /// Builds the right-side secondary button.
  ///
  /// By default, this button calls [Navigator.maybePop].
  Widget _buildSecondaryButton(BuildContext context) {
    final disabled = disablePopWhileSubmitting && isSubmitting;

    return OutlinedButton(
      style: secondButtonStyle,
      onPressed: disabled
          ? null
          : onSecondButtonPressed ??
              () async {
                await Navigator.of(context).maybePop();
              },
      child: Text(secondButtonText),
    );
  }
}
