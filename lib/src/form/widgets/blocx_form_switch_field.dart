import 'package:blocx_core/form_bloc.dart'
    show BlocxBaseFormEntity, BlocxFormBloc, BlocxFormEventUpdateData;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocx_form_scope.dart';

/// A reactive platform-adaptive switch control wired to a [BlocxFormBloc]
/// boolean field.
///
/// When [BlocxSwitchOptions.value] is `null`, the current boolean state is read
/// from `bloc.formData.getValueByKey(formKey)`. Dispatches
/// [BlocxFormEventUpdateData] on change and displays any field validation error
/// set on [formKey].
class BlocxFormSwitchField<
  F extends BlocxBaseFormEntity<F, E>,
  P,
  E extends Enum
>
    extends StatelessWidget {
  /// The enum key that identifies this boolean field in the form entity.
  final E formKey;

  /// Visual and behavioural configuration for the switch control.
  final BlocxSwitchOptions options;

  /// Creates a reactive switch form field.
  const BlocxFormSwitchField({
    super.key,
    required this.formKey,
    this.options = const BlocxSwitchOptions(),
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBloc =
        BlocxFormScope.maybeOf<F, P, E>(context)?.bloc ??
        BlocProvider.of<BlocxFormBloc<F, P, E>>(context);

    final rawValue =
        options.value ?? resolvedBloc.formData.getValueByKey(formKey);
    final isChecked = rawValue is bool ? rawValue : false;

    final errorText =
        resolvedBloc.state.errorByKey(formKey) ?? options.errorText;

    final ValueChanged<bool>? onChanged = options.enabled
        ? (next) => resolvedBloc.add(
            BlocxFormEventUpdateData<E>(data: next, key: formKey),
          )
        : null;

    final switchKey = ValueKey<String>('blocx_switch_${formKey.name}');

    final Widget control = options.hasText
        ? SwitchListTile.adaptive(
            key: switchKey,
            value: isChecked,
            onChanged: onChanged,
            title: options.label != null
                ? Text(options.label!, style: options.labelStyle)
                : null,
            subtitle: options.subtitle != null
                ? Text(options.subtitle!, style: options.subtitleStyle)
                : null,
            controlAffinity: options.controlAffinity,
            contentPadding: options.contentPadding,
            dense: options.dense,
            thumbColor: options.thumbColor,
            trackColor: options.trackColor,
            focusNode: options.focusNode,
            autofocus: options.autofocus,
          )
        : Switch.adaptive(
            key: switchKey,
            value: isChecked,
            onChanged: onChanged,
            thumbColor: options.thumbColor,
            trackColor: options.trackColor,
            focusNode: options.focusNode,
            autofocus: options.autofocus,
          );

    final theme = Theme.of(context);

    return Padding(
      padding: options.padding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            container: true,
            label: options.label,
            hint: options.subtitle,
            toggled: isChecked,
            enabled: options.enabled,
            child: control,
          ),
          if (errorText != null && errorText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
              child: Text(
                errorText,
                style:
                    options.errorStyle ??
                    theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Visual and behavioural options for [BlocxFormSwitchField].
class BlocxSwitchOptions {
  /// Optional explicit boolean value override.
  ///
  /// When omitted, [BlocxFormSwitchField] reads the value directly from the
  /// nearest [BlocxFormBloc]'s `formData`.
  final bool? value;

  /// Whether user interaction is enabled. Defaults to `true`.
  final bool enabled;

  /// Optional primary label rendered via [SwitchListTile.adaptive].
  final String? label;

  /// Optional secondary subtitle rendered below [label].
  final String? subtitle;

  /// Optional static error text displayed when the bloc has no error for the field.
  final String? errorText;

  /// Outer padding around the switch control.
  final EdgeInsetsGeometry? padding;

  /// Padding passed to [SwitchListTile.adaptive.contentPadding].
  final EdgeInsetsGeometry? contentPadding;

  /// Controls whether the switch appears at the start or end of the tile.
  final ListTileControlAffinity controlAffinity;

  /// Whether the list tile uses compact vertical density.
  final bool? dense;

  /// Custom thumb colors resolved for each [WidgetState].
  final WidgetStateProperty<Color?>? thumbColor;

  /// Custom track colors resolved for each [WidgetState].
  final WidgetStateProperty<Color?>? trackColor;

  /// Text style applied to [label].
  final TextStyle? labelStyle;

  /// Text style applied to [subtitle].
  final TextStyle? subtitleStyle;

  /// Text style applied to validation error messages.
  final TextStyle? errorStyle;

  /// Optional focus node attached to the switch control.
  final FocusNode? focusNode;

  /// Whether the switch requests focus automatically on mount.
  final bool autofocus;

  /// Creates switch configuration options.
  const BlocxSwitchOptions({
    this.value,
    this.enabled = true,
    this.label,
    this.subtitle,
    this.errorText,
    this.padding,
    this.contentPadding,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.dense,
    this.thumbColor,
    this.trackColor,
    this.labelStyle,
    this.subtitleStyle,
    this.errorStyle,
    this.focusNode,
    this.autofocus = false,
  });

  /// Whether a label or subtitle has been configured.
  bool get hasText =>
      (label != null && label!.isNotEmpty) ||
      (subtitle != null && subtitle!.isNotEmpty);

  /// Returns a copy of these options with the given fields replaced.
  BlocxSwitchOptions copyWith({
    bool? value,
    bool? enabled,
    String? label,
    String? subtitle,
    String? errorText,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? contentPadding,
    ListTileControlAffinity? controlAffinity,
    bool? dense,
    WidgetStateProperty<Color?>? thumbColor,
    WidgetStateProperty<Color?>? trackColor,
    TextStyle? labelStyle,
    TextStyle? subtitleStyle,
    TextStyle? errorStyle,
    FocusNode? focusNode,
    bool? autofocus,
  }) {
    return BlocxSwitchOptions(
      value: value ?? this.value,
      enabled: enabled ?? this.enabled,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      errorText: errorText ?? this.errorText,
      padding: padding ?? this.padding,
      contentPadding: contentPadding ?? this.contentPadding,
      controlAffinity: controlAffinity ?? this.controlAffinity,
      dense: dense ?? this.dense,
      thumbColor: thumbColor ?? this.thumbColor,
      trackColor: trackColor ?? this.trackColor,
      labelStyle: labelStyle ?? this.labelStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      focusNode: focusNode ?? this.focusNode,
      autofocus: autofocus ?? this.autofocus,
    );
  }
}
