import 'package:flutter/services.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blocx_core/form_bloc.dart' show BlocxBaseFormEntity, BlocxFormEventUpdateData, BlocxFormBloc;

/// A [TextFormField] pre-wired to a [BlocxFormBloc] field.
///
/// Dispatches [BlocxFormEventUpdateData] on every keystroke and automatically
/// displays any validation error set on [formKey] by the bloc. Also shows a
/// loading spinner in the suffix while a unique-field check is in progress.
///
/// Requires a [BlocxFormBloc]`<F, P, E>` ancestor provided via [BlocProvider].
///
/// ## Usage
///
/// Prefer the [BlocxFormWidgetState.textField] helper over constructing this
/// widget directly — it manages the [TextEditingController] for you:
///
/// ```dart
/// textField(LoginField.email, options: BlocXTextFieldOptions(labelText: 'Email'))
/// ```
///
/// ## Type parameters
///
/// - [F]: The form entity. Must extend [BlocxBaseFormEntity].
/// - [P]: The payload type of the parent form.
/// - [E]: The field enum type.
class BlocXFormTextField<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum> extends StatefulWidget {
  /// The enum key that identifies this field in the form entity.
  final E formKey;

  /// Visual style variant. Defaults to [TextFieldType.filled].
  final TextFieldType textFieldType;

  /// Optional external controller.
  ///
  /// When provided, this widget does not own the controller and will not
  /// dispose it. When omitted, an internal controller is created and disposed
  /// automatically.
  final TextEditingController? controller;

  /// Standard [TextFormField] validator. Runs on the raw string value.
  final FormFieldValidator<String>? validator;

  /// Visual and behavioural options. Defaults to [BlocXTextFieldOptions].
  final BlocXTextFieldOptions textFieldOptions;

  const BlocXFormTextField({
    super.key,
    required this.formKey,
    this.textFieldOptions = const BlocXTextFieldOptions(),
    required this.textFieldType,
    this.controller,
    this.validator,
  });

  @override
  State<BlocXFormTextField<F, P, E>> createState() => BlocXFormTextFieldState<F, P, E>();
}

/// State for [BlocXFormTextField].
class BlocXFormTextFieldState<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>
    extends BlocXWidgetState<BlocXFormTextField<F, P, E>> {
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
      if (_ownsController) _internalController?.dispose();
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
      inputFormatters: o.inputFormatters,
      enabled: o.enabled,
      maxLength: o.maxLength,
      keyboardType: o.keyboardType,
      textDirection: o.textDirection ?? (isRtl(_controller.text) ? TextDirection.rtl : TextDirection.ltr),
      textCapitalization: o.textCapitalization,
      textInputAction: o.textInputAction,
      textAlign: o.textAlign,
      maxLines: o.maxLines,
      minLines: o.minLines,
      obscureText: o.obscureText,
      decoration: _buildDecoration(context),
      onChanged: (text) {
        bloc.add(BlocxFormEventUpdateData(data: text, key: widget.formKey));
        if (o.showClearButton) setState(() {});
      },
    );
  }

  /// Returns `true` when [text] contains RTL characters (Arabic, Hebrew, etc.).
  ///
  /// Used to automatically set [TextDirection.rtl] when no explicit
  /// [BlocXTextFieldOptions.textDirection] is provided.
  bool isRtl(String text) {
    final rtlPattern = RegExp(r'[\u0590-\u08FF\u200F\u202B\u202E\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return rtlPattern.hasMatch(text);
  }

  /// The nearest [BlocxFormBloc] in the widget tree.
  BlocxFormBloc<F, P, E> get bloc => BlocProvider.of<BlocxFormBloc<F, P, E>>(context);

  /// Builds the [InputDecoration] for the chosen [TextFieldType].
  InputDecoration _buildDecoration(BuildContext context) {
    final o = widget.textFieldOptions;
    final Widget? suffix = getSuffix(o);
    final String? errorText = getErrorText(o);

    final base = InputDecoration(
      labelText: o.labelText,
      labelStyle: o.labelStyle,
      hintText: o.hintText,
      hintStyle: o.hintStyle,
      helperText: o.helperText,
      helperStyle: o.helperStyle,
      errorText: errorText,
      errorStyle: o.errorStyle,
      prefixIcon: o.prefix,
      suffixIcon: suffix,
      filled: o.filled,
      fillColor: o.fillColor,
      isDense: true,
      contentPadding: o.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );

    return base;
  }

  @override
  void dispose() {
    if (_ownsController) _internalController?.dispose();
    super.dispose();
  }

  /// Whether a unique-field check is currently running for this field.
  bool get isCheckingUniqueField => bloc.state.checkingUniqueFields.contains(widget.formKey);

  /// Returns the suffix widget.
  ///
  /// Priority order:
  /// 1. Spinning progress indicator while [isCheckingUniqueField] is true.
  /// 2. Explicit [BlocXTextFieldOptions.suffix] if set.
  /// 3. Clear button if [BlocXTextFieldOptions.showClearButton] is true and
  ///    the field has text.
  Widget? getSuffix(BlocXTextFieldOptions o) {
    if (isCheckingUniqueField) {
      return SizedBox.square(
        dimension: 8,
        child: CircularProgressIndicator(color: colorScheme.primary, padding: EdgeInsets.all(8)),
      );
    }
    if (o.suffix != null) return o.suffix;

    final bool canShowClear = o.showClearButton && _controller.text.isNotEmpty;
    return canShowClear
        ? IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
            icon: const Icon(Icons.clear),
            onPressed: _controller.text.isEmpty
                ? null
                : () {
                    _controller.clear();
                    bloc.add(BlocxFormEventUpdateData(data: '', key: widget.formKey));
                    setState(() {});
                  },
          )
        : null;
  }

  /// Returns the first bloc-driven error for this field, or falls back to
  /// [BlocXTextFieldOptions.errorText].
  String? getErrorText(BlocXTextFieldOptions options) {
    final index = bloc.state.errors.keys.toList().indexWhere((e) => e == widget.formKey);
    if (index >= 0) {
      return bloc.state.errors.values.toList()[index].first;
    }
    return options.errorText;
  }
}

