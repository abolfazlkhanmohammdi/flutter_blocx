import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A form-connected [TextFormField] that reports its value to a [FormBloc].
///
/// Generics:
/// - **F**: form data type held by the bloc
/// - **P**: payload type emitted by events/effects
/// - **E**: enum used as the *key* for form inputs (one enum value per field)
///
/// Behavior:
/// - On every text change, dispatches `FormEventUpdateData(data: <text>, key: <E>)`.
/// - If you pass a [controller], this widget **won’t** dispose it. If not,
///   an internal one is created and disposed automatically.
/// - Styling & behavior are controlled via [textFieldOptions].
class BlocXFormTextField<F, P, E extends Enum> extends StatefulWidget {
  /// The enum key that identifies this field in your form.
  final E formKey;

  /// Visual & behavioral options for the text field.
  final BlocXTextFieldOptions textFieldOptions;

  /// Optional controller. If omitted, one is created internally.
  final TextEditingController? controller;

  /// Standard validator for [TextFormField].
  final FormFieldValidator<String>? validator;

  const BlocXFormTextField({
    super.key,
    required this.formKey,
    this.textFieldOptions = const BlocXTextFieldOptions(),
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
      textCapitalization: o.textCapitalization,
      textInputAction: o.textInputAction,
      textAlign: o.textAlign,
      maxLines: o.maxLines,
      minLines: o.minLines,
      obscureText: o.obscureText,
      decoration: _buildDecoration(context, o),
      onChanged: (text) {
        // Notify the bloc about this field’s new value.
        bloc.add(FormEventUpdateData(data: text, key: widget.formKey));
        // Rebuild to reflect clear-button visibility.
        if (o.showClearButton) setState(() {});
      },
    );
  }

  /// Access the nearest [FormBloc] in the tree.
  FormBloc<F, P, E> get bloc => BlocProvider.of<FormBloc<F, P, E>>(context);

  /// Build the resolved [InputDecoration] using [BlocXTextFieldOptions].
  /// Defaults: **filled** and **no underline/border**.
  InputDecoration _buildDecoration(BuildContext context, BlocXTextFieldOptions o) {
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

    if (o.decoration != null) {
      // Respect user-provided decoration; only merge common bits.
      return o.decoration!.copyWith(
        labelText: o.labelText ?? o.decoration!.labelText,
        labelStyle: o.labelStyle ?? o.decoration!.labelStyle,
        hintText: o.hintText ?? o.decoration!.hintText,
        hintStyle: o.hintStyle ?? o.decoration!.hintStyle,
        helperText: o.helperText ?? o.decoration!.helperText,
        helperStyle: o.helperStyle ?? o.decoration!.helperStyle,
        errorText: o.errorText ?? o.decoration!.errorText,
        errorStyle: o.errorStyle ?? o.decoration!.errorStyle,
        prefixIcon: o.prefixIcon ?? o.decoration!.prefixIcon,
        suffixIcon: suffix ?? o.decoration!.suffixIcon,
      );
    }

    // ---- Default look: filled, no underline, rounded ----
    final BorderRadius radius = o.borderRadius ?? const BorderRadius.all(Radius.circular(12));

    final OutlineInputBorder noLine = OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none);

    return InputDecoration(
      // label / hint / helper / error
      labelText: o.labelText,
      labelStyle: o.labelStyle,
      hintText: o.hintText,
      hintStyle: o.hintStyle,
      helperText: o.helperText,
      helperStyle: o.helperStyle,
      errorText: o.errorText,
      errorStyle: o.errorStyle,

      // icons
      prefixIcon: o.prefixIcon,
      suffixIcon: suffix,

      // filled, no underline
      filled: o.filled, // default true
      fillColor: o.fillColor ?? Theme.of(context).colorScheme.surfaceVariant,

      // remove underlines (all states)
      border: noLine,
      enabledBorder: noLine,
      focusedBorder: noLine,
      errorBorder: noLine,
      disabledBorder: noLine,

      isDense: true,
      contentPadding: o.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  void dispose() {
    if (_ownsController) {
      _internalController?.dispose();
    }
    super.dispose();
  }
}

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
