import 'package:blocx_core/form_bloc.dart' show BlocxBaseFormEntity, BlocxFormEventUpdateData, BlocxFormBloc;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/flutter_blocx.dart';

/// A [DropdownButtonFormField] pre-wired to a [BlocxFormBloc] field.
///
/// Dispatches [BlocxFormEventUpdateData] on every selection change and
/// automatically displays any validation error set on [formKey] via the bloc.
///
/// Requires a [BlocxFormBloc]`<F, P, E>` ancestor provided via
/// [BlocProvider].
///
/// ## Usage
///
/// Prefer the [BlocxFormWidgetState.dropdown] helper over constructing this
/// widget directly:
///
/// ```dart
/// dropdown<String>(
///   ProfileField.country,
///   items: countries.map((c) => DropdownMenuItem(value: c.code, child: Text(c.name))).toList(),
/// )
/// ```
///
/// ## Type parameters
///
/// - [F]: The form entity. Must extend [BlocxBaseFormEntity].
/// - [P]: The payload type of the parent form.
/// - [E]: The field enum type.
/// - [T]: The value type of each [DropdownMenuItem].
class BlocXFormDropdown<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum, T> extends StatefulWidget {
  /// The enum key that identifies this field in the form entity.
  final E formKey;

  /// The list of items to display in the dropdown.
  final List<DropdownMenuItem<T>> items;

  /// Optional pre-selected value. Defaults to `null`.
  final T? value;

  /// Visual and layout options for the dropdown. Defaults to
  /// [BlocXDropdownOptions] with sensible defaults.
  final BlocXDropdownOptions options;

  const BlocXFormDropdown({
    super.key,
    required this.formKey,
    required this.items,
    this.value,
    this.options = const BlocXDropdownOptions(),
  });

  @override
  State<BlocXFormDropdown<F, P, E, T>> createState() => _BlocXFormDropdownState<F, P, E, T>();
}

class _BlocXFormDropdownState<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum, T>
    extends BlocXWidgetState<BlocXFormDropdown<F, P, E, T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.options;
    final errorText = getErrorText();

    return DropdownButtonFormField<T>(
      style: o.textStyle,
      initialValue: _selectedValue,
      selectedItemBuilder: o.selectedItemBuilder,
      decoration: InputDecoration(
        filled: o.filled,
        fillColor: o.fillColor,
        errorText: errorText,
        labelText: o.labelText,
        hintText: o.hintText,
        hintStyle: o.hintStyle,
        contentPadding: o.contentPadding,
      ),
      isExpanded: o.isExpanded,
      borderRadius: BorderRadius.circular(8),
      alignment: Alignment.center,
      items: widget.items,
      onChanged: (v) => bloc.add(BlocxFormEventUpdateData(data: v, key: widget.formKey)),
    );
  }

  /// Returns the first error message set on [formKey] by the bloc, or falls
  /// back to [BlocXDropdownOptions.errorText] if provided.
  String? getErrorText() {
    final index = bloc.state.errors.keys.toList().indexWhere((k) => k == widget.formKey);
    if (index >= 0) {
      return bloc.state.errors.values.toList()[index].first;
    }
    return widget.options.errorText;
  }

  BlocxFormBloc<F, P, E> get bloc => BlocProvider.of<BlocxFormBloc<F, P, E>>(context);
}

/// Visual and layout options for [BlocXFormDropdown].
class BlocXDropdownOptions {
  /// Label text displayed above the dropdown.
  final String? labelText;

  /// Hint text displayed when no item is selected.
  final String? hintText;

  /// Whether the field background is filled. Defaults to `true`.
  final bool filled;

  /// Fill colour for the field background.
  final Color? fillColor;

  /// Border radius applied to the dropdown popup.
  final BorderRadius? borderRadius;

  /// Content padding inside the field.
  final EdgeInsetsGeometry? contentPadding;

  /// Static error text. Overridden by any bloc-driven error on the same field.
  final String? errorText;

  /// Text style for the selected item label.
  final TextStyle? textStyle;

  /// Text style for the hint text.
  final TextStyle? hintStyle;

  /// Whether to show a visible border. Defaults to `false`.
  final bool showBorder;

  /// Whether the dropdown expands to fill available width. Defaults to `true`.
  final bool isExpanded;

  /// Optional custom builder for the selected item display.
  final DropdownButtonBuilder? selectedItemBuilder;

  const BlocXDropdownOptions({
    this.labelText,
    this.selectedItemBuilder,
    this.hintText,
    this.hintStyle,
    this.isExpanded = true,
    this.filled = true,
    this.fillColor,
    this.borderRadius,
    this.textStyle,
    this.contentPadding,
    this.errorText,
    this.showBorder = false,
  });
}
