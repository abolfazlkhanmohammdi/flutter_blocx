import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberNudge extends StatefulWidget {
  const NumberNudge({
    super.key,
    this.initialValue = 0,
    this.min = 0,
    this.max,
    this.smallStep = 1,
    this.bigStep = 5,
    this.buttonLabel = 'Apply',
    this.onChanged,
    this.onSubmit,
  });

  final int initialValue;
  final int min;
  final int? max;
  final int smallStep; // 1
  final int bigStep; // 5
  final String buttonLabel;
  final ValueChanged<int>? onChanged;
  final ValueChanged<int>? onSubmit;

  @override
  State<NumberNudge> createState() => _NumberNudgeState();
}

class _NumberNudgeState extends State<NumberNudge> {
  late final TextEditingController _ctrl;
  Timer? _repeatTimer;

  int get _value => int.tryParse(_ctrl.text) ?? widget.initialValue;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _set(int v) {
    // clamp
    final max = widget.max;
    int clamped = v;
    if (max != null)
      clamped = clamped.clamp(widget.min, max);
    else if (clamped < widget.min)
      clamped = widget.min;

    // only update if changed
    if (_value == clamped) return;
    _ctrl.text = clamped.toString();
    widget.onChanged?.call(clamped);
    setState(() {});
  }

  void _bump(int delta) {
    HapticFeedback.selectionClick();
    _set(_value + delta);
  }

  void _startRepeat(int delta) {
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) => _bump(delta));
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  ButtonStyle _chipStyleTonal(BuildContext context) {
    return FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      minimumSize: const Size(44, 36),
      shape: const StadiumBorder(),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
  }

  // === Auto-flipping tooltip (inline/private) ===
  Widget _autoFlipTooltip({
    required String message,
    required Widget child,
    double estimatedPopupHeight = 56,
    double verticalOffset = 8,
  }) {
    return _AutoFlipTooltip(
      message: message,
      child: child,
      estimatedPopupHeight: estimatedPopupHeight,
      verticalOffset: verticalOffset,
    );
  }

  Widget _stepChip(String label, int delta) {
    return _autoFlipTooltip(
      message: delta > 0 ? 'Increase by $delta' : 'Decrease by ${delta.abs()}',
      child: FilledButton(style: _chipStyleTonal(context), onPressed: () => _bump(delta), child: Text(label)),
    );
  }

  Widget _repeatIcon({required IconData icon, required String tooltip, required int delta}) {
    final button = IconButton(
      icon: Icon(icon),
      onPressed: () => _bump(delta),
      splashRadius: 18,
      visualDensity: VisualDensity.compact,
    );

    // Press & hold auto-repeat + auto-flip tooltip
    return _autoFlipTooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (_) => _startRepeat(delta),
        onLongPressEnd: (_) => _stopRepeat(),
        onTapDown: (_) => _stopRepeat(), // ensure clean state
        child: button,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      // runSpacing: 8,
      children: [
        _stepChip('-${widget.bigStep}', -widget.bigStep),
        _stepChip('-${widget.smallStep}', -widget.smallStep),

        SizedBox(
          width: 120,
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'-?\d+'))],
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: cs.surfaceContainerHighest.withOpacity(0.08),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              prefixIcon: _repeatIcon(icon: Icons.remove_rounded, tooltip: '-1 (hold to repeat)', delta: -1),
              suffixIcon: _repeatIcon(icon: Icons.add_rounded, tooltip: '+1 (hold to repeat)', delta: 1),
            ),
            onChanged: (s) {
              final v = int.tryParse(s);
              if (v != null) _set(v);
            },
            onSubmitted: (_) => widget.onSubmit?.call(_value),
          ),
        ),

        _stepChip('+${widget.smallStep}', widget.smallStep),
        _stepChip('+${widget.bigStep}', widget.bigStep),
        Spacer(),
        FilledButton.icon(
          onPressed: () => widget.onSubmit?.call(_value),
          icon: const Icon(Icons.check_rounded),
          label: Text(widget.buttonLabel),
          style: FilledButton.styleFrom(minimumSize: const Size(80, 40), shape: const StadiumBorder()),
        ),
      ],
    );
  }
}

// Private inline widget that auto-flips Tooltip above/below based on available space.
class _AutoFlipTooltip extends StatefulWidget {
  const _AutoFlipTooltip({
    required this.message,
    required this.child,
    this.estimatedPopupHeight = 56,
    this.verticalOffset = 8,
  });

  final String message;
  final Widget child;
  final double estimatedPopupHeight;
  final double verticalOffset;

  @override
  State<_AutoFlipTooltip> createState() => _AutoFlipTooltipState();
}

class _AutoFlipTooltipState extends State<_AutoFlipTooltip> {
  bool _preferBelow = true;

  void _recompute() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final screenH = MediaQuery.sizeOf(context).height;
    final offset = renderBox.localToGlobal(Offset.zero);
    final top = offset.dy;
    final bottom = top + renderBox.size.height;

    final spaceAbove = top;
    final spaceBelow = screenH - bottom;

    final preferBelow = spaceBelow >= widget.estimatedPopupHeight || spaceBelow >= spaceAbove;
    if (preferBelow != _preferBelow) {
      setState(() => _preferBelow = preferBelow);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
  }

  @override
  Widget build(BuildContext context) {
    // Check again after layout/scroll changes.
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());

    return Tooltip(
      message: widget.message,
      preferBelow: _preferBelow,
      verticalOffset: widget.verticalOffset,
      child: widget.child,
    );
  }
}
