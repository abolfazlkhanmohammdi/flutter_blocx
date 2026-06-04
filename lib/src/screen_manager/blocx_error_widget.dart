import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blocx/src/core/localizations/loc_provider.dart';

@immutable
class BlocxErrorWidget extends StatelessWidget {
  /// The thrown error (e.g., Exception, DioError, etc.)
  final ReadableError error;

  /// Optional "Try again" callback.
  final VoidCallback? onRetry;

  /// Optional callback when user taps "Report".
  final VoidCallback? onReport;

  /// Controls overall padding; defaults to symmetric 24.
  final EdgeInsetsGeometry padding;

  /// When true, shows stack trace panel expanded by default.
  final bool expandDetails;

  const BlocxErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onReport,
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
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    bool expandDetails = false,
  }) {
    return BlocxErrorWidget(
      key: key,
      error: state.error,
      onRetry: onRetry,
      onReport: onReport,
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 40, color: scheme.onErrorContainer),
                  const SizedBox(height: 12),
                  Text(
                    error.title ?? loc.somethingWentWrong,
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.message,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: scheme.onErrorContainer),
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
                  if (error.stackTrace != null) ...[
                    const SizedBox(height: 12),
                    _DetailsTile(
                      color: scheme.onErrorContainer,
                      expanded: expandDetails,
                      stackTrace: error.stackTrace!,
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
                          child: Text(loc.tryAgain),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => _copyDetails(context),
                        icon: const Icon(Icons.copy),
                        label: Text(loc.copyDetails),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.onErrorContainer,
                          side: BorderSide(
                              color: scheme.onErrorContainer
                                  .withValues(alpha: 0.4)),
                        ),
                      ),
                      if (onReport != null)
                        TextButton.icon(
                          onPressed: onReport,
                          icon: const Icon(Icons.bug_report_outlined),
                          label: Text(loc.report),
                          style: TextButton.styleFrom(
                              foregroundColor: scheme.onErrorContainer),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.exit_to_app_rounded),
                        label: Text(loc.close),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.onErrorContainer,
                          side: BorderSide(
                              color: scheme.onErrorContainer
                                  .withValues(alpha: 0.4)),
                        ),
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
      ..writeln(error.stackTrace?.toString() ?? '<none>');

    await Clipboard.setData(ClipboardData(text: buf.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.errorDetailsCopied)));
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
      data: Theme.of(context)
          .copyWith(dividerColor: color.withValues(alpha: 0.2)),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(loc.details,
            style: textTheme.titleSmall?.copyWith(color: color)),
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
