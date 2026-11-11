/// Testing utilities and semantic widget finders for `flutter_blocx`.
///
/// Re-exports `package:blocx_core/testing.dart` so widget and integration tests
/// can import a single testing entry point.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

export 'package:blocx_core/testing.dart';

bool _matchesBlocxItemKey(Key? key, String idStr) {
  if (key is ValueKey) {
    final valueStr = key.value.toString();
    return valueStr == 'blocx_item_$idStr' ||
        valueStr == idStr ||
        valueStr.startsWith('$idStr+');
  }
  return false;
}

bool _hasMatchingBlocxItemAncestor(Element element, String idStr) {
  var foundAncestor = false;
  element.visitAncestorElements((ancestor) {
    if (_matchesBlocxItemKey(ancestor.widget.key, idStr)) {
      foundAncestor = true;
      return false;
    }
    return true;
  });
  return foundAncestor;
}

/// Semantic finders on [CommonFinders] (`find`) for `flutter_blocx` widgets
/// and collection items.
extension BlocxCommonFinders on CommonFinders {
  /// Finds a collection item by its entity [id], matching
  /// `ValueKey('blocx_item_$id')`, `ValueKey('$id')`, and versioned keys such
  /// as `ValueKey('$id+$version')`, deduplicating stacked ancestors
  /// (`AutoScrollTag`, `KeyedSubtree`, user item key) to return one match per
  /// rendered item.
  Finder blocxItem(Object id) {
    final idStr = id.toString();
    return byElementPredicate(
      (element) =>
          _matchesBlocxItemKey(element.widget.key, idStr) &&
          !_hasMatchingBlocxItemAncestor(element, idStr),
      description: 'BlocX collection item with id "$idStr"',
    );
  }

  /// Finds a [BlocXFormTextField], [BlocxFormChipField], or
  /// [BlocxFormSegmentedField] by its enum [field] key.
  Finder blocxField(Enum field) =>
      byKey(ValueKey<String>('blocx_field_${field.name}'));

  /// Finds a [BlocXFormDropdown] by its enum [field] key.
  Finder blocxDropdown(Enum field) =>
      byKey(ValueKey<String>('blocx_dropdown_${field.name}'));

  /// Finds a [BlocxFormCheckbox] by its enum [field] key.
  Finder blocxCheckbox(Enum field) =>
      byKey(ValueKey<String>('blocx_checkbox_${field.name}'));

  /// Finds a [BlocxFormSwitchField] by its enum [field] key.
  Finder blocxSwitch(Enum field) =>
      byKey(ValueKey<String>('blocx_switch_${field.name}'));

  /// Finds a password visibility toggle button inside an obscured
  /// [BlocXFormTextField] by its enum [field] key.
  Finder blocxObscureToggle(Enum field) =>
      byKey(ValueKey<String>('blocx_obscure_toggle_${field.name}'));

  /// Finds a chip or filter widget with semantic key
  /// `ValueKey('blocx_filter_$filterValue')`.
  Finder blocxFilter(Object filterValue) =>
      byKey(ValueKey<String>('blocx_filter_$filterValue'));

  /// Finds a status badge with key `ValueKey('blocx_badge_$status')`.
  Finder blocxBadge(Object status) =>
      byKey(ValueKey<String>('blocx_badge_$status'));

  /// Finds the default form submit button ([BlocxFormRegisterButton]).
  Finder blocxSubmitButton() =>
      byKey(const ValueKey<String>('blocx_submit_button'));

  /// Finds the default form cancel button inside [BlocxFormButtonRow].
  Finder blocxCancelButton() =>
      byKey(const ValueKey<String>('blocx_cancel_button'));

  /// Finds the collection search text field ([BlocxSearchField]).
  Finder blocxSearchField() =>
      byKey(const ValueKey<String>('blocx_search_field'));
}