/// The visual style variant for a [BlocXFormTextField].
enum TextFieldType {
  /// Material outlined style.
  outlined,

  /// Underline-only style.
  underlined,

  /// Filled background style (default).
  filled,
}

/// Configuration bag for [BlocXFormTextField].
///
/// All fields are optional and have sensible defaults. Pass only what differs
/// from the defaults.
class BlocXTextFieldOptions {
  /// Override the entire [InputDecoration]. When set, all other decoration
  /// fields are ignored.
  final InputDecoration? decoration;

  /// Text style for the input value.
  final TextStyle? style;

  /// Keyboard type hint (e.g. [TextInputType.emailAddress]).
  final TextInputType? keyboardType;

  /// Explicit text direction. Auto-detected from content when omitted.
  final TextDirection? textDirection;

  /// Text capitalisation mode. Defaults to [TextCapitalization.none].
  final TextCapitalization textCapitalization;

  /// Action button on the keyboard (e.g. [TextInputAction.next]).
  final TextInputAction? textInputAction;

  /// Horizontal alignment of the input text. Defaults to [TextAlign.start].
  final TextAlign textAlign;

  /// Maximum number of lines. Defaults to `1`.
  final int? maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum character count (shows counter below the field).
  final int? maxLength;

  /// Minimum character count (validated externally).
  final int? minLength;

  /// Whether the field requests focus on first build. Defaults to `false`.
  final bool autofocus;

  /// Whether the field is interactive. Defaults to `true`.
  final bool enabled;

  /// Whether to obscure input (e.g. passwords). Defaults to `false`.
  final bool obscureText;

  /// Input formatters applied before the value reaches the bloc.
  final List<TextInputFormatter> inputFormatters;

  /// Label text displayed as a floating label.
  final String? labelText;

  /// Style for [labelText].
  final TextStyle? labelStyle;

  /// Hint text displayed when the field is empty.
  final String? hintText;

  /// Style for [hintText].
  final TextStyle? hintStyle;

  /// Helper text displayed below the field.
  final String? helperText;

  /// Style for [helperText].
  final TextStyle? helperStyle;

  /// Static error text. Overridden by any bloc-driven error on the same field.
  final String? errorText;

  /// Style for the error text.
  final TextStyle? errorStyle;

  /// Widget placed at the start of the field (prefix icon area).
  final Widget? prefix;

  /// Widget placed at the end of the field (suffix icon area).
  ///
  /// Overridden by the unique-field progress indicator when a check is running.
  final Widget? suffix;

  /// Whether to show a clear (✕) button when the field has text.
  ///
  /// Ignored when [obscureText] is `true`. Defaults to `true`.
  final bool showClearButton;

  /// Whether the field background is filled. Defaults to `true`.
  final bool filled;

  /// Fill colour for the field background.
  final Color? fillColor;

  /// Border radius for the default decoration.
  final BorderRadius? borderRadius;

  /// Content padding inside the field.
  final EdgeInsetsGeometry? contentPadding;

  const BlocXTextFieldOptions({
    this.decoration,
    this.style,
    this.keyboardType,
    this.textDirection,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters = const [],
    this.minLength,
    this.autofocus = false,
    this.obscureText = false,
    this.labelText,
    this.labelStyle,
    this.hintText,
    this.hintStyle,
    this.helperText,
    this.helperStyle,
    this.errorText,
    this.errorStyle,
    this.prefix,
    this.suffix,
    this.showClearButton = true,
    this.filled = true,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.enabled = true,
  });
}
