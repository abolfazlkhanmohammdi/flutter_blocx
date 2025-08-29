import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A stateless, platform-adaptive checkbox.
/// All non-function configuration is provided via [options].
class BlocxFormCheckbox<F, P, E extends Enum> extends StatelessWidget {
  /// Non-function props live here (value, labels, styles, etc.).
  final BlocxCheckboxOptions options;
  final E formKey;
  const BlocxFormCheckbox({super.key, required this.options, required this.formKey});

  @override
  Widget build(BuildContext context) {
    final child = options.hasText ? _buildListTile(context) : _buildCompact(context);

    return Padding(
      padding: options.padding ?? EdgeInsets.zero,
      child: Semantics(
        container: true,
        label: options.label,
        hint: options.subtitle,
        checked: options.isChecked,
        child: child,
      ),
    );
  }

  /// Larger touch target with label/subtitle.
  Widget _buildListTile(BuildContext context) {
    return CheckboxListTile.adaptive(
      value: options.isChecked,
      onChanged: (value) => bloc(context).add(FormEventUpdateData(data: value, key: formKey)),
      title: options.label != null ? Text(options.label!, style: options.labelStyle) : null,
      subtitle: options.subtitle != null ? Text(options.subtitle!, style: options.subtitleStyle) : null,
      controlAffinity: options.controlAffinity,
      contentPadding: options.contentPadding,
      dense: options.dense,
      visualDensity: options.visualDensity,
      activeColor: options.activeColor,
      checkColor: options.checkColor,
      focusNode: options.focusNode,
      autofocus: options.autofocus,
    );
  }

  /// Compact version without text.
  Widget _buildCompact(BuildContext context) {
    return Checkbox.adaptive(
      value: options.isChecked,
      onChanged: (value) => bloc(context).add(FormEventUpdateData(data: value, key: formKey)),
      visualDensity: options.visualDensity,
      activeColor: options.activeColor,
      checkColor: options.checkColor,
      focusNode: options.focusNode,
      autofocus: options.autofocus,
    );
  }

  FormBloc<F, P, E> bloc(BuildContext context) => BlocProvider.of<FormBloc<F, P, E>>(context);
}

/// Options bag for [BlocxFormCheckbox].
/// Put every non-function field here. The parent owns and updates [isChecked].
class BlocxCheckboxOptions {
  /// Current value.
  final bool isChecked;

  /// Optional primary/secondary text.
  final String? label;
  final String? subtitle;

  /// Layout & visuals.
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visualDensity;
  final ListTileControlAffinity controlAffinity;
  final EdgeInsetsGeometry? contentPadding;
  final bool? dense;

  /// Colors & typography.
  final Color? activeColor;
  final Color? checkColor;
  final TextStyle? labelStyle;
  final TextStyle? subtitleStyle;

  /// Focus & behavior.
  final FocusNode? focusNode;
  final bool autofocus;

  const BlocxCheckboxOptions({
    required this.isChecked,
    this.label,
    this.subtitle,
    this.padding,
    this.visualDensity,
    this.controlAffinity = ListTileControlAffinity.leading,
    this.contentPadding,
    this.dense,
    this.activeColor,
    this.checkColor,
    this.labelStyle,
    this.subtitleStyle,
    this.focusNode,
    this.autofocus = false,
  });

  bool get hasText => (label != null && label!.isNotEmpty) || (subtitle != null && subtitle!.isNotEmpty);

  BlocxCheckboxOptions copyWith({
    bool? isChecked,
    String? label,
    String? subtitle,
    EdgeInsetsGeometry? padding,
    VisualDensity? visualDensity,
    ListTileControlAffinity? controlAffinity,
    EdgeInsetsGeometry? contentPadding,
    bool? dense,
    Color? activeColor,
    Color? checkColor,
    TextStyle? labelStyle,
    TextStyle? subtitleStyle,
    FocusNode? focusNode,
    bool? autofocus,
  }) {
    return BlocxCheckboxOptions(
      isChecked: isChecked ?? this.isChecked,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      padding: padding ?? this.padding,
      visualDensity: visualDensity ?? this.visualDensity,
      controlAffinity: controlAffinity ?? this.controlAffinity,
      contentPadding: contentPadding ?? this.contentPadding,
      dense: dense ?? this.dense,
      activeColor: activeColor ?? this.activeColor,
      checkColor: checkColor ?? this.checkColor,
      labelStyle: labelStyle ?? this.labelStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      focusNode: focusNode ?? this.focusNode,
      autofocus: autofocus ?? this.autofocus,
    );
  }
}
