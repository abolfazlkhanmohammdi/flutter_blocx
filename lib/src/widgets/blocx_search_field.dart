import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A search text field that integrates with a [SearchableListBlocMixin].
///
/// - Typing triggers [ListEventSearch].
/// - Clearing input triggers [ListEventClearSearch].
class BlocxSearchField<T extends BaseEntity, P> extends StatelessWidget {
  final TextEditingController controller;
  final BlocxSearchFieldOptions options;

  const BlocxSearchField({
    super.key,
    required this.controller,
    this.options = const BlocxSearchFieldOptions(),
  });

  @override
  Widget build(BuildContext context) {
    final bloc = _blocOrThrowSearchable(context);

    final defaultDecoration = InputDecoration(
      hintText: options.hintText ?? "Search...",
      hintStyle:
          options.hintStyle ??
          Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
      prefixIcon: options.prefixIcon ?? const Icon(Icons.search),
      suffixIcon: options.showClearButton
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                bloc.add(ListEventClearSearch<T>());
              },
            )
          : null,
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );

    return TextField(
      controller: controller,
      decoration: options.decoration ?? defaultDecoration,
      style: options.style,
      keyboardType: options.keyboardType,
      textCapitalization: options.textCapitalization,
      textInputAction: options.textInputAction,
      textAlign: options.textAlign,
      maxLines: options.maxLines,
      minLines: options.minLines,
      autofocus: options.autofocus,
      obscureText: options.obscureText,
      // ← keep onChange exactly as you had it
      onChanged: (text) => bloc.add(ListEventSearch<T>(searchText: text)),
      onSubmitted: (text) => bloc.add(ListEventSearch<T>(searchText: text)),
    );
  }

  /// Returns the nearest [ListBloc<T, P>] and ensures it supports searching.
  ///
  /// Throws a clear [FlutterError] if:
  /// - No `ListBloc<T, P>` is found in the widget tree, or
  /// - The bloc does not implement `SearchableListBlocContract<T>`.
  ListBloc<T, P> _blocOrThrowSearchable(BuildContext context) {
    final b = BlocProvider.of<ListBloc<T, P>>(context, listen: false);
    if (!b.isSearchable) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('BlocxSearchField requires a searchable ListBloc.'),
        ErrorDescription(
          'Found a ListBloc<$T, $P>, but it does not implement '
          'SearchableListBlocMixin<$T,$P>.\n'
          'mix SearchableListBlocMixin in your bloc.',
        ),
      ]);
    }
    return b;
  }
}

/// Options for customizing [BlocxSearchField].
///
/// Wraps common [TextField] parameters so you can pass them directly.
class BlocxSearchFieldOptions {
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

  // Extra customization for the default decoration
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefixIcon;
  final bool showClearButton;

  const BlocxSearchFieldOptions({
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
    this.hintText,
    this.hintStyle,
    this.prefixIcon,
    this.showClearButton = true,
  });
}
