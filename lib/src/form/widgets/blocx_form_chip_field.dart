import 'package:blocx_core/form_bloc.dart'
    show BlocxBaseFormEntity, BlocxFormBloc, BlocxFormEventUpdateData;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocx_form_scope.dart';

/// Describes a single selectable chip option inside [BlocxFormChipField].
class BlocxChipOption<T> {
  /// Underlying value dispatched via [BlocxFormEventUpdateData] on selection.
  final T value;

  /// Human-readable chip label.
  final String label;

  /// Optional leading avatar widget displayed inside the chip.
  final Widget? avatar;

  /// Optional tooltip displayed on long press or hover.
  final String? tooltip;

  /// Whether this option can be selected. Defaults to `true`.
  final bool enabled;

  /// Optional explicit key override for the rendered chip widget.
  ///
  /// Defaults to `ValueKey('blocx_filter_$value')`, compatible with
  /// `find.blocxFilter(...)` in `package:flutter_blocx/testing.dart`.
  final Key? itemKey;

  /// Creates a chip option.
  const BlocxChipOption({
    required this.value,
    required this.label,
    this.avatar,
    this.tooltip,
    this.enabled = true,
    this.itemKey,
  });
}

/// Visual and behavioural options for [BlocxFormChipField].
class BlocxChipFieldOptions {
  /// Optional label rendered above the chip wrap.
  final String? labelText;

  /// Optional helper text rendered below the chip wrap when no error is active.
  final String? helperText;

  /// Optional static error text overridden by active bloc errors on the field.
  final String? errorText;

  /// Whether multiple options can be selected simultaneously (`FilterChip`).
  ///
  /// When `false` (default), renders mutually exclusive `ChoiceChip` items.
  final bool multiSelect;

  /// When `true` in single-select mode, tapping the active chip clears selection
  /// (`null`). Defaults to `true`.
  final bool allowDeselect;

  /// Horizontal gap between adjacent chips. Defaults to `8.0`.
  final double spacing;

  /// Vertical gap between wrapped rows of chips. Defaults to `8.0`.
  final double runSpacing;

  /// Horizontal alignment passed to [Wrap.alignment].
  final WrapAlignment alignment;

  /// Outer padding around the field.
  final EdgeInsetsGeometry? padding;

  /// Whether multi-select [FilterChip] items display a checkmark when selected.
  final bool showCheckmark;

  /// Whether user interaction is enabled across all options. Defaults to `true`.
  final bool enabled;

  /// In [multiSelect] mode, forces dispatched updates to emit a `Set<T>` even
  /// when the current bloc value is `null`. When `false`, emits `List<T>` unless
  /// the existing value on `formData` is already a `Set`.
  final bool emitSetInMultiSelect;

  /// Text style applied to [labelText].
  final TextStyle? labelStyle;

  /// Text style applied to [helperText].
  final TextStyle? helperStyle;

  /// Text style applied to validation errors.
  final TextStyle? errorStyle;

  /// Creates chip field configuration options.
  const BlocxChipFieldOptions({
    this.labelText,
    this.helperText,
    this.errorText,
    this.multiSelect = false,
    this.allowDeselect = true,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.alignment = WrapAlignment.start,
    this.padding,
    this.showCheckmark = true,
    this.enabled = true,
    this.emitSetInMultiSelect = true,
    this.labelStyle,
    this.helperStyle,
    this.errorStyle,
  });
}

/// A reactive chip-group selector wired to a [BlocxFormBloc] field.
///
/// Supports both single-select (`ChoiceChip`) and multi-select (`FilterChip`)
/// modes. Each chip automatically receives a semantic
/// `ValueKey('blocx_filter_${option.value}')` key so integration and widget
/// tests can locate options via `find.blocxFilter(value)`.
class BlocxFormChipField<
  F extends BlocxBaseFormEntity<F, E>,
  P,
  E extends Enum,
  T
