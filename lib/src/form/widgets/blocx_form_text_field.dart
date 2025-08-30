import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocXFormTextField<F, P, E extends Enum> extends StatefulWidget {
  /// The enum key that identifies this field in your form.
  final E formKey;

  /// Type of the text field (filled, outlined, underlined).
  final TextFieldType textFieldType;

  /// Optional controller. If omitted, one is created internally.
  final TextEditingController? controller;

  /// Standard validator for [TextFormField].
  final FormFieldValidator<String>? validator;

  /// Visual & behavioral options for the text field.
  final BlocXTextFieldOptions textFieldOptions;

  const BlocXFormTextField({
    super.key,
    required this.formKey,
    this.textFieldOptions = const BlocXTextFieldOptions(),
    required this.textFieldType, // Directly taking TextFieldType here
    this.controller,
    this.validator,
  });

  @override
  State<BlocXFormTextField<F, P, E>> createState() => BlocXFormTextFieldState<F, P, E>();
}

class BlocXFormTextFieldState<F, P, E extends Enum> extends State<BlocXFormTextField<F, P, E>> {
  TextEditingController? _internalController;
  bool get _ownsController => widget.controller == null;
  TextEditingController get _controller => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(covariant BlocXFormTextField<F, P, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _internalController?.dispose();
      }
      _internalController = widget.controller ?? TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.textFieldOptions;

    return TextFormField(
      validator: widget.validator,
      controller: _controller,
      autofocus: o.autofocus,
      style: o.style,
      keyboardType: o.keyboardType,
      textDirection: isRtl(_controller.text) ? TextDirection.rtl : TextDirection.ltr,
      textCapitalization: o.textCapitalization,
      textInputAction: o.textInputAction,
      textAlign: o.textAlign,
      maxLines: o.maxLines,
      minLines: o.minLines,
      obscureText: o.obscureText,
      decoration: _buildDecoration(context),
      onChanged: (text) {
        // Notify the bloc about this field’s new value.
        bloc.add(FormEventUpdateData(data: text, key: widget.formKey));
        // Rebuild to reflect clear-button visibility.
        if (o.showClearButton) setState(() {});
      },
    );
  }

  bool isRtl(String text) {
    // Regular expression to check for RTL characters (e.g., Arabic, Hebrew)
    final rtlPattern = RegExp(r'[\u0590-\u08FF\u200F\u202B\u202E\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    // If any character in the string matches the RTL pattern, return true
    return rtlPattern.hasMatch(text);
  }

  /// Access the nearest [FormBloc] in the tree.
  FormBloc<F, P, E> get bloc => BlocProvider.of<FormBloc<F, P, E>>(context);

  /// Build the resolved [InputDecoration] based on the [TextFieldType].
  InputDecoration _buildDecoration(BuildContext context) {
    final o = widget.textFieldOptions;

    final bool canShowClear = o.showClearButton && _controller.text.isNotEmpty && !o.obscureText;
    final Widget? suffix = canShowClear
        ? IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              bloc.add(FormEventUpdateData(data: '', key: widget.formKey));
              setState(() {});
            },
          )
        : null;

    // Hint style with lower opacity of primary color
    final hintStyle = o.hintStyle ?? TextStyle(color: Theme.of(context).colorScheme.primary.withAlpha(60));

    final BorderRadius radius = o.borderRadius ?? const BorderRadius.all(Radius.circular(8));

    switch (widget.textFieldType) {
      case TextFieldType.outlined:
        return InputDecoration(
          labelText: o.labelText,
          labelStyle: o.labelStyle,
          hintText: o.hintText,
          hintStyle: hintStyle,
          helperText: o.helperText,
          helperStyle: o.helperStyle,
          errorText: o.errorText,
          errorStyle: o.errorStyle,
          prefixIcon: o.prefixIcon,
          suffixIcon: suffix,
          filled: o.filled,
          fillColor: o.fillColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
          ),
          isDense: true,
          contentPadding: o.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );

      case TextFieldType.underlined:
        return InputDecoration(
          labelText: o.labelText,
          labelStyle: o.labelStyle,
          hintText: o.hintText,
          hintStyle: hintStyle,
          helperText: o.helperText,
          helperStyle: o.helperStyle,
          errorText: o.errorText,
          errorStyle: o.errorStyle,
          prefixIcon: o.prefixIcon,
          suffixIcon: suffix,
          filled: o.filled,
          fillColor: o.fillColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
          ),
          isDense: true,
          contentPadding: o.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );

      case TextFieldType.filled:
        return InputDecoration(
          labelText: o.labelText,
          labelStyle: o.labelStyle,
          hintText: o.hintText,
          hintStyle: hintStyle,
          helperText: o.helperText,
          helperStyle: o.helperStyle,
          errorText: o.errorText,
          errorStyle: o.errorStyle,
          prefixIcon: o.prefixIcon,
          suffixIcon: suffix,
          filled: o.filled,
          fillColor: o.fillColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          disabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          isDense: true,
          contentPadding: o.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _internalController?.dispose();
    }
    super.dispose();
  }
}

enum TextFieldType { outlined, underlined, filled }

/// Wraps common [TextField]/[TextFormField] parameters.
/// Defaults are a **filled** field with **no underline** and rounded corners.
class BlocXTextFieldOptions {
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final bool obscureText;

  // Label
  final String? labelText;
  final TextStyle? labelStyle;

  // Hint
  final String? hintText;
  final TextStyle? hintStyle;

  // Helper
  final String? helperText;
  final TextStyle? helperStyle;

  // Error (explicit). If provided, overrides validator error.
  final String? errorText;
  final TextStyle? errorStyle;

  // Icons
  final Widget? prefixIcon;

  /// Shows a clear (✕) suffix icon while there is text (ignored when [obscureText] is true).
  final bool showClearButton;

  // --- New: defaults for filled, no underline, and shape/padding ---
  /// Whether the field is filled (default: true).
  final bool filled;

  /// Fill color for the default decoration (when [decoration] is null).
  final Color? fillColor;

  /// Border radius for the default outline (when [decoration] is null).
  final BorderRadius? borderRadius;

  /// Content padding for the default decoration (when [decoration] is null).
  final EdgeInsetsGeometry? contentPadding;

  const BlocXTextFieldOptions({
    this.decoration,
    this.style,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.obscureText = false,
    // label
    this.labelText,
    this.labelStyle,
    // hint
    this.hintText,
    this.hintStyle,
    // helper
    this.helperText,
    this.helperStyle,
    // error
    this.errorText,
    this.errorStyle,
    // icons
    this.prefixIcon,
    // behavior
    this.showClearButton = true,
    // filled defaults
    this.filled = true,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
  });
}
