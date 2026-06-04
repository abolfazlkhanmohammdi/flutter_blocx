import 'package:blocx_core/form_bloc.dart' show BlocxBaseFormEntity, BlocxFormBloc, BlocxFormEventUpdateData;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/flutter_blocx.dart';

/// A [TextFormField] pre-wired to a [BlocxFormBloc] field.
///
/// Dispatches [BlocxFormEventUpdateData] on every keystroke and automatically
/// displays any validation error set on [formKey] by the bloc. It also shows a
/// loading spinner in the suffix while a unique-field check is in progress.
///
/// Requires a [BlocxFormBloc]`<F, P, E>` ancestor provided via [BlocProvider].
///
/// Prefer the [BlocxFormWidgetState.textField] helper over constructing this
/// widget directly, because the helper manages the [TextEditingController].
///
/// Type parameters:
///
/// - [F]: The form entity type.
/// - [P]: The form payload type.
/// - [E]: The form field enum type.
class BlocXFormTextField<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum> extends StatefulWidget {
  /// The enum key that identifies this field in the form entity.
  final E formKey;

  /// The visual style variant used to build the default decoration.
  final TextFieldType textFieldType;

  /// Optional external controller.
  ///
  /// When provided, this widget does not own the controller and will not
  /// dispose it. When omitted, an internal controller is created and disposed
  /// automatically.
  final TextEditingController? controller;

  /// Standard [TextFormField] validator.
  ///
  /// Runs on the raw string value. Bloc-driven validation errors are displayed
  /// through the field decoration.
  final FormFieldValidator<String>? validator;

  /// Visual and behavioural options for the text field.
  final BlocXTextFieldOptions textFieldOptions;