>
    extends StatelessWidget {
  /// The enum key identifying this field in the form entity.
  final E formKey;

  /// Selectable chip options.
  final List<BlocxChipOption<T>> options;

  /// Visual and behavioural configuration.
  final BlocxChipFieldOptions fieldOptions;

  /// Optional explicit single-select value override.
  final T? value;

  /// Optional explicit multi-select value override.
  final Iterable<T>? selectedValues;

  /// Creates a reactive chip field connected to [formKey].
  const BlocxFormChipField({
    super.key,
    required this.formKey,
    required this.options,
    this.fieldOptions = const BlocxChipFieldOptions(),
    this.value,
    this.selectedValues,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBloc =
        BlocxFormScope.maybeOf<F, P, E>(context)?.bloc ??
        BlocProvider.of<BlocxFormBloc<F, P, E>>(context);

    final rawValue = resolvedBloc.formData.getValueByKey(formKey);
    final errorText =
        resolvedBloc.state.errorByKey(formKey) ?? fieldOptions.errorText;
    final theme = Theme.of(context);

    final Set<T> activeSet = _resolveActiveSet(rawValue);
    final T? activeSingle = _resolveActiveSingle(rawValue);
    final bool shouldEmitList = switch (rawValue) {
      final List<dynamic> _ => true,
      final Set<dynamic> _ => false,
      _ => !fieldOptions.emitSetInMultiSelect,
    };

    return KeyedSubtree(
      key: ValueKey<String>('blocx_field_${formKey.name}'),
      child: Padding(
        padding: fieldOptions.padding ?? EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fieldOptions.labelText != null &&
                fieldOptions.labelText!.isNotEmpty) ...[
              Text(
                fieldOptions.labelText!,
                style: fieldOptions.labelStyle ?? theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: fieldOptions.spacing,
              runSpacing: fieldOptions.runSpacing,
              alignment: fieldOptions.alignment,
              children: options.map((option) {
                final chipKey =
                    option.itemKey ??
                    ValueKey<String>('blocx_filter_${option.value}');
                final canTap = fieldOptions.enabled && option.enabled;

                if (fieldOptions.multiSelect) {
                  final isSelected = activeSet.contains(option.value);
                  return FilterChip(
                    key: chipKey,
                    avatar: option.avatar,
                    label: Text(option.label),
                    tooltip: option.tooltip,
                    selected: isSelected,
                    showCheckmark: fieldOptions.showCheckmark,
                    onSelected: canTap
                        ? (selected) {
                            final next = Set<T>.of(activeSet);
                            if (selected) {
                              next.add(option.value);
                            } else {
                              next.remove(option.value);
                            }
                            final dynamic payload = shouldEmitList
                                ? next.toList(growable: false)
                                : Set<T>.unmodifiable(next);
                            resolvedBloc.add(
                              BlocxFormEventUpdateData<E>(
                                data: payload,
                                key: formKey,
                              ),
                            );
                          }
                        : null,
                  );
                }

                final isSelected = activeSingle == option.value;
                return ChoiceChip(
                  key: chipKey,
                  avatar: option.avatar,
                  label: Text(option.label),
                  tooltip: option.tooltip,
                  selected: isSelected,
                  onSelected: canTap
                      ? (selected) {
                          final T? nextValue;
                          if (!selected ||
                              (isSelected && fieldOptions.allowDeselect)) {
                            nextValue = null;
                          } else {
                            nextValue = option.value;
                          }
                          resolvedBloc.add(
                            BlocxFormEventUpdateData<E>(
                              data: nextValue,
                              key: formKey,
                            ),
                          );
                        }
                      : null,
                );
              }).toList(),
            ),
            if (errorText != null && errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  errorText,
                  style:
                      fieldOptions.errorStyle ??
                      theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                ),
              )
            else if (fieldOptions.helperText != null &&
                fieldOptions.helperText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  fieldOptions.helperText!,
                  style:
                      fieldOptions.helperStyle ??
                      theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  T? _resolveActiveSingle(dynamic rawValue) {
    if (value != null) return value;
    return rawValue is T ? rawValue : null;
  }

  Set<T> _resolveActiveSet(dynamic rawValue) {
    if (selectedValues != null) return Set<T>.of(selectedValues!);
    if (rawValue is Iterable) {
      return rawValue.whereType<T>().toSet();
    }
    return <T>{};
  }
}
