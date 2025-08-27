import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';

class BlocxSnackBar extends StatelessWidget {
  final String message;
  final String? title;
  final BlocXSnackbarType snackbarType;

  const BlocxSnackBar({super.key, required this.message, this.title, required this.snackbarType});

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    required BlocXSnackbarType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      duration: duration,
      dismissDirection: DismissDirection.horizontal,
      backgroundColor: Colors.transparent, // we style our own container
      padding: EdgeInsets.zero, // let our content manage padding
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16 + MediaQuery.viewInsetsOf(context).bottom),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: BlocxSnackBar(message: message, title: title, snackbarType: type),
    );
    final m = ScaffoldMessenger.of(context);
    m.clearSnackBars();
    m.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colorsFor(theme.colorScheme, snackbarType);

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(snackbarType.icon, color: colors.onBg),
            const SizedBox(width: 12),
            Expanded(child: _titleMessage(context, colors.onBg)),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              icon: Icon(Icons.close, color: colors.onBg),
              tooltip: 'Close',
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleMessage(BuildContext context, Color onBg) {
    final textTheme = Theme.of(context).textTheme;

    final messageWidget = Text(
      message,
      style: textTheme.bodyMedium?.copyWith(color: onBg),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );

    if (title == null) return messageWidget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title!,
          style: textTheme.titleSmall?.copyWith(color: onBg, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        messageWidget,
      ],
    );
  }
}

class _SnackColors {
  final Color bg;
  final Color onBg;
  const _SnackColors(this.bg, this.onBg);
}

_SnackColors _colorsFor(ColorScheme scheme, BlocXSnackbarType type) {
  switch (type) {
    case BlocXSnackbarType.error:
      return _SnackColors(scheme.errorContainer, scheme.onErrorContainer);
    case BlocXSnackbarType.info:
      return _SnackColors(scheme.primaryContainer, scheme.onPrimaryContainer);
    case BlocXSnackbarType.warning:
      return _SnackColors(scheme.tertiaryContainer, scheme.onTertiaryContainer);
  }
}

extension on BlocXSnackbarType {
  IconData get icon => switch (this) {
    BlocXSnackbarType.error => Icons.error_outline,
    BlocXSnackbarType.info => Icons.info_outline,
    BlocXSnackbarType.warning => Icons.warning_amber_outlined,
  };
}
