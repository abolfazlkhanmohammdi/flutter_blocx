import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart'
    show
        BlocxCollectionEventSearch,
        BlocxCollectionEventClearSearch,
        BlocxCollectionBloc;
import 'package:flutter/material.dart';
import 'package:flutter_blocx/src/core/localizations/loc_provider.dart';

/// A search text field that integrates with a [SearchableListBlocMixin].
///
/// - Typing triggers [BlocxCollectionEventSearch].
/// - Clearing input triggers [BlocxCollectionEventClearSearch].
class BlocxSearchField<Entity extends BlocxBaseEntity, Payload>
    extends StatelessWidget {
  final TextEditingController controller;
  final BlocxSearchFieldOptions options;
  final BlocxCollectionBloc<Entity, Payload> bloc;
  const BlocxSearchField({
    super.key,
    required this.controller,
    this.options = const BlocxSearchFieldOptions(),
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final defaultDecoration = InputDecoration(
      hintText: options.hintText ?? loc.searchHint,
      hintStyle: options.hintStyle ??
          Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500, fontStyle: FontStyle.italic),
      prefixIcon: options.prefixIcon ?? const Icon(Icons.search),
      suffixIcon: options.showClearButton && controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                bloc.add(BlocxCollectionEventClearSearch<Entity>());
              },
            )
          : null,
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
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
      onChanged: (text) =>
          bloc.add(BlocxCollectionEventSearch<Entity>(searchText: text)),
      onSubmitted: (text) =>
          bloc.add(BlocxCollectionEventSearch<Entity>(searchText: text)),
    );
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
