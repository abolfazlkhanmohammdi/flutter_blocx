import 'package:flutter/widgets.dart';

/// Builder callback invoked by [BlocxLocal] with the current local state value
/// and mutation helpers.
typedef BlocxLocalWidgetBuilder<T> =
    Widget Function(
      BuildContext context,
      T value,
      ValueChanged<T> setValue,
      void Function(T Function(T current) updater) update,
    );

/// Lightweight, auto-disposing UI-scoped reactive state holder for ephemeral
/// visual micro-interactions (disclosure panels, local tabs, hover/UI toggles)
/// without writing boilerplate `StatefulWidget` classes.
class BlocxLocal<T> extends StatefulWidget {
  /// Initial local state value used when the widget is first mounted.
  final T initialValue;

  /// Optional callback fired whenever the value changes.
  final ValueChanged<T>? onChanged;

  /// Builds the child subtree from the current value and mutation callbacks.
  final BlocxLocalWidgetBuilder<T> builder;

  /// Creates an ephemeral UI-scoped state holder.
  const BlocxLocal({
    super.key,
    required this.initialValue,
    required this.builder,
    this.onChanged,
  });

  @override
  State<BlocxLocal<T>> createState() => _BlocxLocalState<T>();
}

class _BlocxLocalState<T> extends State<BlocxLocal<T>> {
  late final ValueNotifier<T> _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier<T>(widget.initialValue);
  }

  void _setValue(T next) {
    if (!mounted) return;
    if (_notifier.value != next) {
      _notifier.value = next;
      widget.onChanged?.call(next);
    }
  }

  void _update(T Function(T current) updater) {
    _setValue(updater(_notifier.value));
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: _notifier,
      builder: (context, value, _) =>
          widget.builder(context, value, _setValue, _update),
    );
  }
}
