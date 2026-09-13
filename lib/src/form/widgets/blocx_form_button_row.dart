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

  /// Text shown on the secondary button.
  final String secondButtonText;

  /// Visual style used by the register button.
  final RegisterButtonType registerType;

  /// Visual and behavioral configuration for the button row.
  final BlocxFormButtonRowOptions options;

  /// Called when the register button is pressed.
  ///
  /// When null, [BlocxFormRegisterButton] submits through the nearest form
  /// widget state.
  final VoidCallback? onRegisterPressed;

  /// Called when the secondary button is pressed.
  ///
  /// When null, the secondary button calls [Navigator.maybePop].
  final VoidCallback? onSecondButtonPressed;

  /// Creates a form button row.
  const BlocxFormButtonRow({
    super.key,
    required this.formState,
    required this.registerText,
    required this.registerSubmittingText,
    this.secondButtonText = 'Cancel',
    this.registerType = RegisterButtonType.filled,
    this.options = const BlocxFormButtonRowOptions(),
    this.onRegisterPressed,
    this.onSecondButtonPressed,
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
      mainAxisSize: options.expandEqually ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (options.expandEqually)
          Expanded(child: registerButton)
        else
          registerButton,
        SizedBox(width: options.spacing),
        if (options.expandEqually)
          Expanded(child: secondaryButton)
        else
          secondaryButton,
      ],
    );

    return SizedBox(
      height: options.height,
      child: row,
    );
  }

  /// Builds the left-side [BlocxFormRegisterButton].
  Widget _buildRegisterButton(BuildContext context) {
    return BlocxFormRegisterButton<F, P, E>(
      state: formState,
      buttonText: registerText,
      submitText: registerSubmittingText,
      type: registerType,
      onPressed: onRegisterPressed,
      buttonOptions: _resolveRegisterButtonOptions(context),
    );
  }

  /// Resolves the register-button options.
  ///
  /// Default theme styling is merged with the explicitly supplied style.
  /// Explicit enabled-state styling is preserved, while fixed colors receive
  /// appropriate disabled-state equivalents.
  BlocxFormRegisterButtonOptions _resolveRegisterButtonOptions(
    BuildContext context,
  ) {
    final buttonOptions = options.registerButtonOptions;
    final defaultStyle = _defaultRegisterButtonStyle(context);
    final explicitStyle = _getExplicitRegisterButtonStyle(buttonOptions);

    final mergedStyle = switch ((defaultStyle, explicitStyle)) {
      (final ButtonStyle defaultStyle, final ButtonStyle explicitStyle) =>
        defaultStyle.merge(explicitStyle),
      (final ButtonStyle defaultStyle, null) => defaultStyle,
      (null, final ButtonStyle explicitStyle) => explicitStyle,
      (null, null) => null,
    };

    final resolvedStyle = mergedStyle == null
        ? null
        : _applyDisabledStateColors(
            context,
            style: mergedStyle,
            type: registerType,
          );

    return BlocxFormRegisterButtonOptions(
      style: resolvedStyle,
      labelTextStyle: buttonOptions.labelTextStyle,
      loadingIndicatorBuilder: buttonOptions.loadingIndicatorBuilder,
      spacing: buttonOptions.spacing,
      disableWhenInvalid: buttonOptions.disableWhenInvalid,
    );
  }

  /// Returns the explicit style configured for the current button type.
  ButtonStyle? _getExplicitRegisterButtonStyle(
    BlocxFormRegisterButtonOptions buttonOptions,
  ) {
    if (buttonOptions.style != null) {
      return buttonOptions.style;
    }

    return switch (registerType) {
      RegisterButtonType.elevated => buttonOptions.elevatedStyle,
      RegisterButtonType.filled => buttonOptions.filledStyle,
      RegisterButtonType.text => buttonOptions.textStyle,
      RegisterButtonType.outlined => buttonOptions.outlinedStyle,
      RegisterButtonType.other => null,
    };
  }

  /// Builds the default register-button style from the current [ColorScheme].
  ButtonStyle? _defaultRegisterButtonStyle(BuildContext context) {
    final scheme = colorScheme(context);
    final disabledForeground = scheme.onSurface.withValues(alpha: 0.38);
    final disabledBackground = scheme.onSurface.withValues(alpha: 0.12);
    final disabledSide = BorderSide(
      color: scheme.onSurface.withValues(alpha: 0.12),
    );

    return switch (registerType) {
      RegisterButtonType.elevated => ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return disabledBackground;
              }

              return scheme.primary;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return disabledForeground;
              }

              return scheme.onPrimary;
            },
          ),
        ),
      RegisterButtonType.filled => ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return disabledBackground;
              }

              return scheme.primary;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return disabledForeground;
              }

              return scheme.onPrimary;
            },
          ),
        ),
      RegisterButtonType.text => ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return disabledForeground;
              }

              return scheme.primary;
            },
          ),
        ),
      RegisterButtonType.outlined => ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return disabledForeground;
              }

              return scheme.primary;
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return disabledSide;
              }

              return BorderSide(color: scheme.outline);
            },
          ),
        ),
      RegisterButtonType.other => null,
    };
  }

  /// Applies disabled-state colors while preserving custom state-aware colors.
  ///
  /// When a custom style uses a fixed color for every state, the fixed value is
  /// kept for enabled states and replaced by the appropriate disabled color.
  ButtonStyle _applyDisabledStateColors(
    BuildContext context, {
    required ButtonStyle style,
    required RegisterButtonType type,
  }) {
    if (type == RegisterButtonType.other) {
      return style;
    }

    final scheme = colorScheme(context);
    final disabledForeground = scheme.onSurface.withValues(alpha: 0.38);
    final disabledBackground = scheme.onSurface.withValues(alpha: 0.12);
    final disabledSide = BorderSide(
      color: scheme.onSurface.withValues(alpha: 0.12),
    );

    final hasBackground = switch (type) {
      RegisterButtonType.elevated || RegisterButtonType.filled => true,
      _ => false,
    };

    final hasSide = type == RegisterButtonType.outlined;

    return style.copyWith(
      backgroundColor: hasBackground
          ? _withDisabledFallback<Color>(
              style.backgroundColor,
              disabledBackground,
            )
          : style.backgroundColor,
      foregroundColor: _withDisabledFallback<Color>(
        style.foregroundColor,
        disabledForeground,
      ),
      side: hasSide
          ? _withDisabledFallback<BorderSide>(
              style.side,
              disabledSide,
            )
          : style.side,
    );
  }

  /// Creates a state property that preserves custom enabled-state values.
  ///
  /// A custom disabled value is preserved when it differs from the enabled
  /// value. Otherwise, [disabledFallback] is used.
  WidgetStateProperty<T?> _withDisabledFallback<T>(
    WidgetStateProperty<T?>? property,
    T disabledFallback,
  ) {
    return WidgetStateProperty.resolveWith<T?>(
      (states) {
        if (!states.contains(WidgetState.disabled)) {
          return property?.resolve(states);
        }

        final enabledValue = property?.resolve(const <WidgetState>{});
        final disabledValue = property?.resolve(states);

        if (disabledValue != null && disabledValue != enabledValue) {
          return disabledValue;
        }

        return disabledFallback;
      },
    );
  }

  /// Builds the right-side secondary button.
  ///
  /// By default, this button calls [Navigator.maybePop].
  Widget _buildSecondaryButton(BuildContext context) {
    final disabled = options.disablePopWhileSubmitting && isSubmitting;
    final defaultStyle = _defaultSecondButtonStyle(context);

    final mergedStyle = options.secondButtonStyle == null
        ? defaultStyle
        : defaultStyle.merge(options.secondButtonStyle);

    final resolvedStyle = _applyDisabledStateColors(
      context,
      style: mergedStyle,
      type: RegisterButtonType.outlined,
    );

    return OutlinedButton(
      style: resolvedStyle,
      onPressed: disabled
          ? null
          : onSecondButtonPressed ??
              () async {
                await Navigator.of(context).maybePop();
              },
      child: Builder(
        builder: (buttonContext) {
          return Text(
            secondButtonText,
            style: _resolveSecondButtonTextStyle(buttonContext),
          );
        },
      ),
    );
  }

  /// Resolves secondary-button typography while retaining the button's
  /// state-aware foreground color.
  TextStyle? _resolveSecondButtonTextStyle(BuildContext context) {
    final customStyle = options.secondButtonTextStyle;

    if (customStyle == null) {
      return null;
    }

    final inheritedColor = DefaultTextStyle.of(context).style.color;

    if (inheritedColor == null) {
      return customStyle;
    }

    if (customStyle.foreground != null) {
      return customStyle.copyWith(
        foreground: Paint()..color = inheritedColor,
      );
    }

    return customStyle.copyWith(color: inheritedColor);
  }

  /// Builds the default secondary-button style from the current [ColorScheme].
  ButtonStyle _defaultSecondButtonStyle(BuildContext context) {
    final scheme = colorScheme(context);
    final disabledForeground = scheme.onSurface.withValues(alpha: 0.38);
    final disabledSide = BorderSide(
      color: scheme.onSurface.withValues(alpha: 0.12),
    );

    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledForeground;
          }

          return scheme.primary;
        },
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledSide;
          }

          return BorderSide(color: scheme.outline);
        },
      ),
    );
  }
}

