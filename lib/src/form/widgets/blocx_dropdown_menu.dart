import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart'
    show BaseFormEntity, BlocxFormEventUpdateData, BlocxFormBloc;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/flutter_blocx.dart';

class BlocXFormDropdown<F extends BaseFormEntity<F, E>, P, E extends Enum, T>
    extends StatefulWidget {
  final E formKey;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final BlocXDropdownOptions options;

  const BlocXFormDropdown({
    super.key,
    required this.formKey,
    required this.items,
    this.value,
    this.options = const BlocXDropdownOptions(),
  });

  @override
  State<BlocXFormDropdown<F, P, E, T>> createState() =>
      _BlocXFormDropdownState<F, P, E, T>();
}

class _BlocXFormDropdownState<F extends BaseFormEntity<F, E>, P, E extends Enum,
    T> extends BlocXWidgetState<BlocXFormDropdown<F, P, E, T>> {
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
      onChanged: (v) =>
          bloc.add(BlocxFormEventUpdateData(data: v, key: widget.formKey)),
    );
  }

  String? getErrorText() {
    int index =
        bloc.state.errors.keys.toList().indexWhere((k) => k == widget.formKey);
    if (index >= 0) {
      return bloc.state.errors.values.toList()[index].first;
    }
    return widget.options.errorText;
  }

  BlocxFormBloc<F, P, E> get bloc =>
      BlocProvider.of<BlocxFormBloc<F, P, E>>(context);
}

class BlocXDropdownOptions {
  final String? labelText;
  final String? hintText;
  final bool filled;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final String? errorText;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool showBorder;
  final bool isExpanded;
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
