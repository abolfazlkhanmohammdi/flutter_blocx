import 'package:flutter/widgets.dart';

import 'blocx_local.dart';

/// Builder callback invoked by [BlocxUiToggle] with the current boolean state
/// along with [toggle] and [setValue] helpers.
typedef BlocxUiToggleBuilder =
    Widget Function(
      BuildContext context,
      bool isActive,
      VoidCallback toggle,
      ValueChanged<bool> setValue,
    );

/// Specialized boolean toggle primitive built on [BlocxLocal]`<bool>`.
class BlocxUiToggle extends StatelessWidget {
  /// Initial active state when mounted. Defaults to `false`.
  final bool initialValue;

  /// Optional callback invoked whenever [isActive] changes.
  final ValueChanged<bool>? onChanged;

  /// Builds the child subtree from the active state and toggle callbacks.
  final BlocxUiToggleBuilder builder;

  /// Creates a boolean UI toggle primitive.
  const BlocxUiToggle({
    super.key,
    this.initialValue = false,
    required this.builder,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocxLocal<bool>(
      initialValue: initialValue,
      onChanged: onChanged,
      builder: (context, value, setValue, update) =>
          builder(context, value, () => update((v) => !v), setValue),
    );
  }
}
