import 'package:blocx_core/form_bloc.dart'
    show BlocxBaseFormEntity, BlocxFormBloc, BlocxFormEventUpdateData;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocx_form_scope.dart';

/// Describes one option segment inside [BlocxFormSegmentedField].
class BlocxSegmentOption<T> {
  /// Underlying value associated with this segment.
  final T value;

  /// Convenience text label displayed in the segment when [labelWidget] is
  /// omitted.
  final String? label;

  /// Optional custom widget label overriding [label].
  final Widget? labelWidget;

  /// Optional icon displayed inside the segment.
  final Widget? icon;

  /// Optional tooltip displayed on hover or long press.
  final String? tooltip;

  /// Whether this individual segment is interactive. Defaults to `true`.
  final bool enabled;

  /// Creates a segment option.
  const BlocxSegmentOption({
    required this.value,
    this.label,
    this.labelWidget,
    this.icon,
    this.tooltip,
    this.enabled = true,
  });
}

/// Visual and behavioural options for [BlocxFormSegmentedField].
class BlocxSegmentedFieldOptions {
  /// Optional label rendered above the segmented button control.
  final String? labelText;

  /// Optional helper text rendered below when no error is active.
  final String? helperText;

  /// Optional static error text overridden by active bloc errors on the field.
  final String? errorText;

  /// Whether multiple segments can be selected at once. Defaults to `false`.
  final bool multiSelect;

  /// Whether deselecting the last active segment is allowed. Defaults to `false`.
  final bool emptySelectionAllowed;

  /// Whether a checkmark icon is rendered on selected segments.
  final bool showSelectedIcon;

  /// Optional style override applied to [SegmentedButton].
  final ButtonStyle? style;

  /// Outer padding around the segmented field.
  final EdgeInsetsGeometry? padding;

  /// Whether user interaction is enabled. Defaults to `true`.
  final bool enabled;

  /// In [multiSelect] mode, emits `Set<T>` when `true` unless the existing
  /// `formData` value is a [List].
  final bool emitSetInMultiSelect;

  /// Text style applied to [labelText].
  final TextStyle? labelStyle;

  /// Text style applied to [helperText].
  final TextStyle? helperStyle;

  /// Text style applied to validation error text.
  final TextStyle? errorStyle;

  /// Creates segmented field configuration options.
  const BlocxSegmentedFieldOptions({
    this.labelText,
    this.helperText,
    this.errorText,
    this.multiSelect = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = true,
    this.style,
    this.padding,
    this.enabled = true,
    this.emitSetInMultiSelect = true,
    this.labelStyle,
    this.helperStyle,
    this.errorStyle,
  });
}

/// A reactive Material 3 [SegmentedButton] field wired to a [BlocxFormBloc].
///
/// Supports both single-select (`T?`) and multi-select (`Set<T>` / `List<T>`)
/// fields, displays bloc validation errors automatically, and assigns a
/// deterministic `ValueKey('blocx_field_${formKey.name}')` to the control.
class BlocxFormSegmentedField<
  F extends BlocxBaseFormEntity<F, E>,
  P,
  E extends Enum,
  T
>
    extends StatelessWidget {
  /// The enum key identifying this field in the form entity.
  final E formKey;

  /// Ordered segments to render inside the [SegmentedButton].
  final List<BlocxSegmentOption<T>> segments;

  /// Visual and behavioural configuration.
  final BlocxSegmentedFieldOptions fieldOptions;

  /// Optional explicit single-select value override.
  final T? value;

  /// Optional explicit multi-select value override.
  final Iterable<T>? selectedValues;

  /// Creates a reactive segmented button form field.
  const BlocxFormSegmentedField({
    super.key,
    required this.formKey,
    required this.segments,
    this.fieldOptions = const BlocxSegmentedFieldOptions(),
    this.value,
    this.selectedValues,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBloc =
        BlocxFormScope.maybeOf<F, P, E>(context)?.bloc ??
        BlocProvider.of<BlocxFormBloc<F, P, E>>(context);

    final rawValue = resolvedBloc.formData.getValueByKey(formKey);
    final selectedSet = _resolveSelectedSet(rawValue);
    final effectiveEmptyAllowed =
        fieldOptions.emptySelectionAllowed || selectedSet.isEmpty;
    final errorText =
        resolvedBloc.state.errorByKey(formKey) ?? fieldOptions.errorText;
    final theme = Theme.of(context);
    final bool shouldEmitList = switch (rawValue) {
      final List<dynamic> _ => true,
      final Set<dynamic> _ => false,
      _ => !fieldOptions.emitSetInMultiSelect,
    };

    return Padding(
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
          SegmentedButton<T>(
            key: ValueKey<String>('blocx_field_${formKey.name}'),
            segments: segments
                .map(
                  (segment) => ButtonSegment<T>(
                    value: segment.value,
                    label:
                        segment.labelWidget ??
                        (segment.label != null ? Text(segment.label!) : null),
                    icon: segment.icon,
                    tooltip: segment.tooltip,
                    enabled: fieldOptions.enabled && segment.enabled,
                  ),
                )
                .toList(),
            selected: selectedSet,
            multiSelectionEnabled: fieldOptions.multiSelect,
            emptySelectionAllowed: effectiveEmptyAllowed,
            showSelectedIcon: fieldOptions.showSelectedIcon,
            style: fieldOptions.style,
            onSelectionChanged: fieldOptions.enabled
                ? (nextSelection) {
                    if (fieldOptions.multiSelect) {
                      final dynamic payload = shouldEmitList
                          ? nextSelection.toList(growable: false)
                          : Set<T>.unmodifiable(nextSelection);
                      resolvedBloc.add(
                        BlocxFormEventUpdateData<E>(
                          data: payload,
                          key: formKey,
                        ),
                      );
                    } else {
                      final T? nextSingle = nextSelection.isEmpty
                          ? null
                          : nextSelection.first;
                      resolvedBloc.add(
                        BlocxFormEventUpdateData<E>(
                          data: nextSingle,
                          key: formKey,
                        ),
                      );
                    }
                  }
                : null,
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
    );
  }

  Set<T> _resolveSelectedSet(dynamic rawValue) {
    final availableValues = segments.map((s) => s.value).toSet();

    if (fieldOptions.multiSelect) {
      if (selectedValues != null) {
        return selectedValues!.where(availableValues.contains).toSet();
      }
      if (rawValue is Iterable) {
        return rawValue.whereType<T>().where(availableValues.contains).toSet();
      }
      return <T>{};
    }

    final singleCandidate = value ?? (rawValue is T ? rawValue : null);
    if (singleCandidate != null && availableValues.contains(singleCandidate)) {
      return <T>{singleCandidate};
    }
    return <T>{};
  }
}