  /// Creates a bloc-connected text form field.
  const BlocXFormTextField({
    super.key,
    required this.formKey,
    required this.textFieldType,
    this.textFieldOptions = const BlocXTextFieldOptions(),
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

  /// Whether this state owns and should dispose the active controller.
  bool get _ownsController => widget.controller == null;

  /// The active text controller.
  TextEditingController get _controller => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(covariant BlocXFormTextField<F, P, E> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == widget.controller) return;

    final oldControllerWasInternal = oldWidget.controller == null;
    final newControllerIsInternal = widget.controller == null;

    if (oldControllerWasInternal) {
      _internalController?.dispose();
      _internalController = null;
    }

    if (newControllerIsInternal) {
      _internalController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.textFieldOptions;

    return TextFormField(
      validator: widget.validator,
      controller: _controller,
      autofocus: options.autofocus,
      style: options.style,
      inputFormatters: options.inputFormatters,
      enabled: options.enabled,
      maxLength: options.maxLength,
      keyboardType: options.keyboardType,
      textDirection: options.textDirection ?? _detectTextDirection(),
      textCapitalization: options.textCapitalization,
      textInputAction: options.textInputAction,
      textAlign: options.textAlign,
      maxLines: options.maxLines,
      minLines: options.minLines,
      obscureText: options.obscureText,
      decoration: _buildDecoration(context),
      onChanged: (text) {
        bloc.add(
          BlocxFormEventUpdateData(
            data: text,
            key: widget.formKey,
          ),
        );

        if (options.showClearButton || options.textDirection == null) {
          setState(() {});
        }
      },
    );
  }

  /// Detects text direction from the current controller text.
  TextDirection _detectTextDirection() {
    return isRtl(_controller.text) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Returns `true` when [text] contains RTL characters.
  ///
  /// Used to automatically set [TextDirection.rtl] when no explicit
  /// [BlocXTextFieldOptions.textDirection] is provided.
  bool isRtl(String text) {
    final rtlPattern = RegExp(
      r'[\u0590-\u08FF\u200F\u202B\u202E\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
    );
    return rtlPattern.hasMatch(text);
  }

  /// The nearest [BlocxFormBloc] in the widget tree.
  BlocxFormBloc<F, P, E> get bloc => BlocProvider.of<BlocxFormBloc<F, P, E>>(context);

  /// Builds the [InputDecoration] for the active text field type and options.
  InputDecoration _buildDecoration(BuildContext context) {
    final options = widget.textFieldOptions;
    final suffix = getSuffix(options);
    final errorText = getErrorText(options);

    if (options.decoration != null) {
      return options.decoration!.copyWith(
        errorText: errorText,
        suffixIcon: suffix ?? options.decoration!.suffixIcon,
      );
    }

    return InputDecoration(
      labelText: options.labelText,
      labelStyle: options.labelStyle,
      hintText: options.hintText,
      hintStyle: options.hintStyle,
      helperText: options.helperText,
      helperStyle: options.helperStyle,
      errorText: errorText,
      errorStyle: options.errorStyle,
      prefixIcon: options.prefix,
      suffixIcon: suffix,
      filled: _shouldUseFilledBackground(options),
      fillColor: options.fillColor,
      isDense: true,
      contentPadding: options.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: _buildBorder(options),
    );
  }

  /// Whether the field should use a filled background.
  bool _shouldUseFilledBackground(BlocXTextFieldOptions options) {
    return switch (widget.textFieldType) {
      TextFieldType.filled => options.filled,
      TextFieldType.outlined => false,
      TextFieldType.underlined => false,
    };
  }

  /// Builds the default border for [widget.textFieldType].
  InputBorder _buildBorder(BlocXTextFieldOptions options) {
    final borderRadius = options.borderRadius ?? BorderRadius.circular(12);

    return switch (widget.textFieldType) {
      TextFieldType.outlined => OutlineInputBorder(
          borderRadius: borderRadius,
        ),
      TextFieldType.underlined => const UnderlineInputBorder(),
      TextFieldType.filled => OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
    };
  }

  @override
  void dispose() {
    if (_ownsController) {
      _internalController?.dispose();
    }
    super.dispose();
  }

  /// Whether a unique-field check is currently running for this field.
  bool get isCheckingUniqueField => bloc.state.checkingUniqueFields.contains(widget.formKey);

  /// Returns the suffix widget for the field.
  ///
  /// Priority order:
  ///
  /// 1. Progress indicator while [isCheckingUniqueField] is true.
  /// 2. Explicit [BlocXTextFieldOptions.suffix] if set.
  /// 3. Clear button when [BlocXTextFieldOptions.showClearButton] is true.
  Widget? getSuffix(BlocXTextFieldOptions options) {
    if (isCheckingUniqueField) {
      return SizedBox.square(
        dimension: 8,
        child: CircularProgressIndicator(
          color: colorScheme.primary,
          padding: const EdgeInsets.all(8),
        ),
      );
    }

    if (options.suffix != null) return options.suffix;

    final canShowClear = options.showClearButton && !options.obscureText && _controller.text.isNotEmpty;

    if (!canShowClear) return null;

    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
      icon: const Icon(Icons.clear),
      onPressed: _controller.text.isEmpty
          ? null
          : () {
              _controller.clear();
              bloc.add(
                BlocxFormEventUpdateData(
                  data: '',
                  key: widget.formKey,
                ),
              );
              setState(() {});
            },
    );
  }

  /// Returns the first bloc-driven error for this field.
  ///
  /// Falls back to [BlocXTextFieldOptions.errorText] when the bloc has no error
  /// for [widget.formKey].
  String? getErrorText(BlocXTextFieldOptions options) {
    final index = bloc.state.errors.keys.toList().indexWhere((key) => key == widget.formKey);

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

  /// Filled background style.
  filled,
}

/// Configuration options for [BlocXFormTextField].
///
/// These options control both visual styling and input behaviour.
class BlocXTextFieldOptions {
  /// Optional base [InputDecoration].
  ///
  /// When provided, the decoration is used as the base decoration. Runtime
  /// values such as bloc-driven [errorText] and suffix loading indicators are
  /// still merged into it.
  final InputDecoration? decoration;

  /// Text style for the input value.
  final TextStyle? style;

  /// Keyboard type hint.
  final TextInputType? keyboardType;

  /// Explicit text direction.
  ///
  /// When omitted, direction is detected from the current text.
  final TextDirection? textDirection;

  /// Text capitalisation mode.
  final TextCapitalization textCapitalization;

  /// Action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Horizontal alignment of the input text.
  final TextAlign textAlign;

  /// Maximum number of lines.
  final int? maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum character count.
  final int? maxLength;

  /// Minimum character count.
  ///
  /// This option is metadata only. Validation should be implemented through
  /// bloc validators or [TextFormField.validator].
  final int? minLength;

  /// Whether the field requests focus on first build.
  final bool autofocus;

  /// Whether the field is interactive.
  final bool enabled;

  /// Whether to obscure input.
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

  /// Static error text.
  ///
  /// Bloc-driven errors override this value.
  final String? errorText;

  /// Style for the error text.
  final TextStyle? errorStyle;

  /// Widget placed at the start of the field.
  final Widget? prefix;

  /// Widget placed at the end of the field.
  ///
  /// Overridden by the unique-field progress indicator when a check is running.
  final Widget? suffix;

  /// Whether to show a clear button when the field has text.
  ///
  /// Ignored when [obscureText] is `true`.
  final bool showClearButton;

  /// Whether the filled text field variant uses a filled background.
  ///
  /// This only affects [TextFieldType.filled]. Outlined and underlined variants
  /// are not filled by default.
  final bool filled;

  /// Fill colour for the field background.
  final Color? fillColor;

  /// Border radius for the default outlined and filled decorations.
  final BorderRadius? borderRadius;

  /// Content padding inside the field.
  final EdgeInsetsGeometry? contentPadding;

  /// Creates text field configuration options.
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
