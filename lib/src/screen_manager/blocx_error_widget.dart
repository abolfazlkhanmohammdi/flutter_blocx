import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class BlocxErrorWidget extends StatelessWidget {
  /// The thrown error (e.g., Exception, DioError, etc.)
  final Object error;

  /// Optional stack trace to show in the expandable details.
  final StackTrace? stackTrace;

  /// Optional "Try again" callback.
  final VoidCallback? onRetry;

  /// Optional callback when user taps "Report".
  final VoidCallback? onReport;

  /// Optional title override (defaults to a friendly message).
  final String? title;

  /// Controls overall padding; defaults to symmetric 24.
  final EdgeInsetsGeometry padding;

  /// When true, shows stack trace panel expanded by default.
  final bool expandDetails;

  const BlocxErrorWidget({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.onReport,
    this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.expandDetails = false,
  });

  /// Convenience factory to build directly from your cubit state.
  factory BlocxErrorWidget.fromState(
    ScreenManagerCubitStateDisplayErrorPage state, {
    Key? key,
    VoidCallback? onRetry,
    VoidCallback? onReport,
    String? title,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    bool expandDetails = false,
  }) {
    return BlocxErrorWidget(
      key: key,
      error: state.error,
      stackTrace: state.stackTrace,
      onRetry: onRetry,
      onReport: onReport,
      title: title,
      padding: padding,
      expandDetails: expandDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: padding,
          child: Card(
            color: scheme.errorContainer,
            surfaceTintColor: scheme.errorContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 40, color: scheme.onErrorContainer),
                  const SizedBox(height: 12),
                  Text(
                    title ?? 'Something went wrong',
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _shortError(error),
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onErrorContainer.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (stackTrace != null) ...[
                    const SizedBox(height: 12),
                    _DetailsTile(
                      color: scheme.onErrorContainer,
                      expanded: expandDetails,
                      stackTrace: stackTrace!,
                      error: error,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      if (onRetry != null)
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                          ),
                          onPressed: onRetry,
                          child: const Text('Try again'),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => _copyDetails(context),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.onErrorContainer,
                          side: BorderSide(color: scheme.onErrorContainer.withValues(alpha: 0.4)),
                        ),
                      ),
                      if (onReport != null)
                        TextButton.icon(
                          onPressed: onReport,
                          icon: const Icon(Icons.bug_report_outlined),
                          label: const Text('Report'),
                          style: TextButton.styleFrom(foregroundColor: scheme.onErrorContainer),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _shortError(Object e) {
    final s = e.toString().trim();
    // Take first line if it’s multi-line (common for Exceptions)
    final nl = s.indexOf('\n');
    return nl > 0 ? s.substring(0, nl) : s;
  }

  Future<void> _copyDetails(BuildContext context) async {
    final buf = StringBuffer()
      ..writeln('Error: $error')
      ..writeln()
      ..writeln('StackTrace:')
      ..writeln(stackTrace?.toString() ?? '<none>');

    await Clipboard.setData(ClipboardData(text: buf.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error details copied')));
    }
  }
}

/// Collapsible details (stack trace)
class _DetailsTile extends StatelessWidget {
  const _DetailsTile({
    required this.color,
    required this.expanded,
    required this.stackTrace,
    required this.error,
  });

  final Color color;
  final bool expanded;
  final StackTrace stackTrace;
  final Object error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: color.withValues(alpha: 0.2)),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text('Details', style: textTheme.titleSmall?.copyWith(color: color)),
        children: [
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              'Error: $error\n\n$stackTrace',
              style: textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.9),
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