/// Configuration options for [BlocxFormButtonRow].
///
/// These options control the row layout, submit-button configuration, and
/// secondary-button styling and behavior.
class BlocxFormButtonRowOptions {
  /// Configuration passed to the register button.
  ///
  /// Default theme styling is merged with explicitly supplied styles.
  final BlocxFormRegisterButtonOptions registerButtonOptions;

  /// Optional style for the secondary button.
  ///
  /// The style is merged with the active theme defaults.
  final ButtonStyle? secondButtonStyle;

  /// Optional typography for the secondary-button label.
  ///
  /// The button's state-aware foreground color takes precedence over the
  /// color contained in this style.
  final TextStyle? secondButtonTextStyle;

  /// Whether the secondary button should be disabled while submitting.
  final bool disablePopWhileSubmitting;

  /// Horizontal spacing between the buttons.
  ///
  /// Defaults to `12.0`.
  final double spacing;

  /// Whether both buttons should expand equally to fill the row.
  ///
  /// Defaults to `true`.
  final bool expandEqually;

  /// Height of the button row.
  ///
  /// Defaults to `40.0`.
  final double height;

  /// Creates form button row configuration options.
  const BlocxFormButtonRowOptions({
    this.registerButtonOptions = const BlocxFormRegisterButtonOptions(
      disableWhenInvalid: true,
    ),
    this.secondButtonStyle,
    this.secondButtonTextStyle,
    this.disablePopWhileSubmitting = true,
    this.spacing = 12.0,
    this.expandEqually = true,
    this.height = 40.0,
  });
}
